//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Alamofire

class ItemViewController: UIViewController, UIScrollViewDelegate{
    var itemID: Int?
    var item: Item?
    var itemImages:[UIImageView] = []
    enum NetworkError: Error {
        case url
        case server
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate=self
    
        load()
    }
    
    //MARK: - Fetching from API
    func load(){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.loadItem()
                .flatMap{self.loadItemImages($0)}
            
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    do{
                        try self.itemImages = data.unwrap()
                    } catch{
                        print(error)
                    }
                    activityIndicator.stopAnimating()
                case let .failure(error):
                    print(error)
                }
                
                self.buildUI()
            }
        }
    }
    
    func loadItem() -> Result<Item>{
        var result: Result<Item>!
        let semaphore = DispatchSemaphore(value: 0)
        let apiURL = "https://digitalvision.rs/parametri.php?action=artikaleng&id=\(itemID!)"
        
        guard let url = URL(string: apiURL) else {
            return .failure(NetworkError.url)
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let item = self.parseJSON(data) {
                    self.item = item
                    result = .success(item)
                } else{
                    result = .failure(NetworkError.server)
                }
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func parseJSON(_ data: Data) -> Item?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Item.self, from: data)
            return decodedData
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func loadItemImages(_ item: Item) -> Result<[UIImageView]>{
        var result:Result<[UIImageView]>
        var images:[UIImageView] = []
        let semaphore = DispatchSemaphore(value: 0)
        var counter = 0
        
        for pictureURL in item.ImageUrls! {
            Alamofire.request(pictureURL).response { response in
                if let data = response.data {
                    images.append(UIImageView(image: UIImage(data: data)))
                }
                
                if (counter==item.ImageUrls!.count-1){
                    semaphore.signal()
                }
                
                counter+=1
            }
        }
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if(images.count>0){
            result = .success(images)
        } else{
            result = .failure(NetworkError.server)
        }
        
        return result
    }
    
    func buildUI(){
        nameLabel.text = item!.Name
        priceLabel.text = String(item!.Price) + "€"
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: 300 * CGFloat(itemImages.count), height: 300)
        pageControl.numberOfPages = item!.ImageUrls!.count
        pageControl.currentPage = 0
        
        for (i, imageView) in itemImages.enumerated(){
            imageView.frame = CGRect(x: 300 * CGFloat(i), y: 0, width: 300, height: 300)
            scrollView.addSubview(imageView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/300)
        pageControl.currentPage = Int(pageIndex)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        let alert = UIAlertController(title: "Added to cart 🛒", message: item!.Name, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

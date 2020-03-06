//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Kingfisher

class ItemViewController: UIViewController, UIScrollViewDelegate{
    var itemID: Int?
    var item: Item?
    enum NetworkError: Error {
        case url
        case server
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
                    self.item = data
                    self.buildUI()
                case let .failure(error):
                    print(error)
                }

                activityIndicator.stopAnimating()
            }
        }
    }
    
    func loadItem() -> Result<ItemCodable, Error>{
        var result: Result<ItemCodable, Error>!
        let semaphore = DispatchSemaphore(value: 0)
        
        let apiURL = "https://digitalvision.rs/parametri.php?action=artikaleng&id=\(itemID!)"
        guard let url = URL(string: apiURL) else {
            return .failure(NetworkError.url)
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let itemCodable = self.parseJSON(data) {
                    result = .success(itemCodable)
                } else{
                    result = .failure(NetworkError.server)
                }
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func parseJSON(_ data: Data) -> ItemCodable?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ItemCodable.self, from: data)
            return decodedData
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func loadItemImages(_ itemCodable: ItemCodable) -> Result<Item, Error>{
        var result:Result<Item, Error>
        var images:[UIImage] = []
        let semaphore = DispatchSemaphore(value: 0)

        for imageURL in itemCodable.ImageUrls! {
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                let image: UIImage
                do{
                    image = try result.get().image
                } catch{
                    image = UIImage(systemName: "desktopcomputer")!
                    print("error fetching image")
                }
                
                images.append(image)
                
                if (images.count == itemCodable.ImageUrls!.count){
                    semaphore.signal()
                }
            }
        }
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        let item = Item(item: itemCodable, images: images)
        result = .success(item)
        return result
    }
    
    func buildUI(){
        nameLabel.text = item!.name
        priceLabel.text = String(item!.price) + "€"
        
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: 300 * CGFloat(item!.images!.count), height: 300)
        for (i, image) in item!.images!.enumerated(){
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 300 * CGFloat(i), y: 0, width: 300, height: 300)
            scrollView.addSubview(imageView)
        }
        
        pageControl.numberOfPages = item!.images!.count
        pageControl.currentPage = 0
                
        let htmlData = NSString(string: item!.description).data(using: String.Encoding.utf8.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!,
                                                       options: options,
                                                       documentAttributes: nil)
        descriptionTextView.attributedText = attributedString
        descriptionTextView.isEditable = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/300)
        pageControl.currentPage = Int(pageIndex)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        let alert = UIAlertController(title: "Added to cart 🛒", message: item!.name, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

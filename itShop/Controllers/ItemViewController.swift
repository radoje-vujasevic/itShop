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
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate=self
        
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        DispatchQueue.global(qos: .utility).async {
            self.loadItem()
        }
    }
    
    //MARK: - Fetching from API
    func loadItem(){
        let url = URL(string: "https://digitalvision.rs/parametri.php?action=artikaleng&id=\(itemID!)")!
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let itemCodable = try decoder.decode(ItemCodable.self, from: data)
                    self.loadItemImages(itemCodable)
                } catch {
                    print("error parsing items")
                }
            }  else{
                print("error fetching item")
            }
        }.resume()
    }
    
    func loadItemImages(_ itemCodable: ItemCodable){
        var images:[UIImage] = []
        
        for imageURL in itemCodable.ImageUrls! {
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                let image: UIImage
                do{
                    image = try result.get().image
                } catch{
                    print("error fetching item image")
                    image = UIImage(systemName: "desktopcomputer")!
                }
                
                images.append(image)
                
                if (images.count == itemCodable.ImageUrls!.count){
                    self.item = Item(item: itemCodable, images: images)
                    self.buildUI()
                }
            }
        }
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
        
        activityIndicator.stopAnimating()
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

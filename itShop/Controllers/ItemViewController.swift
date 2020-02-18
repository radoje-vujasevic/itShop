//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController{
    var itemID: Int?
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    //MARK: - Fetching from API
    func loadItems(){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        let apiURL = "https://digitalvision.rs/parametri.php?action=artikaleng&id=\(itemID!)"
        
        if let url = URL(string: apiURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Error with API call")
                }
                if let safeData = data {
                    if let item = self.parseJSON(safeData) {
                        self.item = item
                        DispatchQueue.main.async {
                            activityIndicator.stopAnimating()
                        }
                    }
                }
            }
            task.resume()
        }
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
}

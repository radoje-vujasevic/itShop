//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Alamofire

class ItemListViewController: UITableViewController{
    var categoryID: Int?
    var items: [Item] = []
    var itemImages: [UIImage] = []
    enum NetworkError: Error {
        case url
        case server
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableCell = UINib(nibName: "ItemListViewCell", bundle: nil)
        tableView.register(tableCell, forCellReuseIdentifier: "ItemListViewCellID")
        
        load()
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemListViewCellID", for: indexPath) as! ItemListViewCell
        cell.cellImage.image = itemImages[indexPath.row]
        cell.nameLabel.text = items[indexPath.row].Name
        cell.priceLabel.text = "Cena: \(items[indexPath.row].Price)€"
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ItemViewController
            destinationVC.itemID = items[indexPath.row].Id
            destinationVC.item = items[indexPath.row]
        }
    }
    
    //MARK: - Fetching from API
    func load(){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.loadItems()
                .flatMap{self.loadItemImages($0)}
            
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    do{
                        try self.itemImages = data.unwrap()
                    } catch{
                        print(error)
                    }
                    self.tableView.reloadData()
                    activityIndicator.stopAnimating()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    func loadItems() -> Result<[Item]>{
        let apiURL = "https://digitalvision.rs/parametri.php?action=artikliPoKategorijiEng&id=\(categoryID!)"
        
        guard let url = URL(string: apiURL) else {
            return .failure(NetworkError.url)
        }
        
        var result: Result<[Item]>!
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let items = self.parseJSON(data) {
                    self.items = items
                    result = .success(items)
                } else{
                    result = .failure(NetworkError.server)
                }
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func loadItemImages(_ items: [Item]) -> Result<[UIImage]>{
        var result:Result<[UIImage]>
        var images:[UIImage] = []
        let semaphore = DispatchSemaphore(value: 0)
        var counter = 0
        
        for item in items {
            guard let url = URL(string: item.MainImage) else {
                return .failure(NetworkError.url)
            }
            
            Alamofire.request(url).response { response in                
                if let data = response.data {
                    images.append(UIImage(data: data)!)
                }
                
                if (counter==items.count-1){
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
    
    func parseJSON(_ data: Data) -> Array<Item>?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Array<Item>.self, from: data)
            return decodedData
            
        } catch {
            print(error)
            return nil
        }
    }
}

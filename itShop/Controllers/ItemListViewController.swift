//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Kingfisher

class ItemListViewController: UITableViewController{
    var categoryID: Int?
    var items: [Item] = []
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
        cell.cellImage.image = items[indexPath.row].mainImage
        cell.nameLabel.text = items[indexPath.row].name
        cell.priceLabel.text = "Cena: \(items[indexPath.row].price)€"
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ItemViewController
            destinationVC.itemID = items[indexPath.row].id
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
                    self.items = data
                    self.tableView.reloadData()
                case let .failure(error):
                    print(error)
                }
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func loadItems() -> Result<[ItemCodable], Error>{
        let apiURL = "https://digitalvision.rs/parametri.php?action=artikliPoKategorijiEng&id=\(categoryID!)"
        guard let url = URL(string: apiURL) else {
            return .failure(NetworkError.url)
        }
        var result: Result<[ItemCodable], Error>!
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let items = self.parseJSON(data) {
                    result = .success(items)
                }
            } else{
                result = .failure(NetworkError.server)
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func loadItemImages(_ itemsCodable: [ItemCodable]) -> Result<[Item], Error>{
        var result:Result<[Item], Error>
        var items:[Item] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        for item in itemsCodable {
            KingfisherManager.shared.retrieveImage(with: item.MainImage) { result in
                do{
                    let image = try result.get().image
                    items.append(Item(item: item, image: image))
                } catch{
                    print("error fetching image")
                    items.append(Item(item: item, image: UIImage(systemName: "desktopcomputer")!))
                }
                
                if (items.count == itemsCodable.count){
                    semaphore.signal()
                }
            }
        }
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        result = .success(items)
        return result
    }
    
    func parseJSON(_ data: Data) -> Array<ItemCodable>?{
        let decoder = JSONDecoder()
        do {
            let itemCodable = try decoder.decode(Array<ItemCodable>.self, from: data)
            return itemCodable
            
        } catch {
            print(error)
            return nil
        }
    }
}

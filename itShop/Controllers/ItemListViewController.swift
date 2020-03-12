//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Kingfisher

class ItemListViewController: UITableViewController, passName{
    var categoryID: Int?
    var items: [Item] = []
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableCell = UINib(nibName: "ItemListViewCell", bundle: nil)
        tableView.register(tableCell, forCellReuseIdentifier: "ItemListViewCellID")
        
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        DispatchQueue.global(qos: .utility).async {
            self.loadItems()
        }
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemListViewCellID", for: indexPath) as! ItemListViewCell
        cell.addToCart.tag = indexPath.row
        cell.cellImage.image = items[indexPath.row].mainImage
        cell.nameLabel.text = items[indexPath.row].name
        cell.priceLabel.text = "Cena: \(items[indexPath.row].price)€"
        cell.delegate = self
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
    func loadItems(){
        let url = URL(string: "https://digitalvision.rs/parametri.php?action=artikliPoKategorijiEng&id=\(categoryID!)")!
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let itemsCodable = try decoder.decode(Array<ItemCodable>.self, from: data)
                    self.loadItemsImages(itemsCodable)
                } catch {
                    print("error parsing items")
                }
            } else{
                print("error fetching items")
            }
        }.resume()
    }
    
    func loadItemsImages(_ itemsCodable: [ItemCodable]){
        var items:[Item] = []
        
        for item in itemsCodable {
            KingfisherManager.shared.retrieveImage(with: item.MainImage) { result in
                do{
                    let image = try result.get().image
                    items.append(Item(item: item, image: image))
                } catch{
                    print("error fetching item image")
                    items.append(Item(item: item, image: UIImage(systemName: "desktopcomputer")!))
                }
                
                if (items.count == itemsCodable.count){
                    self.buildUI(items)
                }
            }
        }
    }
    
    func buildUI(_ items:[Item]) {
        DispatchQueue.main.async {
            self.items = items
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func showMessage(_ i: Int) {
        let alert = UIAlertController(title: "Added to cart 🛒", message: items[i].name, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

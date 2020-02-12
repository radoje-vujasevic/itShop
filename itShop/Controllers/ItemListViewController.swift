//
//  ItemViewController.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit

class ItemListViewController: UITableViewController{
    var categoryID: Int?
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].Name
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
        }
    }
    
    //MARK: - Fetching from API
    func loadItems(){
        let apiURL = "https://digitalvision.rs/parametri.php?action=artikliPoKategorijiEng&id=\(categoryID!)"
        
        if let url = URL(string: apiURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Error with API call")
                }
                if let safeData = data {
                    if let items = self.parseJSON(safeData) {
                        self.items = items
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            task.resume()
        }
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

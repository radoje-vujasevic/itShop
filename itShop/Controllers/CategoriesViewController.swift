//
//  ViewController.swift
//  itShop
//
//  Created by Raša on 11/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController {
    var categories:[Category] = []
    var start: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (start){
            loadCategories()
        }
    }
        
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].Name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If there are children categories and there is more than one child category --> Push to navigation controller this ViewController as next view
        if (categories[indexPath.row].ChildsExist && categories[indexPath.row].ChildCategories.count > 1){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let loadVC = storyBoard.instantiateViewController(withIdentifier: "CategoryList") as! CategoriesViewController
            loadVC.categories = categories[indexPath.row].ChildCategories
            loadVC.start = false
            self.navigationController?.pushViewController(loadVC, animated: true)
        }
        else {
            performSegue(withIdentifier: "segueToItemsList", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if let destinationVC = segue.destination as? ItemListViewController{
                let clickedCategory = categories[indexPath.row]
                if(clickedCategory.ChildCategories.count == 1){
                    destinationVC.categoryID = clickedCategory.ChildCategories[0].Id
                }
                else{
                    destinationVC.categoryID = clickedCategory.Id
                }
            }
        }
    }
    
    //MARK: - Fetching from API
    func loadCategories(){
        let apiURL = "http://digitalvision.rs:8080/articleCategories/?showAll=true"
        
        if let url = URL(string: apiURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Error with API call")
                }
                if let safeData = data {
                    if let categories = self.parseJSON(safeData) {
                        self.categories = categories
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Array<Category>?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Array<Category>.self, from: data)
            return decodedData
            
        } catch {
            print(error)
            return nil
        }
    }
}


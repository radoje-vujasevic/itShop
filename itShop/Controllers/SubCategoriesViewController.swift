//
//  SubCategoriesViewController.swift
//  itShop
//
//  Created by Raša on 11/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit

class SubCategoriesViewController: UITableViewController{
    var childCategories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "subCategoryCell")
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCategoryCell", for: indexPath)
        cell.textLabel?.text = childCategories[indexPath.row].Name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If there are children categories and there is more than one child category --> List of categories
        if (childCategories[indexPath.row].ChildsExist && childCategories[indexPath.row].ChildCategories.count > 1){
            performSegue(withIdentifier: "segueToSubCategories2", sender: self)
        }
        else {
            performSegue(withIdentifier: "segueToItemList", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let clickedCategory = childCategories[indexPath.row]
            
            if let destinationVC = segue.destination as? SubCategoriesViewController{
                destinationVC.childCategories = clickedCategory.ChildCategories
            }
            
            if let destinationVC = segue.destination as? ItemListViewController{
                if(clickedCategory.ChildCategories.count == 1){
                    destinationVC.categoryID = clickedCategory.ChildCategories[0].Id
                }
                else{
                    destinationVC.categoryID = clickedCategory.Id
                }
            }
        }
    }
}

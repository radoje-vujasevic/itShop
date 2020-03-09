//
//  ViewController.swift
//  itShop
//
//  Created by Raša on 11/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Kingfisher

class CategoriesViewController: UITableViewController {
    var start: Bool = true
    var categories:[Category] = []
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        if (start) {
            activityIndicator.startAnimating()
            
            DispatchQueue.global(qos: .utility).async {
                self.loadCategories()
            }
        }
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.imageView?.image = categories[indexPath.row].image
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCategory = categories[indexPath.row]
        if (clickedCategory.childsExist && clickedCategory.childCategories.count > 1){
            activityIndicator.startAnimating()
            DispatchQueue.global(qos: .utility).async {
                self.loadCategoryImages(clickedCategory.childCategories, self.anotherCategoryView)
            }
        } else {
            let loadVC = storyBoard.instantiateViewController(withIdentifier: "ItemList") as! ItemListViewController
            loadVC.categoryID = clickedCategory.childCategories.count == 1 ? clickedCategory.childCategories[0].Id : clickedCategory.id
            self.navigationController?.pushViewController(loadVC, animated: true)
        }
    }

    //MARK: - Fetching from API
    func loadCategories(){
        let url = URL(string: "http://digitalvision.rs:8080/articleCategories/?showAll=true")!
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let categoriesCodable = try decoder.decode(Array<CategoryCodable>.self, from: data)
                    self.loadCategoryImages(categoriesCodable, self.buildUI)
                } catch {
                    print("error parsing categories")
                }
            } else {
                print("error fetching categories")
            }
        }.resume()
    }
    
    func loadCategoryImages(_ categoriesCodable: [CategoryCodable], _ callback: @escaping (([Category]) -> Void)){
        var categories:[Category] = []
        
        for category in categoriesCodable {
            KingfisherManager.shared.retrieveImage(with: category.ImageUrl) { result in
                do{
                    let image = try result.get().image
                    categories.append(Category(category: category, image: image))
                } catch{
                    print("error fetching image")
                    categories.append(Category(category: category, image: UIImage(systemName: "desktopcomputer")!))
                }
                
                if (categories.count == categoriesCodable.count){
                    callback(categories)
                }
            }
        }
    }
    
    //MARK: - Callbacks
    func buildUI(_ categories:[Category]) {
        DispatchQueue.main.async {
            self.categories = categories
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func anotherCategoryView(_ categories: [Category]){
        DispatchQueue.main.async {
            let loadVC = self.storyBoard.instantiateViewController(withIdentifier: "CategoryList") as! CategoriesViewController
            loadVC.categories = categories
            loadVC.start = false //TODO: Private value constructor
            self.activityIndicator.stopAnimating()
            self.navigationController?.pushViewController(loadVC, animated: true)
        }
    }
}

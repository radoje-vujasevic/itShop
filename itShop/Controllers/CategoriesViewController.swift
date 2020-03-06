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
    var categories:[Category] = []
    var start: Bool = true
    enum NetworkError: Error {
        case url
        case server
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (start) { asyncAll() }
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
            asyncAnotherCategory(clickedCategory)
        } else {
            performSegue(withIdentifier: "segueToItemsList", sender: self) //TODO: Programatically
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if let destinationVC = segue.destination as? ItemListViewController{
                let clickedCategory = categories[indexPath.row]
                if(clickedCategory.childCategories.count == 1){
                    destinationVC.categoryID = clickedCategory.childCategories[0].Id
                }
                else{
                    destinationVC.categoryID = clickedCategory.id
                }
            }
        }
    }
    
    //MARK: - Fetching from API
    func asyncAll(){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.loadCategories()
                .flatMap{self.loadCategoryImages($0)}
            
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    self.categories = data
                    self.tableView.reloadData()
                case let .failure(error):
                    print(error)
                }
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func asyncAnotherCategory(_ clickedCategory:Category){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil) //TODO: Move to didSelectRowAt
        let loadVC = storyBoard.instantiateViewController(withIdentifier: "CategoryList") as! CategoriesViewController
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.loadCategoryImages(clickedCategory.childCategories)
            
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    loadVC.categories = data
                    loadVC.start = false //TODO: Private value constructor
                case let .failure(error):
                    print(error)
                }
                activityIndicator.stopAnimating()
                self.navigationController?.pushViewController(loadVC, animated: true)
            }
        }
    }
    
    func loadCategories() -> Result<[CategoryCodable], Error>{
        let apiURL = "http://digitalvision.rs:8080/articleCategories/?showAll=true"
        guard let url = URL(string: apiURL) else {
            return .failure(NetworkError.url)
        }
        var result: Result<[CategoryCodable], Error>!
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let categories = self.parseJSON(data){
                    result = .success(categories)
                }
            } else {
                result = .failure(NetworkError.server)
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func loadCategoryImages(_ categoriesCodable: [CategoryCodable]) -> Result<[Category], Error>{
        var result: Result<[Category], Error>
        var categories:[Category] = []
        let semaphore = DispatchSemaphore(value: 0)
        
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
                    semaphore.signal()
                }
            }
        }
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        result = .success(categories)
        return result
    }
    
    func parseJSON(_ data: Data) -> Array<CategoryCodable>?{
        let decoder = JSONDecoder()
        do {
            let categoriesCodable = try decoder.decode(Array<CategoryCodable>.self, from: data)
            return categoriesCodable
        } catch {
            print(error)
            return nil
        }
    }
}

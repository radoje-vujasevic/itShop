//
//  ViewController.swift
//  itShop
//
//  Created by Raša on 11/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
import Alamofire

class CategoriesViewController: UITableViewController {
    var categories:[Category] = []
    var categoryImages: [UIImage?] = []
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
        cell.imageView?.image = categoryImages[indexPath.row]
        cell.textLabel?.text = categories[indexPath.row].Name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCategory = categories[indexPath.row]
        if (clickedCategory.ChildsExist && clickedCategory.ChildCategories.count > 1){
            asyncAnotherCategory(clickedCategory)
        } else {
            performSegue(withIdentifier: "segueToItemsList", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // na itemlistvc programski
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
    func asyncAll(){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.loadCategories() // bez flatMapa;
                .flatMap{self.loadCategoryImages($0)}
            
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    do{
                        try self.categoryImages = data.unwrap()
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
    
    func asyncAnotherCategory(_ clickedCategory:Category){
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loadVC = storyBoard.instantiateViewController(withIdentifier: "CategoryList") as! CategoriesViewController
        loadVC.categories = clickedCategory.ChildCategories
        loadVC.start = false //custom constructor sa private vrednostima

        DispatchQueue.global(qos: .utility).async {
            let result = self.loadCategoryImages(clickedCategory.ChildCategories)
            
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    loadVC.categoryImages = data
                case let .failure(error):
                    print(error)
                }
                activityIndicator.stopAnimating()
                self.navigationController?.pushViewController(loadVC, animated: true)
            }
        }
    }
    
//    func fetchImage() -> ([Images]?, Error?) {
//        DispatchQueue.global(qos: .utility).async {
//            let result = self.loadCategoryImages(clickedCategory.ChildCategories)
//
//            DispatchQueue.main.async {
//                switch result {
//                case let .success(data):
//                    return (data, nik)
//                case let .failure(error):
//                    print(error)
//                }
//                activityIndicator.stopAnimating()
//                self.navigationController?.pushViewController(loadVC, animated: true)
//            }
//        }
//    }
    
    func loadCategories() -> Result<[Category]>{
        let apiURL = "http://digitalvision.rs:8080/articleCategories/?showAll=true"
        guard let url = URL(string: apiURL) else {
            return .failure(NetworkError.url)
        }
        var result: Result<[Category]>!
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let categories = self.parseJSON(data){
                    self.categories = categories
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
    
    func loadCategoryImages(_ categories: [Category]) -> Result<[UIImage]>{
        var result:Result<[UIImage]>
        var images:[UIImage] = []
        let semaphore = DispatchSemaphore(value: 0)
        var counter = 0
        
        for category in categories {
            guard let url = URL(string: category.ImageUrl) else {
                return .failure(NetworkError.url)
            }
            
            Alamofire.request(url).response { response in
                if let data = response.data {
                    images.append(UIImage(data: data)!)
                }
                
                if (counter==categories.count-1){
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


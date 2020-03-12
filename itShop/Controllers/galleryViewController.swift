//
//  galleryViewController.swift
//  itShop
//
//  Created by Raša on 11/03/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit

class galleryViewController: UIViewController, UIScrollViewDelegate{
    var item: Item?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate=self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: 350 * CGFloat(item!.images!.count), height: 350)
        for (i, image) in item!.images!.enumerated(){
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 350 * CGFloat(i), y: 0, width: 350, height: 350)
            scrollView.addSubview(imageView)
        }
        
        pageControl.numberOfPages = item!.images!.count
        pageControl.currentPage = 0

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         let pageIndex = round(scrollView.contentOffset.x/350)
         pageControl.currentPage = Int(pageIndex)
     }
}

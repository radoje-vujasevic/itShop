//
//  ItemListViewCellTableViewCell.swift
//  itShop
//
//  Created by Raša on 19/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import UIKit
protocol passName:class {
    func showMessage()
}

class ItemListViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    weak var delegate: passName?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addToCart(_ sender: Any) {
        delegate?.showMessage()
    }
}

//
//  ItemDetailViewController.swift
//  GroceryListManager
//
//  Created by Avinash Dongarwar on 5/22/16.
//  Copyright © 2016 Avinash Dongarwar. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var shoppingItem : ShoppingItem?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var unitPriceLabel : UILabel!
    @IBOutlet weak var quantityLabel : UILabel!
    @IBOutlet weak var unitsLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        imageView!.image = UIImage(named:shoppingItem!.imageName)
        nameLabel.text = shoppingItem?.name
        unitPriceLabel.text = shoppingItem?.unitPrice
        quantityLabel.text = shoppingItem?.quantity
        unitsLabel.text = shoppingItem?.units
        unitsLabel.text = shoppingItem?.itemDescription
        
    }
}

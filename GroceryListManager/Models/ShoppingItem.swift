//
//  ShoppingItem.swift
//  GroceryListManager
//
//  Created by Avinash Dongarwar on 5/22/16.
//  Copyright © 2016 Avinash Dongarwar. All rights reserved.
//

import Foundation

class ShoppingItem : NSObject, NSCoding {
    
    var name: String
    var imageName: String
    var unitPrice: String
    var quantity: String
    var units: String
    var itemDescription: String
    
    
    
    init?(name: String, imageName: String?, unitPrice: String?, quantity: String?, units: String?, itemDescription: String?) {
        
        self.name = name
        self.imageName = imageName!
        self.unitPrice = unitPrice!
        self.quantity = quantity!
        self.units = units!
        self.itemDescription = itemDescription!
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(name, forKey:"name")
        aCoder.encodeObject(imageName, forKey:"imageName")
        aCoder.encodeObject(unitPrice, forKey:"unitPrice")
        aCoder.encodeObject(quantity, forKey:"quantity")
        aCoder.encodeObject(units, forKey:"units")
        aCoder.encodeObject(itemDescription, forKey:"itemDescription")
    }
    
    
    required init (coder aDecoder: NSCoder) {
        
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.imageName = aDecoder.decodeObjectForKey("imageName") as! String
        self.unitPrice = aDecoder.decodeObjectForKey("unitPrice") as! String
        self.quantity = aDecoder.decodeObjectForKey("quantity") as! String
        self.units = aDecoder.decodeObjectForKey("units") as! String
        self.itemDescription = aDecoder.decodeObjectForKey("itemDescription") as! String
    }
}

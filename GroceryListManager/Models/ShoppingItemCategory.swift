//
//  ShoppingItemCategory.swift
//  GroceryListManager
//
//  Created by Avinash Dongarwar on 5/22/16.
//  Copyright © 2016 Avinash Dongarwar. All rights reserved.
//

import Foundation

class ShoppingItemCategory: NSObject, NSCoding {
    
    var categoryName: String
    var shoppingItems: Array<ShoppingItem>
    
    init?(categoryName: String?, shoppingItems: Array<ShoppingItem>?) {
        
        self.categoryName = categoryName!
        self.shoppingItems = shoppingItems!
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(categoryName, forKey:"categoryName")
        aCoder.encodeObject(shoppingItems, forKey:"shoppingItems")
    }
    
    
    required init (coder aDecoder: NSCoder) {
        
        self.categoryName = aDecoder.decodeObjectForKey("categoryName") as! String
        self.shoppingItems = aDecoder.decodeObjectForKey("shoppingItems") as! Array<ShoppingItem>
    }
    
}
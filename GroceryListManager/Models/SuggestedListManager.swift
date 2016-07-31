//
//  SuggestedListManager.swift
//  GroceryListManager
//
//  Created by Avinash Dongarwar on 5/22/16.
//  Copyright © 2016 Avinash Dongarwar. All rights reserved.
//

import Foundation

class SuggestedListManager {
    
    static let PATH_TO_DATA_FILE: String =  "/DataFile.json"
    
    private class func createShoppingList() -> Array<ShoppingItem> {
        
        return [ShoppingItem(name: "Cookies", imageName: "Cookie", unitPrice: "$2.95", quantity: "1", units: "13.3 oz", itemDescription: "Chocolate")!,
            ShoppingItem(name: "Black Berries", imageName: "BlackBerries", unitPrice: "$2.93", quantity: "1", units: "", itemDescription: "Organic")!,
            ShoppingItem(name: "Apples", imageName: "Apple", unitPrice: "$1.01", quantity: "1", units: "1 lb", itemDescription: "Organic")!,
            ShoppingItem(name: "Blue Berries", imageName: "BlueBerries", unitPrice: "$4.95", quantity: "1", units: "1 lb", itemDescription: "Organic")!,
            ShoppingItem(name: "Steak", imageName: "Steak", unitPrice: "$11.99", quantity: "1", units: "1 lb", itemDescription: "T-Bone")!,
            ShoppingItem(name: "Bread", imageName: "Bread", unitPrice: "$3.99", quantity: "1", units: "", itemDescription: "Organic")!,
            ShoppingItem(name: "Orange Juice", imageName: "OrangeJuice", unitPrice: "$5.00", quantity: "1", units: "12 oz", itemDescription: "Organic")!,
            ShoppingItem(name: "Bananas", imageName: "Banana", unitPrice: "$0.99", quantity: "1", units: "1 lb", itemDescription: "Organic")!,
            ShoppingItem(name: "Cantaloupe", imageName: "Canteloupe", unitPrice: "$0.63", quantity: "1", units: "1 lb", itemDescription: "Organic")!,
            ShoppingItem(name: "Cheerios", imageName: "Cheerios", unitPrice: "$3.13", quantity: "1", units: "12 oz", itemDescription: "Gluten Free")!,
            ShoppingItem(name: "Turkey", imageName: "Turkey", unitPrice: "$23.04", quantity: "1", units: "16 lb", itemDescription: "Fresh")!,
            ShoppingItem(name: "Dates", imageName: "Dates", unitPrice: "$3.49", quantity: "1", units: "1 lb", itemDescription: "Organic")!,
            ShoppingItem(name: "Dragon Fruit", imageName: "Dragonfruit", unitPrice: "$7.34", quantity: "1", units: "3 oz", itemDescription: "Organic")!,
            ShoppingItem(name: "Figs", imageName: "Fig", unitPrice: "$4.09", quantity: "1", units: "5 oz", itemDescription: "Organic")!,
            ShoppingItem(name: "Ground Beef", imageName: "GroundBeef", unitPrice: "$7.49", quantity: "1", units: "1 lb", itemDescription: "Fresh")!,
           ShoppingItem(name: "Hot Dog Buns", imageName: "Hotdogbun", unitPrice: "$3.29", quantity: "1", units: "8 ct", itemDescription: "Enriched Buns")!,
           ShoppingItem(name: "Eggs", imageName: "Eggs", unitPrice: "$7.49", quantity: "1", units: "1 dozen", itemDescription: "Organic")!,
           ShoppingItem(name: "Peaches", imageName: "Peach", unitPrice: "$7.49", quantity: "1", units: "3 lb", itemDescription: "Organic")!,
           ShoppingItem(name: "Oranges", imageName: "Orange", unitPrice: "$5.49", quantity: "1", units: "12 ct", itemDescription: "Organic")!,
           ShoppingItem(name: "Mineral Water", imageName: "MineralWater", unitPrice: "$5.00", quantity: "1", units: "12 ct", itemDescription: "Sparkling Mineral Water")!,
           ShoppingItem(name: "Rice Krispies", imageName: "Rice_krispies", unitPrice: "$3.38", quantity: "1", units: "18 oz", itemDescription: "Kelloggs")!]
        
    }
    
    
    class func getData (onSuccess: Array<ShoppingItemCategory> -> Void, onError: (NSError?) -> Void) ->() {
        
        let fileManager = (NSFileManager.defaultManager())
        let filePath = SuggestedListManager.getPathToDataFile()
        
        if (fileManager.fileExistsAtPath(filePath))
        {
            if let tempArr: [ShoppingItemCategory] = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [ShoppingItemCategory] {
                onSuccess(tempArr)
            }
        }
        else
        {
            let shoppingItemArr : Array<ShoppingItem> = createShoppingList()
            
            let shoppingItemCatArr : Array<ShoppingItemCategory> =
            [ShoppingItemCategory (categoryName: "",
                shoppingItems: shoppingItemArr)!]
            
            onSuccess(shoppingItemCatArr)
            
            writeArrayToFile(shoppingItemCatArr)
        }
    }
    
    
    class func writeArrayToFile (shoppingItems: Array<ShoppingItemCategory>) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            
            NSKeyedArchiver.archiveRootObject(shoppingItems, toFile: SuggestedListManager.getPathToDataFile())
        })
    }
    
    
    class func getPathToDataFile () -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true)
        let path: AnyObject = paths[0]
        
        return path.stringByAppendingString(PATH_TO_DATA_FILE)
        
    }
    
}
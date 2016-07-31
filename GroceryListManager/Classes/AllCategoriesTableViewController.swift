//
//  AllCategoriesTableViewController.swift
//  GroceryListManager
//
//  Created by Avinash Dongarwar on 5/22/16.
//  Copyright © 2016 Avinash Dongarwar. All rights reserved.
//

import UIKit

class AllCategoriesTableViewController: UITableViewController {
    
    private let cellIdentifier = "cell"
    
    var categories : [String]?
    
    var selectedCategory:String? {
        didSet {
            if let category = selectedCategory {
                selectedCategoryIndex = categories!.indexOf(category)!
            }
        }
    }
    
    var selectedCategoryIndex:Int?
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = categories![indexPath.row]
        
        guard indexPath.row == selectedCategoryIndex else {
            cell.accessoryType = .None
            return cell
        }

        cell.accessoryType = .Checkmark
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let index = selectedCategoryIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        selectedCategory = categories![indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
}

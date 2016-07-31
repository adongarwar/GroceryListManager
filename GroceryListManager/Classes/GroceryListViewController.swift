//
//  GroceryListViewController.swift
//  GroceryListManager
//
//  Created by Avinash Dongarwar on 5/22/16.
//  Copyright © 2016 Avinash Dongarwar. All rights reserved.
//

import UIKit

class GroceryListViewController: UIViewController {
    
    private let cellIdentifier = "cell"
    
    weak var AddAlertSaveAction: UIAlertAction?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCategoryButton : UIBarButtonItem!
    @IBOutlet weak var existingCategoryButton: UIBarButtonItem!
    @IBOutlet weak var removeCategoryButton: UIBarButtonItem!
    
    var shoppingItemCategoryList: [ShoppingItemCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableDisableButtons(false)
        self.prepareData()
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(GroceryListViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
    }

    
    // MARK: - actions
    
    @IBAction func sortButtonClicked(sender: UIBarButtonItem) {
        
        self.shoppingItemCategoryList.sortInPlace { $0.categoryName < $1.categoryName }
        
        for (_, shoppingItemCat) in self.shoppingItemCategoryList.enumerate () {
            
            shoppingItemCat.shoppingItems.sortInPlace { $0.name < $1.name }
        }
        
        SuggestedListManager.writeArrayToFile(shoppingItemCategoryList)
        
        self.tableView.reloadData()
    }
    
    
    @IBAction func categorizeButtonClicked(sender: UIBarButtonItem) {
        
        self.tableView.setEditing(true, animated: true)
        
        self.navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: #selector(GroceryListViewController.cancelButtonClicked(_:)))
    }
    
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Categorize", style: UIBarButtonItemStyle.Done, target: self, action: #selector(GroceryListViewController.categorizeButtonClicked(_:)))
    }
    
    
    @IBAction func addItemToNewCategory(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(
            title: "Add new Category",
            message: "Please enter new category name for selected items.",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (txtcategoryName) -> Void in
            
            txtcategoryName.placeholder = "Enter new category name."
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GroceryListViewController.handleTextFieldTextDidChangeNotification(_:)), name: UITextFieldTextDidChangeNotification, object: txtcategoryName)
        }
        
        
        func removeTextFieldObserver() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alertController.textFields![0])
        }
        
        
        let addAction = UIAlertAction(title: "Add",
            style: UIAlertActionStyle.Default,
            handler: {[weak self]
                (paramAction:UIAlertAction!) in
                
                if let strongSelf = self {
                    
                    removeTextFieldObserver()
                    let firstTextField = alertController.textFields![0] as UITextField
                    
                    strongSelf.createNewCategory(firstTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                    
                }
            })
        
        
        addAction.enabled = false
        AddAlertSaveAction = addAction
        
        let cancelAction = UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.Default) {
                (action) -> Void in
                
                removeTextFieldObserver()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func removeItemsFromCategory(sender: UIBarButtonItem) {
        
        let shoppingCat = categoryForName("")
        addSelectedItemsToCategory(shoppingCat!)
    }
    
    
    
    
    @IBAction func itemSelected(sender: AnyObject) {

        if self.tableView.editing == false {
            performSegueWithIdentifier("showDetail", sender: sender.view)
        }
    }
    
    
    // MARK: - Notification handlers
    
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        
        let textField = notification.object as! UITextField
        AddAlertSaveAction!.enabled = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count >= 1
    }
    
    
    // MARK: - Data Processing
    
    private func prepareData ()
    {
        SuggestedListManager.getData({[weak self] (shoppingItemCategories) -> Void in
            
            if let strongSelf = self {
                strongSelf.shoppingItemCategoryList = shoppingItemCategories
            }
            }, onError:{(error)  in
                
        })
    }
    
    
    private func createNewCategory(categoryName: String)
    {
        if (!self.validateCategoryEntry(categoryName)) {return}
        
        let tempItems: Array<ShoppingItem> = []
        let shoppingCat = ShoppingItemCategory (categoryName: categoryName, shoppingItems: tempItems)
        shoppingItemCategoryList.append(shoppingCat!)
        
        addSelectedItemsToCategory(shoppingCat!)
    }
    
    
    private func addToExistingCategory(categoryName: String)
    {
        let shoppingCat = categoryForName(categoryName)
        addSelectedItemsToCategory(shoppingCat!)
    }
    
    
    
    private func addSelectedItemsToCategory(category: ShoppingItemCategory)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self]() -> Void in
            
            if let strongSelf = self {
                
                if let paths: [NSIndexPath] = strongSelf.tableView.indexPathsForSelectedRows! {
                    
                    let sortedArray = paths.sort({$0.row > $1.row})
                    
                    var tempItems: Array<ShoppingItem> = []
                    
                    for i in sortedArray {
                        let shoppingCat = strongSelf.shoppingItemCategoryList[i.section]
                        let shoppingItem = shoppingCat.shoppingItems[i.row]
                        shoppingCat.shoppingItems.removeAtIndex(i.row)
                        tempItems.append(shoppingItem)
                    }
                    
                    category.shoppingItems.appendContentsOf(tempItems.reverse())
                    
                    strongSelf.shoppingItemCategoryList = strongSelf.shoppingItemCategoryList.filter() { $0.shoppingItems.count > 0 }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    strongSelf.navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Categorize", style: UIBarButtonItemStyle.Done, target: self, action: #selector(GroceryListViewController.categorizeButtonClicked(_:)))
                    strongSelf.tableView.setEditing(false, animated: true)
                    strongSelf.tableView.reloadData()
                    strongSelf.enableDisableButtons(false)
                    
                    SuggestedListManager.writeArrayToFile(strongSelf.shoppingItemCategoryList)
                })
                
            }
            
            })
    }
    
    
    private func allCategories() -> [String]
    {
        let arr = shoppingItemCategoryList.map { $0.categoryName }
        
        return arr.filter() { $0 != "" }
    }
    
    
    private func categoryForName(categoryName: String) -> ShoppingItemCategory?
    {
        let arr:[ShoppingItemCategory] = shoppingItemCategoryList.filter() { $0.categoryName == categoryName }
        
        if (arr.count > 0) {return arr[0]}
        
        return nil
    }
    
    
    // MARK: - Validators
    
    private func validateCategoryEntry(categoryName: String) -> Bool {
        
        if (allCategories().contains(categoryName)) {
            
            let alertController = UIAlertController(title: "Category already exists.", message:
                "Please enter a different category name.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    private func validateCategoryCount () -> Bool {
        
        if (allCategories().count <= 0) {
            
            let alertController = UIAlertController(title: "No Existing Categories.", message:
                "Please create and add items to it using + New Category.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    // Mark: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showCategories" {
            
            if (!validateCategoryCount()) {return}
            
            if let navController = segue.destinationViewController as? UINavigationController {
                
                if let allCategoriesTableViewController = navController.viewControllers[0] as? AllCategoriesTableViewController {
                    
                    allCategoriesTableViewController.categories = allCategories()
                }
            }
        }
        else if segue.identifier == "showDetail" {
            
            if let navController = segue.destinationViewController as? UINavigationController {
                
                if let detailViewController = navController.viewControllers[0] as? ItemDetailViewController {
                    
                    let cell = sender as! UITableViewCell
                    let path = tableView.indexPathForCell(cell)! as NSIndexPath
                    let shoppingCat = shoppingItemCategoryList[path.section]
                    let shoppingItem = shoppingCat.shoppingItems[path.row]
                    
                    detailViewController.shoppingItem = shoppingItem
                }
            }
            
        }
        
    }
    
    
    
    // Mark: - Unwind Segues
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveItemsToExistingCategory(segue:UIStoryboardSegue) {
        
        if let allCategoriesTableViewController = segue.sourceViewController as? AllCategoriesTableViewController {
            
            if let category = allCategoriesTableViewController.selectedCategory {
                addToExistingCategory(category)
            }
        }
    }
    
    
    // Mark: - Convinience functions/ Utilities
    
    private func areButtonsEnabled() -> Bool {
        
        return newCategoryButton.enabled && existingCategoryButton.enabled && removeCategoryButton.enabled
    }
    
    
    private func enableDisableButtons(enable: Bool)  {
        
        newCategoryButton.enabled = enable
        existingCategoryButton.enabled = enable
        removeCategoryButton.enabled = enable
    }
}


extension GroceryListViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return shoppingItemCategoryList.count
    }



    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String? {

        guard self.shoppingItemCategoryList.count > 0 else {
            print("Data not ready yet")
            return ""
        }

        let shoppingItemCategory = self.shoppingItemCategoryList[section]
        return shoppingItemCategory.categoryName
    }



    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard shoppingItemCategoryList.count > 0 else {
            print("Data not ready yet")
            return 0
        }

        return shoppingItemCategoryList[section].shoppingItems.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)

        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            let shoppingItemCategory = self.shoppingItemCategoryList[indexPath.section]
            let shoppingItem = shoppingItemCategory.shoppingItems[indexPath.row]

            cell.textLabel!.text = shoppingItem.name
            cell.detailTextLabel!.text = shoppingItem.unitPrice
            cell.imageView!.image = UIImage(named:shoppingItem.imageName)

            let aSelector : Selector = #selector(GroceryListViewController.itemSelected(_:))
            let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
            tapGesture.cancelsTouchesInView = false
            cell.addGestureRecognizer(tapGesture)
        })

        return cell
    }

    // MARK: - Table view delegates

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        guard tableView.indexPathsForSelectedRows?.count > 0 && !areButtonsEnabled() else { return }
        enableDisableButtons(true)
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {

        guard tableView.indexPathsForSelectedRows?.count == nil && areButtonsEnabled() else { return }
        enableDisableButtons(false)
    }
}


extension GroceryListViewController {



    // MARK: - Drag n Drop

    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(locationInView)

        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }

        switch state {
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(cell)

                var center = cell.center
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)

                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        if finished {
                            My.cellIsAnimating = false
                            if My.cellNeedToShow {
                                My.cellNeedToShow = false
                                UIView.animateWithDuration(0.25, animations: { () -> Void in
                                    cell.alpha = 1
                                })
                            } else {
                                cell.hidden = true
                            }
                        }
                })
            }

        case UIGestureRecognizerState.Changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center

                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {

                    let shoppingCat = self.shoppingItemCategoryList[Path.initialIndexPath!.section]
                    let shoppingItem = shoppingCat.shoppingItems[Path.initialIndexPath!.row]

                    shoppingCat.shoppingItems.removeAtIndex(Path.initialIndexPath!.row)

                    let newShoppingCat = self.shoppingItemCategoryList[indexPath!.section]
                    newShoppingCat.shoppingItems.insert(shoppingItem, atIndex: indexPath!.row)

                    SuggestedListManager.writeArrayToFile(shoppingItemCategoryList)

                    tableView.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                    Path.initialIndexPath = indexPath
                }
            }
        default:
            if Path.initialIndexPath != nil {
                let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.hidden = false
                    cell.alpha = 0.0
                }

                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransformIdentity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0

                    }, completion: { (finished) -> Void in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                        }
                })
            }
        }
    }


    private func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()

        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

}

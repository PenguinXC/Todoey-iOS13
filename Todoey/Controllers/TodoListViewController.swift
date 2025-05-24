//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var todoItems : Results<Item>?
    
    let realm = try! Realm(configuration: AppDelegate.config)
    
    var selectedCategory: Category? {
        // Everything inside didSet will be executed when the selectedCategory is set with a new value
        didSet {
            // Load the items from database when the selected category is set
            // We only call the loadItems method here, because it is certain that the selectedCategory is set before this method is called
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // '/Users/vuna/Library/Developer/CoreSimulator/Devices/B25FD894-26DD-467E-A9B2-0BD44E97C99B/data/Containers/Data/Application/31DF81FC-B8A9-4EF5-A6E2-BC8E44D1ABDD/Library/Application Support/DataModel.sqlite'
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if todoItems is nil, return 1. 1 is used to show 1 row with the alert "No Items Added Yet"
        return todoItems?.count ?? 1
    }
    
    // This method is called when the table view needs a cell to display
    // This method is called initially when the table view is loaded, or when the table view is reloaded
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        debugPrint("cellForRowAt indexPath \(indexPath)")
        
        // Create a new cell with prototype cell identifier "ToDoItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // Get the item from the itemArray at the current indexPath
        if let item = todoItems?[indexPath.row] {
            // Configure the cell with the item from the itemArray at the current indexPath
            cell.textLabel?.text = item.title
            
            // Check if the item is marked as done and set the accessory type accordingly
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            // If there are no items, show a default message
            cell.textLabel?.text = "No Items Added Yet"
        }
        
        
        // Return the configured cell
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // We are checking to see if the todoItems array is not nil and if there is an item at the selected indexPath
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    // Toggle the done property of the item
                    // item.done.toggle()
                    item.done = !item.done
                    // This will delete the item from the database
                    // realm.delete(item)
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        // This will call the cellForRowAt method again to update the cell
        tableView.reloadData()
        
        // Deselect (remove highlight) the cell after a short delay
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // User input will be taken from the alertTextField, but since we need to access it outside the closure, we need to declare another variable (textField) outside the closure
        var textField = UITextField()
        
        // UIAlertController will be used to display an alert with a text field for the user to enter a new item
        // This code designs the alert
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        // The code of this action will be executed when the user clicks the button on our alert
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // We need to check if the selectedCategory is not nil and if it is not nil we assign it to currentCategory
            if let currentCategory = self.selectedCategory {
                // If the selectedCategory is not nil, we can create a new item
                // We are creating a new item inside realm write transaction, it will be saved into the database when the transaction is committed
                do {
                    try self.realm.write {
                        // Create a new item and set its title to the text entered in the text field
                        let newItem = Item()
                        newItem.title = textField.text!
                        // newItem.done = false does not need to be set, because it is already set to false by default
                        // Set the parentCategory of the new item to the selectedCategory
                        
                        // Set the dateCreated property to the current date
                        newItem.dateCreated = Date()
                        // This is not necessary, because the parentCategory is set automatically when we append the new item to the items array of the selectedCategory
                        currentCategory.items.append(newItem)
                        // When you append newItem to currentCategory.items, Realm automatically manages the new item since currentCategory is already persisted in the Realm database. The explicit self.realm.add(newItem) call is redundant and can be removed.
                        // The bidirectional relationship is properly maintained when you add the item to the category's items list - the parentCategory property of the item will automatically reference the category.
                        // self.realm.add(newItem)
                    }
                } catch {
                    print("Error saving new item, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            // Thí placeholder will be displayed in gray in the text field
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
            debugPrint(alertTextField.text!)
            debugPrint("Now")
        }
        
        // Add the "Add Item" button to the alert, defined by the action above
        alert.addAction(action)
        
        // present the alert to the user
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manipulation Methods
    
    fileprivate func loadItems() {
        
        // Create a fetch request for the Item object
        // This will fetch all items that belong to the selected category and sort them by title in ascending order
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}

// MARK: - Search Bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // When the search button is clicked, we filter the todoItems based on the search text
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If the search text is empty, reload the original data
        if searchBar.text?.count == 0 {
            loadItems()

            // DispatchQueue is like a manager that assigns tasks to different threads
            // Calling DispatchQueue.main.async to ensure that the UI updates are performed on the main thread
            // UI updates should always be done on the main thread
            DispatchQueue.main.async {
                // This will make the search bar resign first responder status and dismiss the keyboard
                // The first responder is the object that is currently receiving input events (is the active text field)
                searchBar.resignFirstResponder()
            }
        }
    }
}

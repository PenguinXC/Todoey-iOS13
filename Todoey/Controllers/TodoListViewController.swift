//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    // var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s"]
    var itemArray = [Item]()
    // UIApplication.shared is a singleton object that represents the current application
    // UIApplication.shared.delegate is used to access the app delegate,
    // which is a singleton object that manages the app's lifecycle and shared resources
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // '/Users/vuna/Library/Developer/CoreSimulator/Devices/B25FD894-26DD-467E-A9B2-0BD44E97C99B/data/Containers/Data/Application/31DF81FC-B8A9-4EF5-A6E2-BC8E44D1ABDD/Library/Application Support/DataModel.sqlite'
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Load the items from database when start the app to populate the itemArray
        loadItems()
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // This method is called when the table view needs a cell to display
    // This method is called initially when the table view is loaded, or when the table view is reloaded
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        debugPrint("cellForRowAt indexPath \(indexPath)")
        
        // Create a new cell with prototype cell identifier "ToDoItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        // Configure the cell with the item from the itemArray at the current indexPath
        cell.textLabel?.text = item.title
        
        // Check if the item is marked as done and set the accessory type accordingly
        cell.accessoryType = item.done ? .checkmark : .none
        
        // Return the configured cell
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        // Order matters, so we need to set the done property first
        // We need to delete the item from the database first
        // context.delete(itemArray[indexPath.row])
        // then remove it from the array
        // itemArray.remove(at: indexPath.row)
        
        // Save the updated item to the database
        saveItems()
        
        // Deselect (remove highlight) the cell after a short delay
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // The idea is for this textField to be displayed in the alert
        var textField = UITextField()
        
        // UIAlertController will be used to display an alert with a text field for the user to enter a new item
        // This code designs the alert
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the Add Item button on our
            
            // We are creating a new item inside the context, it is not saved into the database yet
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            // Reload the table view to display the new item
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            // Thí placeholder will be displayed in gray in the text field
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
            print(alertTextField.text!)
            print("Now")
        }
        
        // Add the "Add Item" button to the alert
        alert.addAction(action)
        
        // present the alert to the user
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manipulation Methods
    fileprivate func saveItems() {
        
        do {
            // Saving the context will save the new item to the database
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    fileprivate func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        // The request for the Item entity is used as a parameter, it is a prototype of what the data will look like
        
        do {
            // The fetch request is used to retrieve data from the persistent store when calling the fetch method on the context like below
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - Search Bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // This method is called when the user clicks the search button on the keyboard
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        // The predicate is used to filter the data based on the search text
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // The sort descriptor is used to sort the data based on the title property
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
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

//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    // var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s"]
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Find Mike"
        newItem.done = true
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)

        let newItem3 = Item()
        newItem3.title = "Destroy Demogorgon"
        itemArray.append(newItem3)
        
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)
        itemArray.append(newItem3)

//        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
//            itemArray = items
//        }
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
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            // If the cell is already checked, uncheck it
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            // If the cell is not checked, check it
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData()
        
        // Deselect (remove highlight) the cell after a short delay
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // The idea is for this textField to be displayed in the alert
        var textField = UITextField()
        
        // UIAlertController will be used to display an alert with a text field for the user to enter a new item
        // This code designs the alert
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
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
}

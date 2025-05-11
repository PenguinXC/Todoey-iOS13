//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
            itemArray = items
        }
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // this method is called when the table view needs a cell to display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a new cell with prototype cell identifier "ToDoItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // Configure the cell with the item from the itemArray at the current indexPath
        cell.textLabel?.text = itemArray[indexPath.row]
        
        // Return the configured cell
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            // If the cell is already checked, uncheck it
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            // If the cell is not checked, check it
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        // Deselect the cell after a short delay
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
            self.itemArray.append(textField.text!)
            
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

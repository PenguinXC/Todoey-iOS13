//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
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
    
}


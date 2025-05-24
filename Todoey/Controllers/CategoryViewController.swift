//
//  CategoryViewController.swift
//  Todoey
//
//  Created by VuNA on 18/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    var categories : Results<Category>?
    
    // The first time when you create the realm instance, it can fail if the resource is not available
    // In practice, failing to create a realm instance only happens at the first time
    let realm = try! Realm(configuration: AppDelegate.config)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [file:///Users/vuna/Library/Developer/CoreSimulator/Devices/B25FD894-26DD-467E-A9B2-0BD44E97C99B/data/Containers/Data/Application/B2C0EF36-9138-480C-890E-5D3B17A22BF0/Documents/]
        
        loadCategories()
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If categories is nil, return 1 to show a message "No Categories Added Yet"
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        debugPrint("cellForRowAt indexPath \(indexPath)")
        
        // Create a new cell with prototype cell identifier "CategoryCell"
        // dequeueReusableCell means to reuse a cell that is no longer visible
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Configure the cell with the category from the categoryArray at the current indexPath
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        
        // Return the configured cell
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            // We call realm.write to start a write transaction
            try realm.write {
                // Add the new category to the realm database, the transaction will be committed automatically
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        // Fetch all categories from the Realm database
        categories = realm.objects(Category.self)
        
        // Reloading the table view will call all the datasource methods again, including cellForRowAt indexPath and numberOfRowsInSection
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // MARK: - TableView Delegate Methods
    
    // This method is called when the user selects a row in the table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Perform a segue to the TodoListViewController
        // This call to `performSegue` will trigger perform after the prepare(for segue:sender:) method is called
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! TodoListViewController
        
        // We are passing the selected category (categories?[indexPath.row]) to the TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // User input will be taken from the alertTextField, but since we need to access it outside the closure, we need to declare another variable (textField) outside the closure
        var textField = UITextField()
        
        // UIAlertController will be used to display an alert with a text field for the user to enter a new category
        // This code designs the alert
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // The code of this action will be executed when the user clicks the Add Category button on our alert
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // We are creating a new category inside the context, it is not saved into the database yet
            let newCategory = Category()
            newCategory.name = textField.text!
            
            // Because categories is a Results object, and Results is a auto-updating container,
            // we do not need to update the categories array manually
            
            // Save the new category to the database
            self.save(category: newCategory)
        }
        
        // Add a text field to the alert
        alert.addTextField { (alertTextField) in
            // This placeholder will be displayed in gray in the text field
            alertTextField.placeholder = "Add a new category"
            // Assign the text field to the variable textField
            // The difference between textField and field is that
            // field is a local variable inside the closure
            // and textField is a variable declared outside the closure
            // So we can use textField outside the closure
            textField = alertTextField
        }
        
        // Add the "Add Category" button to the alert, defined by the action above
        alert.addAction(action)
        
        // Present the alert to the user
        present(alert, animated: true, completion: nil)
        
    }
    
}

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
    
    var categories = [Category]()
    
    // Keep CoreData context for backward compatibility
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Use RealmManager to get a Realm instance
    let realm = RealmManager.getRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [file:///Users/vuna/Library/Developer/CoreSimulator/Devices/B25FD894-26DD-467E-A9B2-0BD44E97C99B/data/Containers/Data/Application/B2C0EF36-9138-480C-890E-5D3B17A22BF0/Documents/]
        debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        debugPrint("cellForRowAt indexPath \(indexPath)")
        
        // Create a new cell with prototype cell identifier "CategoryCell"
        // dequeueReusableCell means to reuse a cell that is no longer visible
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Configure the cell with the category from the categoryArray at the current indexPath
        cell.textLabel?.text = categories[indexPath.row].name
        
        // Return the configured cell
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        // Use RealmManager's save method
        RealmManager.shared.save(category)
        tableView.reloadData()
    }
    
    func loadCategories() {
        // Use RealmManager to fetch all categories
        if let results = RealmManager.shared.fetchAll(Category.self) {
            // Convert Results<Category> to [Category] array
            categories = Array(results)
            tableView.reloadData()
        }
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        // UIAlertController will be used to display an alert with a text field for the user to enter a new category
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // The code of this action will be executed when the user clicks the Add Category button on our alert
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            
            // Save the new category to the database using RealmManager
            self.save(category: newCategory)
        }
        
        // Add a text field to the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
        }
        
        // Add the "Add Category" button to the alert, defined by the action above
        alert.addAction(action)
        
        // Present the alert to the user
        present(alert, animated: true, completion: nil)
    }
}
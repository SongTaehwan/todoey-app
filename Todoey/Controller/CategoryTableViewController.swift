//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by 송태환 on 2020/03/13.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift


class CategoryTableViewController: UITableViewController {
    let realm = try! Realm()

    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        tableView.rowHeight = 80.0
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self

        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
        }

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destination = segue.destination as! TableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            destination.selectedCategory = categoryArray?[indexPath.row]
        }
    }

    // MARK: - Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
    
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Type New Category"
        }
    
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "", let name = textField.text {

                // Create Data
                let newCategory = Category() // Realm Data Model
                newCategory.setValue(name, forKey: "name")
                
                self.save(category: newCategory)
            }
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: {() in
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertDismiss)))
        })
    }
    
    @objc func alertDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Core Data method
    func loadCategories() {
        // Pull out data from Realm
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }

    func save(category: Category) {
        do {
            // Save Realm data
            try realm.write({ () in
                realm.add(category)
            })
            tableView.reloadData()
        } catch  {
            print(error)
        }
    }
}

// MARK: - SwipCellDelegate Methods
extension CategoryTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            let target = self.categoryArray![indexPath.row]
            do {
                try self.realm.write { () in
                    self.realm.delete(target)
                }
            } catch {
                print(error)
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        
        return options
    }
}

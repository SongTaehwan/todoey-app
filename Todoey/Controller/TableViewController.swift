//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    var itemArray = [Todo]()
    var selectedCategory: Category? {
        // call loadTodos as soon as selectedCategory assigned from prev screen
        didSet {
            loadTodos()
        }
    }

    // get DB instance
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        
        let todo = itemArray[indexPath.row]
        
        // after reload from TableView Delegate Methods, done state will apply to UI
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.done ? .checkmark : .none

        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = itemArray[indexPath.row]

        // clicked -> change done state
//        todo.done = !todo.done
        // MARK: - CoreData Update
        todo.setValue(!todo.done, forKey: "done")
        
        saveTodo()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen once user clicks the Add Item button on Alert
            // MARK: - CoreData Create
            let newItem = Todo(context: self.context)
//            newItem.title = textField.text!
            newItem.setValue(textField.text!, forKey: "title")
            // 그대로 넣음
            newItem.setValue(self.selectedCategory, forKey: "parentCategory")

            self.itemArray.append(newItem)

            self.saveTodo()
        }
        
        // MARK: - Callback triggers once TextField created
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Create Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    func saveTodo() -> Void {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func loadTodos(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSPredicate? = nil) -> Void {
        // Core Data - READ
        // blow lines of code work the same
//        let categoryPredicate = NSPredicate(format: "parentCategory == %@", selectedCategory!)
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        do {
            if let addditionalPredicate = predicate {
                let compoundPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addditionalPredicate])
                request.predicate = compoundPredicates
            } else {
                request.predicate = categoryPredicate
            }

            itemArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}

// MARK: - UISearchBarDelegate
extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Create request instance
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()

        // Add Query
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate

        // Add sort conditions which can be multiple condition
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        loadTodos(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadTodos()
            
            // UI changes should be running on Main thread even though background thread is completed
            DispatchQueue.main.async {
                // get searchBar back to origin state (no keyboard popup and cursor blink)
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

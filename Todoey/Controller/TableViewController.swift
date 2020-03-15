//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TableViewController: UITableViewController {
    let realm = try! Realm()
    var todoItems: Results<Todo>?
    var selectedCategory: Category? {
        // call loadTodos as soon as selectedCategory assigned from prev screen
        didSet {
            
            loadTodos()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let todo = todoItems?[indexPath.row] {
            // after reload from TableView Delegate Methods, done state will apply to UI
            cell.textLabel?.text = todo.title
            cell.accessoryType = todo.done ? .checkmark : .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let todo = todoItems?[indexPath.row] {
            do {
                try realm.write({ () in
                    todo.done = !todo.done
                })
            } catch  {
                print(error)
            }
        }

        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if textField.text != "", let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write({ () in
                        let newItem = Todo()
                        newItem.setValue(textField.text!, forKey: "title")
                        newItem.setValue(Date(), forKey: "createdAt")
                        currentCategory.items.append(newItem)
                    })
                } catch  {
                    print(error)
                }
            }
            
            self.tableView.reloadData()
        }
        
        // MARK: - Callback triggers once TextField created
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Create Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: {() in
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertDismiss)))
        })
    }
    
    @objc func alertDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    func loadTodos() -> Void {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "createdAt", ascending: true)
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdAt", ascending: true)
        tableView.reloadData()
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

extension TableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            let target = self.todoItems![indexPath.row]
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

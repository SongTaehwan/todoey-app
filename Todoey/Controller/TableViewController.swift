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
import ChameleonFramework

class TableViewController: SwipeTableViewController {
    let realm = try! Realm()
    var todoItems: Results<Todo>?
    var selectedCategory: Category? {
        // call loadTodos as soon as selectedCategory assigned from prev screen
        didSet {
            loadTodos()
        }
    }

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let safeCategory = selectedCategory {
            title = safeCategory.name
            guard let colour = UIColor(hexString: safeCategory.colour) else { fatalError() }
            updateNavBarColor(colour)
            searchBar.barTintColor = colour
            searchBar.searchTextField.backgroundColor = FlatWhite()
        }
        
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let todo = todoItems?[indexPath.row] {
            // after reload from TableView Delegate Methods, done state will apply to UI
            cell.textLabel?.text = todo.title
            cell.accessoryType = todo.done ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }

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
                        newItem.setValue(UIColor.randomFlat().hexValue(), forKey: "colour")
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
    
    // MARK: - Deletion
    override func updateOnSwipe(at indexPath: IndexPath) {
        let target = self.todoItems![indexPath.row]
        do {
            try self.realm.write { () in
                self.realm.delete(target)
            }
        } catch {
            print(error)
        }
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

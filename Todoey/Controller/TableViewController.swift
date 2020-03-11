//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    // CAN NOT Store Custom data or Object, will throw non-property list erorr
//    let defaults = UserDefaults()
    
    // init with type
    var itemArray = [Todo]()
    
    // Create Custom plist
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Todo.plist")

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTodos()
//        if let array = defaults.array(forKey: "TodoList") as? [Todo] {
//            itemArray = array
//        }
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
        todo.done = !todo.done
        
        saveTodo()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen once user clicks the Add Item button on Alert
            let newItem = Todo()
            newItem.title = textField.text!
            self.itemArray.append(newItem)

            self.saveTodo()
            
            // store data like AsyncStorage
            // DO NOT Store Object or Custom data in UserDefaults, it will crash app and it's desgined to store a small piece of data
//            self.defaults.set(self.itemArray, forKey: "TodoList")

    
        }
        
        // MARK: - Callback triggers once TextField created
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Create Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveTodo() -> Void {
        let encoder = PropertyListEncoder()

        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
            
            // reload for UI
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func loadTodos() -> Void {
        // option 1
//        do {
//            let data = try Data(contentsOf: dataFilePath!)
//            let decoder = PropertyListDecoder()
//            itemArray = try decoder.decode([Todo].self, from: data)
//        } catch {
//            print(error)
//        }
        
        // option 2
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Todo].self, from: data)
            } catch {
                print(error)
            }
        }
    }
}


//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by 송태환 on 2020/03/13.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destination = segue.destination as! TableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            destination.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    // MARK: - Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField?
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
    
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField?.placeholder = "Type New Category"
        }
    
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = textField?.text {
                let newCategory = Category(context: self.context)
                newCategory.setValue(name, forKey: "name")
                self.categoryArray.append(newCategory)
                
                self.saveCategory()
            }
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data method
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
            tableView.reloadData()
        } catch  {
            print(error)
        }
    }

    func saveCategory() {
        do {
            try context.save()
            tableView.reloadData()
        } catch  {
            print(error)
        }
    }
}

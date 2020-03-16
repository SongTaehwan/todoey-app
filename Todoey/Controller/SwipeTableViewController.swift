//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by 송태환 on 2020/03/16.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateOnSwipe(at: indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructiveAfterFill
        
        return options
    }
    
    func updateOnSwipe(at indexPath: IndexPath) {
        print("Delete")
    }
    
    func updateNavBarColor(_ backgroundColor: UIColor) {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
    
        let contrastOfBackgroundColor = ContrastColorOf(backgroundColor, returnFlat: true)
        let navAppearance = UINavigationBarAppearance()
        
        // regular title color
        navBar.barTintColor = backgroundColor
        navAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastOfBackgroundColor]

        // large title color
        navAppearance.backgroundColor = backgroundColor
        navAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastOfBackgroundColor]
        
        // back button and icon color
        navBar.tintColor = contrastOfBackgroundColor
        
        // status bar and bar while scrolling
        navBar.standardAppearance = navAppearance
        navBar.scrollEdgeAppearance = navAppearance
    }
}


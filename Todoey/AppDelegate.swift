//
//  AppDelegate.swift
//  Destini
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // code for getting app data in sandbox
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
        // get file path by using FileManager
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)

        // get the path where Realm file stored
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do {
            _ = try Realm()
        } catch {
            print("Error from Realm: \(error)")
        }
        
        
        return true
    }
}


//
//  Stool_TrackerApp.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI
import UserNotifications
import UIKit

// Use UIApplicationDelegate approach for iOS 13+ compatibility
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let persistenceController = PersistenceController.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Create window first to show UI immediately
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set background color
        if #available(iOS 13.0, *) {
            window.backgroundColor = UIColor.systemBackground
        } else {
            window.backgroundColor = UIColor.white
        }
        
        // Create the SwiftUI view that provides the window contents
        let contentView = MainTabView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        
        let hostingController = UIHostingController(rootView: contentView)
        
        // Set background color for hosting controller
        if #available(iOS 13.0, *) {
            hostingController.view.backgroundColor = UIColor.systemBackground
        } else {
            hostingController.view.backgroundColor = UIColor.white
        }
        
        window.rootViewController = hostingController
        self.window = window
        window.makeKeyAndVisible()
        
        // Request notification permission asynchronously after UI is shown
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
        
        return true
    }
}

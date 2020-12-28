//
//  FirebaseTutorialApp.swift
//  FirebaseTutorial
//
//  Created by Dmitriy Borisov on 25.12.2020.
//

import SwiftUI
import Firebase

@main
struct FirebaseTutorialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

//
//  AppDelegate.swift
//  MockingbirdLauncher
//
//  Created by Brian Gonzalez on 6/29/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "com.developerbriangonzalez.Mockingbird"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty
        
        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self,
                                                                selector: #selector(self.terminate),
                                                                name: .killLauncher,
                                                                object: mainAppIdentifier)
            
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            for _ in 1...4 {
                components.removeLast()
            }
            components.append("MacOS")
            components.append("Mockingbird")
            
            let newPath = NSString.path(withComponents: components)
            
            NSWorkspace.shared.launchApplication(newPath)
        } else {
            self.terminate()
        }
    }
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

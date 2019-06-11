//
//  AppDelegate.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var mouseEventMonitor: EventMonitor?
    var keyEventMonitor: EventMonitor?
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = ClipboardController.freshController()
        
        mouseEventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        keyEventMonitor = EventMonitor(mask: .flagsChanged) { [weak self] event in
            let keyPress = event?.modifierFlags.intersection(.deviceIndependentFlagsMask)
            
            if let strongSelf = self, keyPress?.contains([.control, .option, .command]) ?? false {
                strongSelf.togglePopover(event)
            }
            
        }
        keyEventMonitor?.start()
    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Clear clipboard
    }
    
//    func constructMenu() {
//        let menu = NSMenu()
//
//        menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
//        menu.addItem(NSMenuItem.separator())
//        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
//
//        statusItem.menu = menu
//    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        mouseEventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        mouseEventMonitor?.stop()
    }
}

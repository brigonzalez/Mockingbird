//
//  AppDelegate.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa
import HotKey
import Magnet

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var mouseEventMonitor: EventMonitor?
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let clipboard = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }
        clipboard.contentViewController = ClipboardController.freshController()
        
        mouseEventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.clipboard.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        if let keyCombo = KeyCombo(keyCode: 9, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "CommandShiftV", keyCombo: keyCombo, target: self, action: #selector(togglePopover(_:)))
            hotKey.register()
        }
        
        let pasteboardWatcher = PasteboardWatcher()
        pasteboardWatcher.startPolling()
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
        if clipboard.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            clipboard.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        mouseEventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        clipboard.performClose(sender)
        mouseEventMonitor?.stop()
    }
}

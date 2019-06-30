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
    let launcherAppId = "com.developerbriangonzalez.MockingbirdLauncher"
    var mouseEventMonitor: EventMonitor?
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let pasteboardWatcher = PasteboardManager.shared
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        killLauncher()
        popover.contentViewController = ClipboardController.freshController()
        setStatusButton()
        setMouseEventMonitor()
        setEscapeEventMonitor()
        setShowHideKeyboardShortcut()
        
        pasteboardWatcher.startPolling()
    }
    
    func killLauncher() {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
    }

    func setStatusButton() {
        let mockingbirdMenuButton = statusItem.button
        mockingbirdMenuButton?.image = NSImage(named:NSImage.Name("Mockingbird-menu-icon"))
        mockingbirdMenuButton?.action = #selector(togglePopover(_:))
    }

    func setMouseEventMonitor() {
        mouseEventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }

    func setEscapeEventMonitor() {
        let escapeEventMonitor = EventMonitor(mask: .keyDown) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown && event?.keyCode == 53 {
                strongSelf.closePopover(sender: event)
            }
        }
        escapeEventMonitor.startLocalMonitor()
    }

    func setShowHideKeyboardShortcut() {
        let commandShiftVKeyCombo = KeyCombo(keyCode: 9, cocoaModifiers: [.command, .shift])
        let commandShiftVHotKey = HotKey(identifier: "CommandShiftV", keyCombo: commandShiftVKeyCombo!, target: self, action: #selector(togglePopover(_:)))
        commandShiftVHotKey.register()
    }
    
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
        mouseEventMonitor?.startGlobalMonitor()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        mouseEventMonitor?.stopGlobalMonitor()
    }
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

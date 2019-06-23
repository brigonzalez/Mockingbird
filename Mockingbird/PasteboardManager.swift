//
//  PasteboardManager.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/11/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class PasteboardManager: NSObject {
    static let shared = PasteboardManager()
    static var lastCopiedFromClipboardController: Bool = false
    
    var appPasteboard: [String] = []
    var lastCopiedStringFromSystemPasteboard = ""
    
    private let systemPasteboard = NSPasteboard.general
    private var pasteboardItemCount: Int = 0
    
    private override init() {}
    
    func startPolling () {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }
    
    func copyToPasteboard(clip: String) {
        systemPasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        systemPasteboard.setString(clip, forType: NSPasteboard.PasteboardType.string)
        
        PasteboardManager.lastCopiedFromClipboardController = true
    }
    
    @objc private func addToClipboard(stringToAdd: String) {
        appPasteboard.insert(stringToAdd, at: 0)
        
        if (appPasteboard.count == 20) {
            appPasteboard.remove(at: 19)
        }
    }
    
    @objc private func checkForChangesInPasteboard() {
        if let clippedString = systemPasteboard.string(forType: NSPasteboard.PasteboardType.string) {
            lastCopiedStringFromSystemPasteboard = clippedString
            
            if PasteboardManager.lastCopiedFromClipboardController {
                pasteboardItemCount = systemPasteboard.changeCount
                PasteboardManager.lastCopiedFromClipboardController = false
            } else if systemPasteboard.changeCount != pasteboardItemCount {
                addToClipboard(stringToAdd: clippedString)
                pasteboardItemCount = systemPasteboard.changeCount
            }
        }
    }
}

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
    
    var clipboard: [String] = []
    
    private let pasteboard = NSPasteboard.general
    private var pasteboardItemCount: Int = 0
    
    private override init() {}
    
    func startPolling () {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }
    
    func copyToPasteboard(clip: String) {
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(clip, forType: NSPasteboard.PasteboardType.string)
        
        PasteboardManager.lastCopiedFromClipboardController = true
    }
    
    @objc private func addToClipboard(stringToAdd: String) {
        clipboard.insert(stringToAdd, at: 0)
        
        if (clipboard.count == 20) {
            clipboard.remove(at: 19)
        }
    }
    
    @objc private func checkForChangesInPasteboard() {
        if PasteboardManager.lastCopiedFromClipboardController {
            pasteboardItemCount = pasteboard.changeCount
            PasteboardManager.lastCopiedFromClipboardController = false
        } else if let clippedString = pasteboard.string(forType: NSPasteboard.PasteboardType.string), pasteboard.changeCount != pasteboardItemCount {
            addToClipboard(stringToAdd: clippedString)
            pasteboardItemCount = pasteboard.changeCount
        }
    }
}

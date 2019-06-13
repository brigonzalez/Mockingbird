//
//  PasteboardManager.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/11/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class PasteboardManager : NSObject {
    static let shared = PasteboardManager()
    
    var clipboard: [String] = []
    
    private let pasteboard = NSPasteboard.general
    private var pasteboardItemCount: Int = 0
    
    weak var timer: Timer?
    
    private override init() {}
    
    func startPolling () {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PasteboardManager.checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }
    
    func copyToPasteboard(clip: String) {
        // this needs to be fixed
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        print(clip)
        pasteboard.setString(clip, forType: NSPasteboard.PasteboardType.string)
    }
    
    @objc private func addToClipboard(stringToAdd: String) {
        clipboard.insert(stringToAdd, at: 0)
        
        if (clipboard.count == 20) {
            clipboard.remove(at: 20)
        }
    }
    
    @objc private func checkForChangesInPasteboard() {
        if let clippedString = pasteboard.string(forType: NSPasteboard.PasteboardType.string), pasteboard.changeCount != pasteboardItemCount {
            addToClipboard(stringToAdd: clippedString)
            pasteboardItemCount = pasteboard.changeCount
        }
    }
}

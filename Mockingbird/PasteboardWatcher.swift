//
//  PasteboardWatcher.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/11/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class PasteboardWatcher : NSObject {
    private let pasteboard = NSPasteboard.general
    private var pasteboardItemCount: Int = 0
    weak var timer: Timer?
    
    func startPolling () {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(PasteboardWatcher.checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }
    
    @objc private func checkForChangesInPasteboard() {
        if let copiedString = pasteboard.string(forType: NSPasteboard.PasteboardType.string), pasteboard.changeCount != pasteboardItemCount {
            print(copiedString)
            pasteboardItemCount = pasteboard.changeCount
        }
    }
}

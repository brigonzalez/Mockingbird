//
//  ClipboardController.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class ClipboardController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set string to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString("Good Morning", forType: NSPasteboard.PasteboardType.string)
        
        var clipboardItems: [String] = []
        for element in pasteboard.pasteboardItems! {
            if let str = element.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
                clipboardItems.append(str)
            }
        }
        
        // Access the item in the clipboard
        let firstClipboardItem = clipboardItems[0] // Good Morning
        
        print(firstClipboardItem)
    }
    
}

extension ClipboardController {
    static func freshController() -> ClipboardController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ClipboardController")
        
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ClipboardController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        
        return viewcontroller
    }
}

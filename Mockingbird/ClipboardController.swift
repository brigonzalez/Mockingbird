//
//  ClipboardController.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class ClipboardController: NSViewController {}

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

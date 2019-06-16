//
//  ClipboardTextFieldCell.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/14/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class ClipboardTextFieldCell: NSTextFieldCell {
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        print(theRect)
        let newRect = NSRect(x: 0, y: (theRect.size.height - 22) / 2, width: theRect.size.width, height: 22)
        return super.drawingRect(forBounds: newRect)
    }
}

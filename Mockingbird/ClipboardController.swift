//
//  ClipboardController.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class ClipboardController: NSViewController {
    @IBOutlet weak var pasteboard: NSTableView!
    private let pasteboardManager = PasteboardManager.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pasteboard.delegate = self
        pasteboard.dataSource = self
        
        pasteboard.target = self
        pasteboard.doubleAction = #selector(tableViewDoubleClick(_:))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        pasteboard.reloadData()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let clip = pasteboardManager.clipboard[pasteboard.selectedRow]
        
        pasteboardManager.copyToPasteboard(clip: clip)
    }
}


extension ClipboardController: NSTableViewDataSource {
    func numberOfRows(in pasteboard: NSTableView) -> Int {
        
        return pasteboardManager.clipboard.count
    }
}

extension ClipboardController: NSTableViewDelegate {
    func tableView(_ pasteboard: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let keyboardShortcut = ClipboardShortcuts.clipboardShortcuts[row]
        let clip = pasteboardManager.clipboard[row]
        
        if let cell = pasteboard.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ClipCellId"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(keyboardShortcut): \(clip)"
            return cell
        }
        return nil
    }
}

extension ClipboardController {
    static func freshController() -> ClipboardController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ClipboardController")
        
        return (storyboard.instantiateController(withIdentifier: identifier) as? ClipboardController)!
    }
}

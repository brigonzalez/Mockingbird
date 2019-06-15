//
//  ClipboardController.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa
import LaunchAtLogin

class ClipboardController: NSViewController {
    @IBOutlet weak var pasteboard: NSTableView!
    @IBOutlet weak var startAtLoginCheckbox: NSButtonCell!
    
    private let appDelegate = NSApplication.shared.delegate as! AppDelegate
    private let pasteboardManager = PasteboardManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPasteboardProperties()
        setStartAtLoginCheckbox()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        pasteboard.selectRowIndexes(NSIndexSet(index: 0) as IndexSet, byExtendingSelection: false)
        pasteboard.reloadData()
    }
    
    func setStartAtLoginCheckbox() {
        if (LaunchAtLogin.isEnabled) {
            startAtLoginCheckbox.state = NSControl.StateValue.on
        } else {
            startAtLoginCheckbox.state = NSControl.StateValue.off
        }
    }
    
    func setPasteboardProperties() {
        pasteboard.delegate = self
        pasteboard.dataSource = self
        pasteboard.target = self
        pasteboard.doubleAction = #selector(tableViewDoubleClick(_:))
    }
    
    @IBAction func startAtLoginCheck(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = Bool(truncating: sender.state.rawValue as NSNumber)
    }
    
    @IBAction func clearButtonPress(_ sender: Any) {
        pasteboardManager.clipboard.removeAll()
        pasteboard.reloadData()
    }
    
    @IBAction func quitButtonPress(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        let clip = pasteboardManager.clipboard[pasteboard.selectedRow]
        pasteboardManager.copyToPasteboard(clip: clip)
        appDelegate.togglePopover(sender)
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
        
        if let cell = pasteboard.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ClipCellId"), owner: nil) as? ClipboardTableCellView {
            cell.keyboardShortcutLabel.stringValue = keyboardShortcut
            cell.clipTextView.delegate = self
            cell.clipTextView.string = clip
            
            return cell
        }
        return nil
    }
}

extension ClipboardController: NSTextViewDelegate {
    func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        let clip = pasteboardManager.clipboard[pasteboard.selectedRow]
        pasteboardManager.copyToPasteboard(clip: clip)
        appDelegate.togglePopover(nil)
    }
}

extension ClipboardController {
    static func freshController() -> ClipboardController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ClipboardController")
        
        return (storyboard.instantiateController(withIdentifier: identifier) as? ClipboardController)!
    }
}

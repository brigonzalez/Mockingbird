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
    
    @IBAction func clearAllButtonClick(_ sender: Any) {
        pasteboardManager.clipboard.removeAll()
        pasteboard.reloadData()
    }
    
    @IBAction func quitButtonClick(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func clearButtonClick(_ sender: NSButton) {
        pasteboardManager.clipboard.remove(at: sender.tag)
        pasteboard.reloadData()
    }
    
    @IBAction func keyboardShortcutButtonClick(_ sender: NSButton) {
        let clip = pasteboardManager.clipboard[sender.tag]
        pasteboardManager.copyToPasteboard(clip: clip)
        appDelegate.togglePopover(sender)
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
            cell.keyboardShortcutButton.title = keyboardShortcut
            cell.keyboardShortcutButton.tag = row
            cell.keyboardShortcutButton.keyEquivalent = String(keyboardShortcut.last!)
            cell.keyboardShortcutButton.keyEquivalentModifierMask = ClipboardShortcuts.getModifierMask(row: row)
            cell.clippedLabel.stringValue = clip
            cell.clearButton.tag = row
            cell.clearButton.isHidden = true
            cell.clearButton.isEnabled = false
            
            return cell
        }
        return nil
    }
    
    func handleTableViewChanges() {
        for row in 0..<pasteboardManager.clipboard.count {
            let cell = pasteboard.view(atColumn: 0, row: row, makeIfNecessary: true) as! ClipboardTableCellView
            
            if (row == pasteboard.selectedRow) {
                cell.clearButton.isHidden = false
                cell.clearButton.isEnabled = true
            } else {
                cell.clearButton.isHidden = true
                cell.clearButton.isEnabled = false
            }
        }
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        handleTableViewChanges()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        handleTableViewChanges()
    }
}

extension ClipboardController {
    static func freshController() -> ClipboardController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ClipboardController")
        
        return (storyboard.instantiateController(withIdentifier: identifier) as? ClipboardController)!
    }
}

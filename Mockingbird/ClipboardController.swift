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
    @IBOutlet weak var clipboard: NSTableView!
    @IBOutlet weak var startAtLoginCheckbox: NSButtonCell!
    
    private let appDelegate = NSApplication.shared.delegate as! AppDelegate
    private let pasteboardManager = PasteboardManager.shared
    private var needToHandleTableViewSelectionDidChangeEvent = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPasteboardProperties()
        setStartAtLoginCheckbox()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        clipboard.reloadData()
    }
    
    func setStartAtLoginCheckbox() {
        if (LaunchAtLogin.isEnabled) {
            startAtLoginCheckbox.state = NSControl.StateValue.on
        } else {
            startAtLoginCheckbox.state = NSControl.StateValue.off
        }
    }
    
    func setPasteboardProperties() {
        clipboard.delegate = self
        clipboard.dataSource = self
        clipboard.target = self
        clipboard.doubleAction = #selector(tableViewDoubleClick(_:))
    }
    
    @IBAction func startAtLoginCheck(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = Bool(truncating: sender.state.rawValue as NSNumber)
    }
    
    @IBAction func clearAllButtonClick(_ sender: Any) {
        pasteboardManager.appPasteboard.removeAll()
        clipboard.reloadData()
    }
    
    @IBAction func quitButtonClick(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func clearButtonClick(_ sender: NSButton) {
        let selectedRow = clipboard.row(for: sender)
        pasteboardManager.appPasteboard.remove(at: selectedRow)
        clipboard.removeRows(at: NSIndexSet(index: selectedRow) as IndexSet, withAnimation: NSTableView.AnimationOptions.slideLeft)
    }
    
    @IBAction func keyboardShortcutButtonClick(_ sender: NSButton) {
        let selectedRow = clipboard.row(for: sender)
        let clip = pasteboardManager.appPasteboard[selectedRow]
        pasteboardManager.copyToPasteboard(clip: clip)
        appDelegate.togglePopover(sender)
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        let clip = pasteboardManager.appPasteboard[clipboard.selectedRow]
        pasteboardManager.copyToPasteboard(clip: clip)
        appDelegate.togglePopover(sender)
    }
}

extension ClipboardController: NSTableViewDataSource {
    func numberOfRows(in pasteboard: NSTableView) -> Int {
        return pasteboardManager.appPasteboard.count
    }
}

extension ClipboardController: NSTableViewDelegate {
    func tableView(_ pasteboard: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let keyboardShortcut = ClipboardShortcuts.clipboardShortcuts[row]
        let clip = pasteboardManager.appPasteboard[row]
        
        if let cell = pasteboard.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ClipCellId"), owner: nil) as? ClipboardTableCellView {
            cell.keyboardShortcutButton.title = keyboardShortcut
            cell.keyboardShortcutButton.keyEquivalent = String(keyboardShortcut.last!)
            cell.keyboardShortcutButton.keyEquivalentModifierMask = ClipboardShortcuts.getModifierMask(row: row)
            cell.clippedLabel.stringValue = clip
            cell.clearButton.isHidden = true
            cell.clearButton.isEnabled = false
            
            return cell
        }
        return nil
    }
    
    func handleTableViewChanges() {
        for row in 0..<pasteboardManager.appPasteboard.count {
            let cell = clipboard.view(atColumn: 0, row: row, makeIfNecessary: true) as! ClipboardTableCellView
            
            if (row == clipboard.selectedRow) {
                cell.clearButton.isHidden = false
                cell.clearButton.isEnabled = true
            } else {
                cell.clearButton.isHidden = true
                cell.clearButton.isEnabled = false
            }
        }
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        needToHandleTableViewSelectionDidChangeEvent = false
        handleTableViewChanges()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if (needToHandleTableViewSelectionDidChangeEvent) {
            handleTableViewChanges()
        }
        needToHandleTableViewSelectionDidChangeEvent = true
    }
}

extension ClipboardController {
    static func freshController() -> ClipboardController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ClipboardController")
        
        return (storyboard.instantiateController(withIdentifier: identifier) as? ClipboardController)!
    }
}

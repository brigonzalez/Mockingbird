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
    private let BLUE_COLOR = NSColor(red: 0.408, green: 0.51, blue: 1.0, alpha: 1.0)
    private let GREEN_COLOR = NSColor(red: 0.075, green: 0.808, blue: 0.169, alpha: 1.0)
    
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
        pasteboardManager.appPasteboard.remove(at: clipboard.selectedRow)
        clipboard.removeRows(at: NSIndexSet(index: clipboard.selectedRow) as IndexSet, withAnimation: NSTableView.AnimationOptions.slideLeft)
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
        if let cell = pasteboard.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ClipCellId"), owner: nil) as? ClipboardTableCellView {
            let keyboardShortcut = ClipboardShortcuts.clipboardShortcuts[row]
            
            cell.keyboardShortcutButton.title = keyboardShortcut
            cell.keyboardShortcutButton.keyEquivalent = String(keyboardShortcut.last!)
            cell.keyboardShortcutButton.keyEquivalentModifierMask = ClipboardShortcuts.getModifierMask(row: row)
            cell.keyboardShortcutButton.contentTintColor = getKeyboardShortcutButtonColor(row)
            cell.keyboardShortcutButton.toolTip = getKeyboardShortcutButtonToolTip(row)
            cell.clippedLabel.stringValue = pasteboardManager.appPasteboard[row]
            cell.clearButton.alphaValue = 0.0
            cell.clearButton.addTrackingArea(NSTrackingArea.init(rect: cell.clearButton.bounds,
                                                                 options: [.mouseEnteredAndExited, .activeAlways],
                                                                 owner: self,
                                                                 userInfo: ["clearButton": cell.clearButton]))
            
            return cell
        }
        
        return nil
    }
    
    func getKeyboardShortcutButtonColor(_ row: Int) -> NSColor {
        if pasteboardManager.appPasteboard[row] == pasteboardManager.lastCopiedStringFromSystemPasteboard {
            return GREEN_COLOR
        }
        
        return BLUE_COLOR
    }
    
    func getKeyboardShortcutButtonToolTip(_ row: Int) -> String {
        if pasteboardManager.appPasteboard[row] == pasteboardManager.lastCopiedStringFromSystemPasteboard {
            return "This item is currently copied"
        }
        
        return "Click here or press \(ClipboardShortcuts.clipboardShortcuts[row]) to copy"
    }
    
    override func mouseEntered(with event: NSEvent) {
        animateClearButtonForMouseEvents(event: event, toCGFloat: 1.0)
    }
    
    override func mouseExited(with event: NSEvent) {
        animateClearButtonForMouseEvents(event: event, toCGFloat: 0.0)
    }
    
    func animateClearButtonForMouseEvents(event: NSEvent, toCGFloat: CGFloat) {
        let clearButton = event.trackingArea?.userInfo?["clearButton"] as! NSButton
        let selectedRow = clipboard.row(for: clearButton)
        let cell = clipboard.view(atColumn: 0, row: selectedRow, makeIfNecessary: true) as! ClipboardTableCellView
        animateClearButtonAlphaValue(cell.clearButton, toCGFloat: toCGFloat)
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
    
    func handleTableViewChanges() {
        for row in 0..<pasteboardManager.appPasteboard.count {
            let cell = clipboard.view(atColumn: 0, row: row, makeIfNecessary: true) as! ClipboardTableCellView
            
            if (row == clipboard.selectedRow) {
                animateClearButtonAlphaValue(cell.clearButton, toCGFloat: 1.0)
            } else {
                animateClearButtonAlphaValue(cell.clearButton, toCGFloat: 0.0)
            }
        }
    }
    
    func animateClearButtonAlphaValue(_ button: NSButton, toCGFloat: CGFloat) {
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.2
            button.animator().alphaValue = toCGFloat
        })
    }
}

extension ClipboardController {
    static func freshController() -> ClipboardController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ClipboardController")
        
        return (storyboard.instantiateController(withIdentifier: identifier) as? ClipboardController)!
    }
}

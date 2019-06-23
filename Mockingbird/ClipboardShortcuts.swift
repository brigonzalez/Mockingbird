//
//  ClipboardShortcuts.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/12/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

class ClipboardShortcuts : NSObject {
    static var clipboardCopyShortcuts = [
        "⌘1",
        "⌘2",
        "⌘3",
        "⌘4",
        "⌘5",
        "⌘6",
        "⌘7",
        "⌘8",
        "⌘9",
        "⌘0",
        "⌘⌥1",
        "⌘⌥2",
        "⌘⌥3",
        "⌘⌥4",
        "⌘⌥5",
        "⌘⌥6",
        "⌘⌥7",
        "⌘⌥8",
        "⌘⌥9",
        "⌘⌥0"
    ]
    static var clipboardClearShortcuts = [
        "⌥1",
        "⌥2",
        "⌥3",
        "⌥4",
        "⌥5",
        "⌥6",
        "⌥7",
        "⌥8",
        "⌥9",
        "⌥0",
        "⌥⇧1",
        "⌥⇧2",
        "⌥⇧3",
        "⌥⇧4",
        "⌥⇧5",
        "⌥⇧6",
        "⌥⇧7",
        "⌥⇧8",
        "⌥⇧9",
        "⌥⇧0"
    ]
    static func getModifierMaskForKeyboardShortcut(_ row: Int) -> NSEvent.ModifierFlags {
        if (row > 9) {
            return [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.option]
        }
        
        return [NSEvent.ModifierFlags.command]
    }
    static func getModifierMaskForClearButton(_ row: Int) -> NSEvent.ModifierFlags {
        if (row > 9) {
            return [NSEvent.ModifierFlags.option, NSEvent.ModifierFlags.shift]
        }
        
        return [NSEvent.ModifierFlags.option]
    }
}

//
//  EventMonitor.swift
//  Mockingbird
//
//  Created by Brian Gonzalez on 6/10/19.
//  Copyright © 2019 Brian Gonzalez. All rights reserved.
//

import Cocoa

public class EventMonitor {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stopGlobalMonitor()
        stopLocalMonitor()
    }
    
    func startGlobalMonitor() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    func startLocalMonitor() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
            self.handler(event)
            return event
        }
    }
    
    func stopGlobalMonitor() {
        if globalMonitor != nil {
            NSEvent.removeMonitor(globalMonitor!)
            globalMonitor = nil
        }
    }

    func stopLocalMonitor() {
        if localMonitor != nil {
            NSEvent.removeMonitor(localMonitor!)
            localMonitor = nil
        }
    }
}

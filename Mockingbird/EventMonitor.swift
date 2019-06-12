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
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    public func stop() {
        if globalMonitor != nil {
            NSEvent.removeMonitor(globalMonitor!)
            globalMonitor = nil
        }
    }
}

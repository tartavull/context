//
//  contextApp.swift
//  context
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import SwiftUI

@main
struct ContextApp: App {
    
    // Detect if running in UI testing mode
    var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor())
                .onAppear {
                    if isUITesting {
                        print("=== APP: Running in UI Testing mode ===")
                        // Disable animations for UI testing
                        NSApp.windows.forEach { window in
                            window.animationBehavior = .none
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isOpaque = false
                window.backgroundColor = NSColor.clear
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.isOpaque = false
                window.backgroundColor = NSColor.clear
            }
        }
    }
}

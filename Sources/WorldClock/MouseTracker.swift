import AppKit
import SwiftUI

/// Transparent NSView overlay that reliably tracks mouse in NSPopover via NSTrackingArea.
/// .onContinuousHover doesn't work in NSPopover windows.
struct MouseTrackingView: NSViewRepresentable {
    var onMove: (CGFloat) -> Void   // fraction 0-1 of width
    var onExit: () -> Void

    func makeNSView(context: Context) -> TrackingNSView {
        let v = TrackingNSView()
        v.onMove = onMove
        v.onExit = onExit
        return v
    }

    func updateNSView(_ nsView: TrackingNSView, context: Context) {
        nsView.onMove = onMove
        nsView.onExit = onExit
    }
}

class TrackingNSView: NSView {
    var onMove: ((CGFloat) -> Void)?
    var onExit: (() -> Void)?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways],
            owner: self
        ))
    }

    override func mouseMoved(with event: NSEvent) {
        let x = convert(event.locationInWindow, from: nil).x
        onMove?(max(0, min(1, x / bounds.width)))
    }

    override func mouseExited(with event: NSEvent) {
        onExit?()
    }

    override func draw(_ dirtyRect: NSRect) {}
}

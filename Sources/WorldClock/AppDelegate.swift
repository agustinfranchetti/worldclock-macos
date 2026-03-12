import AppKit
import SwiftUI
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    let model = ClockModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupStatusItem()
        setupPopover()

        model.$currentTime
            .combineLatest(model.$clocks)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _ in self?.updateLabel() }
            .store(in: &cancellables)

        updateLabel()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }
        button.action = #selector(togglePopover)
        button.target = self
        button.sendAction(on: [.leftMouseUp])
        button.font = NSFont.monospacedSystemFont(ofSize: 11.5, weight: .regular)
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .semitransient
        popover.animates = true

        let content = PopoverView(onSettingsTap: { [weak self] in
            self?.showSettings()
        })
        .environmentObject(model)

        popover.contentViewController = NSHostingController(rootView: content)
    }

    private func updateLabel() {
        guard let button = statusItem.button else { return }
        button.title = "  " + model.menuBarText
        button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "World Clock")
        button.imagePosition = .imageLeft
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            closePopover()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
            NSApp.activate(ignoringOtherApps: true)
            startEventMonitor()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        stopEventMonitor()
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func showSettings() {
        closePopover()
        let settingsView = SettingsView().environmentObject(model)
        let controller = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: controller)
        window.title = "World Clock Settings"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.setContentSize(NSSize(width: 400, height: 420))
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

import SwiftUI

@main
struct WorldClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Needed as a placeholder so @main works without a visible window
        Settings { EmptyView() }
    }
}

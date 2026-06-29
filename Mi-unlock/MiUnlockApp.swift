import SwiftUI

@main
struct MiUnlockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .defaultSize(width: 460, height: 680)
        #endif
    }
}

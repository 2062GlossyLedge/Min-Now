import SwiftUI

//Initital startup code for app
// Ayden Smith
// Feb. 21, 2025
@main
struct MMApp: App {
    //access to OwnedItems throughout app
    @StateObject private var itemsManager = ItemsManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(itemsManager)
        }
    }
}

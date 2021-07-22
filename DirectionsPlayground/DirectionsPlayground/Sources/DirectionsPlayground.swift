import SwiftUI

@main
struct DirectionsPlayground: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                QueriesList()
            }
            .navigationViewStyle(.stack)
        }
    }
}

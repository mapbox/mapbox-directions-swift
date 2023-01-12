import SwiftUI

@main
struct DirectionsExample: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                QueriesList()
            }
            .navigationViewStyle(.stack)
        }
    }
}

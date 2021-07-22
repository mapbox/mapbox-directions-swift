import Foundation
import SwiftUI

struct QueriesList: View {
    @State
    var queries: [Query] = [] {
        didSet { saveQueries() }
    }

    var body: some View {
        List {
            ForEach($queries) { $query in
                NavigationLink(
                    destination: QueryEditor(query: $query),
                    label: {
                        Text(query.name)
                    })
            }
        }
        .onAppear { loadQueries() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { newQuery() }
                    label: { Image(systemName: "plus") }
            }
        }
        .navigationTitle("Saved Queries")
    }

    private func loadQueries() {
        do {
            queries = try Storage.shared.load() ?? []
        }
        catch {
            print(error)
        }
    }

    private func newQuery() {
        let newQuery = Query.make()
        queries.append(newQuery)
    }

    private func saveQueries() {
        do {
            try Storage.shared.save(queries)
        }
        catch {
            print(error)
        }
    }
}

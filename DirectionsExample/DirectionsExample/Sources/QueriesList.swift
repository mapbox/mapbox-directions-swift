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
                        TextField("Query Name", text: $query.name)
                    })
            }
            .onMove { indices, newOffset in
                queries.move(fromOffsets: indices, toOffset: newOffset)
            }
            .onDelete { indexSet in
                queries.remove(atOffsets: indexSet)
            }
        }
        .onAppear { loadQueries() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { newQuery() }
                    label: { Image(systemName: "plus") }
            }
            ToolbarItem(placement: ToolbarItemPlacement.automatic) {
                EditButton()
            }
        }
        .navigationTitle("Saved Queries")
    }

    private func loadQueries() {
        do {
            queries = try Storage.shared.load() ?? [.default]
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

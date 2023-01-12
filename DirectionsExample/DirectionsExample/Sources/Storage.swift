import Foundation

final class Storage {
    static let shared: Storage = .init()
    
    private enum K {
        static let saveKey: String = "mapbox-directions-queries"
    }

    func save(_ queries: [Query]) throws {
        let coder = JSONEncoder()
        let data = try coder.encode(queries)
        UserDefaults.standard.setValue(data, forKey: K.saveKey)
    }

    func load() throws -> [Query]? {
        let decoder = JSONDecoder()
        return try UserDefaults.standard.data(forKey: K.saveKey).map {
            try decoder.decode([Query].self, from: $0)
        }
    }
}

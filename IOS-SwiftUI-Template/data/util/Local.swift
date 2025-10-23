import Foundation
import CouchbaseLiteSwift

struct CouchbaseLocal : Sendable {
    
    nonisolated let database: Database
    
    nonisolated var collectionPref: Collection {
        get throws {
            if let collection = try database.collection(name: "preferences") {
                return collection
            } else {
                return try database.createCollection(name: "preferences")
            }
        }
    }
    
    init() throws {
        Database.log.file.level = .warning
        Database.log.console.level = .warning
        let config = DatabaseConfiguration()
        database = try Database(name: "app_db", config: config)
        
        // Create index
        if let collection = try? collectionPref {
            let index = ValueIndexConfiguration([Preference.CodingKeys.keyString.rawValue])
            try collection.createIndex(withName: "idx_preferences_key", config: index)
        }
    }
}

// Will Be Solve Soon
extension Collection : @unchecked @retroactive Sendable {}
extension Query : @unchecked @retroactive Sendable {}
extension Database : @retroactive @unchecked Sendable { }
extension CouchbaseLiteSwift.ResultSet : @retroactive @unchecked Sendable { }
extension CouchbaseLiteSwift.QueryChange : @retroactive @unchecked Sendable { }
extension ListenerToken : @retroactive @unchecked Sendable { }

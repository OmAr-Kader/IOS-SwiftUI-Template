import Foundation
import CouchbaseLiteSwift

actor CouchbaseLocal : Sendable {
    
    @BackgroundActor
    var database: Database?
    
    
    @BackgroundActor
    var collectionPreferences: Collection {
        get throws {
            if let collection = try database!.collection(name: "preferences") {
                return collection
            } else {
                return try database!.createCollection(name: "preferences")
            }
        }
    }
    
    init() throws {
        Task { @BackgroundActor in
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("CBLLogs").path()
            let fileConfig = LogFileConfiguration(directory: directory)
            fileConfig.maxRotateCount = 5          // Number of log files to keep
            fileConfig.maxSize = 1024 * 1024       // 1 MB per log file
            fileConfig.usePlainText = false        // Keep as binary for performance

            Database.log.file.config = fileConfig
            Database.log.file.level = .warning        // or .debug for development
            Database.log.console.level = .warning  // Limit console noise

            
            let config = DatabaseConfiguration()
            self.database = try Database(name: "app_db", config: config)
            
            
            // Create index
            if let collection = try? collectionPreferences {
                let index = ValueIndexConfiguration([Preference.CodingKeys.keyString.rawValue])
                try collection.createIndex(withName: "idx_preferences_key", config: index)
            }
        }
    }
    
}

// Just For remove the warring, it safe
extension ListenerToken : @retroactive @unchecked Sendable { }

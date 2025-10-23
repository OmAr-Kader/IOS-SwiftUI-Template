import Foundation
import CouchbaseLiteSwift

final class PrefRepoImp : PrefRepo, Sendable {

    private let db: CouchbaseLocal?
    
    init(db: CouchbaseLocal?) {
        self.db = db
    }
    
    @BackgroundActor
    func prefs() async -> [Preference] {
        do {
            guard let collection = try? db?.collectionPref else {
                return []
            }
            
            let query = QueryBuilder
                .select(
                    SelectResult.expression(Meta.id).as(Preference.CodingKeys.id.rawValue),
                    SelectResult.all()
                )
                .from(DataSource.collection(collection))
            
            let results = try query.execute()
            var preferences: [Preference] = []
            
            for result in results {
                guard let id = result.string(forKey: Preference.CodingKeys.id.rawValue),
                      let document = try collection.document(id: id) else {
                    continue
                }
                preferences.append(Preference.fromDocument(document))
            }
            
            return preferences
        } catch {
            print("Error fetching prefs: \(error)")
            return []
        }
    }
    
    nonisolated func prefs(invoke: @escaping @Sendable @BackgroundActor ([Preference]) -> Void) -> ListenerToken? {
        guard let collection = try? db?.collectionPref else {
            return nil
        }
        
        let query = QueryBuilder
            .select(
                SelectResult.expression(Meta.id).as(Preference.CodingKeys.id.rawValue),
                SelectResult.all()
            )
            .from(DataSource.collection(collection))
        
        let token = query.addChangeListener(withQueue: DispatchQueue.global()) { change in
            Task { @BackgroundActor in
                do {
                    guard let results = change.results else {
                        invoke([])
                        return
                    }
                    
                    var preferences: [Preference] = []
                    for result in results {
                        guard let id = result.string(forKey: Preference.CodingKeys.id.rawValue),
                              let document = try collection.document(id: id) else {
                            continue
                        }
                        preferences.append(Preference.fromDocument(document))
                    }
                    
                    invoke(preferences)
                } catch {
                    print("Error in prefs listener: \(error)")
                    invoke([])
                }
            }
            
        }
        return token
    }
    
    @BackgroundActor
    func insertPref(_ pref: Preference) async -> Preference? {
        do {
            guard let collection = try? db?.collectionPref else {
                return nil
            }
            
            try collection.save(document: pref.toDocument())
            return pref
        } catch {
            print("Error inserting pref: \(error)")
            return nil
        }
    }
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference]) async -> [Preference]? {
        do {
            guard let collection = try? db?.collectionPref else {
                return nil
            }
            
            try db?.database.inBatch {
                for pref in prefs {
                    try collection.save(document: pref.toDocument())
                }
            }
            
            return prefs
        } catch {
            print("Error inserting prefs: \(error)")
            return nil
        }
    }
    
    @BackgroundActor
    func updatePref(_ pref: Preference, newValue: String) async -> Preference? {
        do {
            guard let collection = try? db?.collectionPref else {
                return nil
            }
            
            // 1️⃣ Query document by keyString
            let query = QueryBuilder
                .select(SelectResult.expression(Meta.id))
                .from(DataSource.collection(collection))
                .where(Expression.property(Preference.CodingKeys.keyString.rawValue).equalTo(Expression.string(pref.keyString)))

            // ✅ Correct: iterate through query results instead of subscripting
            let resultSet = try query.execute()
            let firstResult = resultSet.allResults().first
            let existingId = firstResult?.string(forKey: Preference.CodingKeys.id.rawValue)
            
            if let id = existingId, let doc = try collection.document(id: id)?.toMutable() {
                // 2️⃣ Update existing document
                doc.setString(pref.value, forKey: Preference.CodingKeys.value.rawValue)
                try collection.save(document: doc)
                return Preference.fromDocument(doc)
            } else {
                // 3️⃣ If not found, insert a new document
                let newPref = Preference(keyString: pref.keyString, value: newValue)
                try collection.save(document: newPref.toDocument())
                return newPref
            }
        } catch {
            print("Error updating pref: \(error)")
            return nil
        }
    }
    
    @BackgroundActor
    func updatePref(_ prefs: [Preference]) async -> [Preference] {
        do {
            guard let collection = try? db?.collectionPref else {
                return prefs
            }
            
            try db?.database.inBatch {
                for pref in prefs {
                    let query = QueryBuilder
                        .select(SelectResult.expression(Meta.id))
                        .from(DataSource.collection(collection))
                        .where(Expression.property(Preference.CodingKeys.keyString.rawValue).equalTo(Expression.string(pref.keyString)))
                    
                    // ✅ Correctly extract first result
                    let resultSet = try query.execute()
                    let firstResult = resultSet.allResults().first
                    let existingId = firstResult?.string(forKey: Preference.CodingKeys.id.rawValue)
                    
                    if let id = existingId, let doc = try collection.document(id: id)?.toMutable() {
                        // 2️⃣ Update value if found
                        doc.setString(pref.value, forKey: Preference.CodingKeys.value.rawValue)
                        try collection.save(document: doc)
                    } else {
                        // 3️⃣ Otherwise insert new
                        try collection.save(document: pref.toDocument())
                    }
                }
            }
            
            return prefs
        } catch {
            print("Error updating prefs: \(error)")
            return prefs
        }
    }
    
    @BackgroundActor
    func deletePref(key: String) async -> Int {
        do {
            guard let collection = try? db?.collectionPref else {
                return Const.CLOUD_FAILED
            }
            
            let query = QueryBuilder
                .select(SelectResult.expression(Meta.id))
                .from(DataSource.collection(collection))
                .where(Expression.property(Preference.CodingKeys.keyString.rawValue).equalTo(Expression.string(key)))
            
            let results = try query.execute()
            
            if let result = results.next(),
               let id = result.string(forKey: Preference.CodingKeys.id.rawValue),
               let document = try collection.document(id: id) {
                try collection.delete(document: document)
                return Const.CLOUD_SUCCESS
            }
            
            return Const.CLOUD_FAILED
        } catch {
            print("Error deleting pref: \(error)")
            return Const.CLOUD_FAILED
        }
    }
    
    @BackgroundActor
    func deletePrefAll() async -> Int {
        do {
            guard let collection = try? db?.collectionPref else {
                return Const.CLOUD_FAILED
            }
            
            let query = QueryBuilder
                .select(SelectResult.expression(Meta.id))
                .from(DataSource.collection(collection))
            
            try db?.database.inBatch {
                Task { @BackgroundActor in
                    let results = try query.execute()
                    for result in results {
                        guard let id = result.string(forKey: Preference.CodingKeys.id.rawValue),
                              let document = try collection.document(id: id) else {
                            continue
                        }
                        try collection.delete(document: document)
                    }
                }
            }
            
            return Const.CLOUD_SUCCESS
        } catch {
            print("Error deleting all prefs: \(error)")
            return Const.CLOUD_FAILED
        }
    }
}

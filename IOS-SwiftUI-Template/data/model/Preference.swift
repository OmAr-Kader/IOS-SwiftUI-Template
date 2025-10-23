import Foundation
import CouchbaseLiteSwift

struct Preference: Codable, Sendable {
    let id: String
    let keyString: String
    let value: String
    
    @BackgroundActor
    init(id: String = "pref::\(Date().timeIntervalSince1970 * 1000)", keyString: String, value: String) {
        self.id = id
        self.keyString = keyString
        self.value = value
    }
    
    @BackgroundActor
    func toDocument() -> MutableDocument {
        let doc = MutableDocument(id: id)
        doc.setString(keyString, forKey: Preference.CodingKeys.keyString.rawValue)
        doc.setString(value, forKey: Preference.CodingKeys.value.rawValue)
        return doc
    }
    
    @BackgroundActor
    static func fromDocument(_ doc: Document) -> Preference {
        return Preference(
            id: doc.id,
            keyString: doc.string(forKey: CodingKeys.keyString.rawValue) ?? "",
            value: doc.string(forKey: CodingKeys.value.rawValue) ?? ""
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyString
        case value
    }
}

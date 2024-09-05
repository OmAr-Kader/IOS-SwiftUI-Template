import Foundation
import RealmSwift

class Preference : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted(indexed: true) var keyString: String
    @Persisted var value: String

    override init() {
        super.init()
        keyString = ""
        value = ""
    }
    
    convenience init(keyString: String, value: String) {
        self.init()
        self.keyString = keyString
        self.value = value
    }
    
    convenience init(pref: PreferenceData) {
        self.init()
        if !pref.id.isEmpty {
            _id = (try? ObjectId(string: pref.id)) ?? ObjectId.init()
        }
        self.keyString = pref.keyString
        self.value = pref.value
    }
    
}

struct PreferenceData {
    
    let id: String
    let keyString: String
    let value: String
    init(pref: Preference) {
        self.id = pref._id.stringValue
        self.keyString = pref.keyString
        self.value = pref.value
    }
    
    
    init(keyString: String, value: String) {
        self.id = ""
        self.keyString = keyString
        self.value = value
    }
}

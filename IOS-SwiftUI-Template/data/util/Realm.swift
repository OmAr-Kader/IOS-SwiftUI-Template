import Foundation
import RealmSwift

let REALM_SUCCESS: Int = 1
let REALM_FAILED: Int = -1

let COURSE_TYPE_FOLLOWED: Int = 0
let COURSE_TYPE_ENROLLED: Int = 1

var listOfOnlyLocalSchemaRealmClass: [ObjectBase.Type] {
    return [Preference.self]
}


var listOfSchemaRealmClass: [ObjectBase.Type] {
    return [
        
    ]
}

var listOfSchemaEmbeddedRealmClass: [ObjectBase.Type] {
    return [
    ]
}


extension Realm {
    
    func write<Result>(
        _ block: (Self) -> Result,
        onSucces: () -> (),
        onFailed: () -> ()
    ) {
        do {
            try self.write {
                block(self)
            }
            onSucces()
        } catch {
            print("insertPref" + error.localizedDescription)
            onFailed()
        }
    }

}

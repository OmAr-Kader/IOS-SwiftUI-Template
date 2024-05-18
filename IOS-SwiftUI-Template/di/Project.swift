import Foundation
import RealmSwift

struct Project : ScopeFunc {
    let realmApi: RealmApi    
    let preference: PreferenceData
}

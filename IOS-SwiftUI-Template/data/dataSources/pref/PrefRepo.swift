import Combine
import CouchbaseLiteSwift

protocol PrefRepo : Sendable {

    @BackgroundActor
    func prefs() async -> [Preference]
    
    func prefs(invoke: @escaping @Sendable @BackgroundActor ([Preference]) -> Void) -> ListenerToken?
  
    @BackgroundActor
    func insertPref(_ pref: Preference) async -> Preference?
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference]) async -> [Preference]?
    
    @BackgroundActor
    func updatePref(_ pref: Preference, newValue: String) async -> Preference?
    
    @BackgroundActor
    func updatePref(_ prefs: [Preference]) async -> [Preference]
    
    @BackgroundActor
    func deletePref(key: String) async -> Int
    
    @BackgroundActor
    func deletePrefAll() async -> Int
    
}

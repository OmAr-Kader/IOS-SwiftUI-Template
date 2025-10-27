import Combine
import CouchbaseLiteSwift

internal protocol PrefRepo : Sendable {
            
    @BackgroundActor
    func prefs() async -> [Preference]
    
    @BackgroundActor
    func prefs(invoke: @escaping @Sendable @BackgroundActor ([Preference]) -> Void, fetchToken: @escaping @Sendable @BackgroundActor (ListenerToken?) -> Void, onFailed: @escaping @Sendable @BackgroundActor (String) -> Void)

    @BackgroundActor
    func insertPref(_ pref: Preference) async -> Preference?
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference]) async -> [Preference]?
    
    @BackgroundActor
    func updatePref(_ pref: Preference, newValue: String) async -> Preference
    
    @BackgroundActor
    func updatePref(_ prefs: [Preference]) async -> [Preference]
    
    @BackgroundActor
    func deletePref(key: String) async -> Int
    
    @BackgroundActor
    func deletePrefAll() async -> Int
    
}

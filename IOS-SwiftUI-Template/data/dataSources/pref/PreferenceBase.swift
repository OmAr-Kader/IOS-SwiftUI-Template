import Combine
import CouchbaseLiteSwift

final class PreferenceBase : Sendable {

    let repository: PrefRepo
    
    public init(repository: PrefRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func prefs() async -> [Preference] {
        await repository.prefs()
    }
    
    func prefs(invoke: @escaping @Sendable @BackgroundActor ([Preference]) -> Void) -> ListenerToken? {
        return repository.prefs(invoke: invoke)
    }
  
    @BackgroundActor
    func insertPref(_ pref: Preference) async -> Preference? {
        return await repository.insertPref(pref)
    }
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference]) async -> [Preference]? {
        return await repository.insertPref(prefs)
    }
    
    @BackgroundActor
    func updatePref(_ pref: Preference, newValue: String) async -> Preference? {
        return await repository.updatePref(pref, newValue: newValue)
    }
    
    @BackgroundActor
    func updatePref(_ prefs: [Preference]) async -> [Preference] {
        return await repository.updatePref(prefs)
    }
    
    @BackgroundActor
    func deletePref(key: String) async -> Int {
        return await repository.deletePref(key: key)
    }
    
    @BackgroundActor
    func deletePrefAll() async -> Int {
        return await repository.deletePrefAll()
    }
}

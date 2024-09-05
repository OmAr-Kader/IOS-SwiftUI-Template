import Combine

protocol PrefRepo {
    
    @BackgroundActor
    func prefs(invoke: @BackgroundActor ([Preference]) async -> Unit) async
    
    @BackgroundActor
    func prefsRealTime(invoke: @BackgroundActor @escaping ([Preference]) -> Unit) async -> AnyCancellable?
  
    @BackgroundActor
    func updatePref(_ prefs: [Preference],_ invoke: @escaping (([Preference]?) async -> Unit)) async

    @BackgroundActor
    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) async -> Unit
    ) async

    @BackgroundActor
    func deletePref(key: String) async -> Int
    
    @BackgroundActor
    func deletePrefAll() async -> Int
    
}

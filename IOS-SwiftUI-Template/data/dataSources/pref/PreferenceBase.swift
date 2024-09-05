import Combine

class PreferenceBase {
    
    var repository: PrefRepo
    
    init(repository: PrefRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func prefs(invoke: @BackgroundActor ([PreferenceData]) async -> Unit) async {
        await repository.prefs { it in
            await invoke(it.toPreferenceData())
        }
    }
    
    @BackgroundActor
    func prefsRealTime(invoke: @BackgroundActor @escaping ([PreferenceData]) -> Unit) async -> AnyCancellable? {
        return await repository.prefsRealTime { it in
            invoke(it.toPreferenceData())
        }
    }
    
    
    @BackgroundActor
    func updatePref(_ prefs: [PreferenceData],_ invoke: @escaping (([PreferenceData]?) -> Unit)) async {
        await repository.updatePref(prefs.toPreference()) { it in
            invoke(it?.toPreferenceData())
        }
    }
    
    @BackgroundActor
    func updatePref(
        _ pref: PreferenceData,
        _ newValue: String,
        _ invoke: @BackgroundActor @escaping (PreferenceData?) async -> Unit
    ) async {
        await repository.updatePref(Preference(pref: pref), newValue) { it in
            await invoke(it != nil ? PreferenceData(pref: it!) : nil)
        }
    }

    @BackgroundActor
    func deletePref(key: String) async -> Int {
        return await repository.deletePref(key: key)
    }
    
    @discardableResult
    @BackgroundActor
    func deletePrefAll() async -> Int {
        return await repository.deletePrefAll()
    }
}

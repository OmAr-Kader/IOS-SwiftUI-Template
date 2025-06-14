import Foundation
import SwiftUI
import Combine

class AppObserve : ObservableObject {

    @Inject
    private var project: Project
        
    private var tasker = Tasker()

    var shouldNotify = true // MARK: HINT => SHOUD BE USED IN SUB SCREEN

    @Published var navigationPath = NavigationPath()
    
    @Published var state = State()
            
    private var preff: Preference? = nil
    private var preferences: [PreferenceData] = []
    private var prefsTask: Task<Void, Error>? = nil
    private var sinkPrefs: AnyCancellable? = nil

    init() {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        prefsTask = tasker.back {
            self.sinkPrefs = await self.project.pref.prefsRealTime { list in
                self.preferences = list
            }
        }
    }
    
    @MainActor
    func updatenavigationPath(_ it: NavigationPath) {
        self.navigationPath = it
    }
    
    @MainActor
    var navigateHome: (Screen) -> Unit {
        return { screen in
            withAnimation {
                self.state = self.state.copy(homeScreen: screen)
            }
            return ()
        }
    }
    
    @MainActor
    func navigateHomeNoAnimation(_ screen: Screen) -> Unit {
        self.state = self.state.copy(homeScreen: screen)
    }
    
    @MainActor
    func navigateTo(_ screen: Screen) {
        self.navigationPath.append(screen)
    }
    
    @MainActor
    func backPress() {
        if !self.navigationPath.isEmpty {
            self.navigationPath.removeLast()
        }
    }
    
    private func inti(invoke: @BackgroundActor @escaping ([PreferenceData]) -> Unit) {
        tasker.back {
            await self.project.pref.prefs { list in
                invoke(list)
            }
        }
    }

    
    @MainActor
    func findUserBase(
        invoke: @escaping @MainActor (UserBase?) -> Unit
    ) {
        guard self.project.realmApi.realmApp.currentUser != nil else {
            invoke(nil)
            return
        }
        if (self.preferences.isEmpty) {
            self.inti { it in
                self.tasker.back {
                    let userBase = await self.fetchUserBase(it)
                    self.tasker.mainSync {
                        self.preferences = it
                        invoke(userBase)
                    }
                }
            }
        } else {
            self.tasker.back {
                let userBase = await self.fetchUserBase(self.preferences)
                self.tasker.mainSync {
                    invoke(userBase)
                }
            }
        }
    }

    @BackgroundActor
    private func fetchUserBase(_ list: [PreferenceData]) async -> UserBase? {
        let id = list.last { it in it.keyString == PREF_USER_ID }?.value
        let name = list.last { it in it.keyString == PREF_USER_NAME }?.value
        let email = list.last { it in it.keyString == PREF_USER_EMAIL }?.value
        let userType = list.last { it in it.keyString == PREF_USER_TYPE }?.value
        if (id == nil || name == nil || email == nil || userType == nil) {
            return nil
        }
        return UserBase(id: id!, name: name!, email: email!, accountType: Int(userType!)!)
    }

    func updateUserBase(userBase: UserBase, invoke: @escaping @MainActor () -> Unit) {
        tasker.backSync {
            var list : [PreferenceData] = []
            list.append(PreferenceData(keyString: PREF_USER_ID, value: userBase.id))
            list.append(PreferenceData(keyString: PREF_USER_NAME, value: userBase.name))
            list.append(PreferenceData(keyString: PREF_USER_EMAIL, value: userBase.email))
            list.append(PreferenceData(keyString: PREF_USER_TYPE, value: String(userBase.accountType)))
            await self.project.pref.updatePref(list) { newPref in
                self.inti { it in
                    self.tasker.mainSync {
                        self.preferences = it
                        invoke()
                    }
                }
            }
        }
    }

    func findPrefString(
        key: String,
        value: @escaping (String?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                let preference = it.first { it1 in it1.keyString == key }?.value
                self.tasker.mainSync {
                    self.preferences = it
                    value(preference)
                }
            }
        } else {
            tasker.back {
                let preference = self.preferences.first { it1 in it1.keyString == key }?.value
                self.tasker.mainSync {
                    value(preference)
                }
            }
        }
    }
    
    func updatePref(key: String, newValue: String, _ invoke: @MainActor @escaping () -> ()) {
        self.tasker.back {
            await self.project.pref.updatePref(
                PreferenceData(
                    keyString: key,
                    value: newValue
                ), newValue
            ) { _ in
                self.tasker.mainSync {
                    invoke()
                }
            }
        }
    }
    
    
    @MainActor
    func findArg(screen: Screen) -> (any ScreenConfig)? {
        return state.argOf(screen)
    }
    
    @MainActor
    func writeArguments(_ route: Screen,_ screenConfig: ScreenConfig) {
        state = state.copy(route, screenConfig)
    }
    
    @MainActor
    func signOut(_ invoke: @escaping @MainActor () -> Unit,_ failed: @escaping @MainActor () -> Unit) {
        tasker.back {
            let result = await self.project.pref.deletePrefAll()
            if result == REALM_SUCCESS {
                self.self.tasker.mainSync {
                    invoke()
                }
            } else {
                self.self.tasker.mainSync {
                    failed()
                }
            }
        }
    }

    
    private func cancelSession() {
        prefsTask?.cancel()
        prefsTask = nil
    }

    struct State {

        private(set) var homeScreen: Screen = .AUTH_SCREEN_ROUTE
        private(set) var userBase: UserBase? = nil
        private(set) var args = [Screen : any ScreenConfig]()
    
        @MainActor
        mutating func copy(
            homeScreen: Screen? = nil,
            userBase: UserBase? = nil,
            args: [Screen : any ScreenConfig]? = nil
        ) -> Self {
            self.homeScreen = homeScreen ?? self.homeScreen
            self.userBase = userBase ?? self.userBase
            self.args = args ?? self.args
            return self
        }
        
        mutating func argOf(_ screen: Screen) -> (any ScreenConfig)? {
            return args.first { (key: Screen, value: any ScreenConfig) in
                key == screen
            }?.value
        }
        
        mutating func copy<T : ScreenConfig>(_ screen: Screen, _ screenConfig: T) -> Self {
            args[screen] = screenConfig
            return self
        }
    }
    
    deinit {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        sinkPrefs = nil
        prefsTask = nil
        tasker.deInit()
    }
    
}

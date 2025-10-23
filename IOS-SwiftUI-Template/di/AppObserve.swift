import Foundation
import SwiftUI
import Combine
import CouchbaseLiteSwift

class BaseObserve: ObservableObject {
    
    let project: Project
    
    var tasker = Tasker()

    init(project: Project) {
        self.project = project
    }
}

@MainActor
class AppObserve : BaseObserve, Sendable {

    var shouldNotify = true // MARK: HINT => SHOUD BE USED IN SUB SCREEN

    @Published var navigationPath = NavigationPath()
    
    @Published var state = State()
            
    private var preff: Preference? = nil
    private var preferences: [Preference] = []
    private var prefsTask: Task<Void, Error>? = nil
   
    @BackgroundActor
    private var sinkPrefs: ListenerToken? = nil

    init() {
        @Inject
        var project: Project
        super.init(project: project)
        prefsTask?.cancel()
        sinkPrefs?.remove()
        prefsTask = tasker.back {
            self.sinkPrefs = self.project.pref.prefs { list in
                self.tasker.mainSync {
                    self.preferences = list
                    self.initialCount()
                }
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
    
    private func inti(invoke: @BackgroundActor @escaping ([Preference]) -> Unit) {
        tasker.back {
            await invoke(self.project.pref.prefs())
        }
    }
    
    

    
    @MainActor
    func findUserBase(
        invoke: @escaping @MainActor (UserBase?) -> Unit
    ) {
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
    private func fetchUserBase(_ list: [Preference]) async -> UserBase? {
        let id = list.last { it in it.keyString == Const.PREF_USER_ID }?.value
        let name = list.last { it in it.keyString == Const.PREF_USER_NAME }?.value
        let email = list.last { it in it.keyString == Const.PREF_USER_EMAIL }?.value
        let userType = list.last { it in it.keyString == Const.PREF_USER_TYPE }?.value
        if (id == nil || name == nil || email == nil || userType == nil) {
            return nil
        }
        return UserBase(id: id!, name: name!, email: email!, accountType: Int(userType!)!)
    }

    func updateUserBase(userBase: UserBase, invoke: @escaping @MainActor () -> Unit) {
        tasker.backSync {
            var list : [Preference] = []
            list.append(Preference(keyString: Const.PREF_USER_ID, value: userBase.id))
            list.append(Preference(keyString: Const.PREF_USER_NAME, value: userBase.name))
            list.append(Preference(keyString: Const.PREF_USER_EMAIL, value: userBase.email))
            list.append(Preference(keyString: Const.PREF_USER_TYPE, value: String(userBase.accountType)))
            let _ = await self.project.pref.updatePref(list)
            let it = await self.project.pref.prefs()
            self.tasker.mainSync {
                self.preferences = it
                invoke()
            }
        }
    }

    @MainActor
    func findPrefString(
        key: String,
        value: @escaping @MainActor (String?) -> Unit
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
            let preference = self.preferences.first { it1 in it1.keyString == key }?.value
            tasker.back {
                self.tasker.mainSync {
                    value(preference)
                }
            }
        }
    }
    
    func updatePref(key: String, newValue: String, _ invoke: @MainActor @escaping () -> ()) {
        tasker.back {
            _ = await self.project.pref.updatePref(Preference(keyString: key, value: newValue), newValue: newValue)
            self.tasker.mainSync {
                invoke()
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
            if result == Const.CLOUD_SUCCESS {
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

    @MainActor
    func initialCount() {
        let countInt = (Int(preferences.first(where: { $0.keyString == "test_count"})?.value ?? "0") ?? 0)
        //withAnimation {
            self.state = self.state.copy(count: countInt)
        //}
    }
    
    @MainActor
    func increaseCount() {
        let new = (Int(preferences.first(where: { $0.keyString == "test_count"})?.value ?? "0") ?? 0) + 1
        //state = state.copy(count: .set(new))

        updatePref(key: "test_count", newValue: "\(new)") {
            
        }
    }
    
    private func cancelSession() {
        prefsTask?.cancel()
        prefsTask = nil
    }

    struct State {
        
        private(set) var homeScreen: Screen = .AUTH_SCREEN_ROUTE
        private(set) var userBase: UserBase? = nil
        private(set) var count: Int = 0
        private(set) var args = [Screen : any ScreenConfig]()
        
        @MainActor
        mutating func copy(
            homeScreen: Screen? = nil,
            userBase: UserBase? = nil,
            count: Int? = nil,
            args: [Screen : any ScreenConfig]? = nil
        ) -> Self {
            self.homeScreen = homeScreen ?? self.homeScreen
            self.userBase = userBase ?? self.userBase
            self.count = count ?? self.count
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
        sinkPrefs?.remove()
        sinkPrefs = nil
        prefsTask = nil
        tasker.deInit()
    }
    
}

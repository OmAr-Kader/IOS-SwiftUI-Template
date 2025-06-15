import SwiftUI

struct Main: View {
    
    /*@StateObject*/
    var app: AppObserve
    @State private var renderTrigger = 0

    @Inject
    private var theme: Theme
    
    var navigateTo: @MainActor (Screen) -> Unit {
        return { screen in
            app.navigateTo(screen)
        }
    }
    
    var navigateToScreen: @MainActor (ScreenConfig, Screen) -> Unit {
        return { args, screen in
            app.writeArguments(screen, args)
            app.navigateTo(screen)
        }
    }
    
    var navigateHome: @MainActor (Screen) -> Unit {
        return { screen in
            withAnimation {
                app.navigateHome(screen)
            }
        }
    }
    
    var backPress: @MainActor () -> Unit {
        return {
            app.backPress()
        }
    }
    
    var screenConfig: @MainActor (Screen) -> (any ScreenConfig)? {
        return { screen in
            return app.findArg(screen: screen)
        }
    }
    
    var body: some View {
        //let isSplash = app.state.homeScreen == Screen.SPLASH_SCREEN_ROUTE
        
        let _ = print("Main rendered \(renderTrigger)") // MARK: HINT => Necessary To Re-render
        NavigationStack(path: Binding(get: { app.navigationPath }, set: { it in app.updatenavigationPath(it)})) {
            targetScreen(
                app.state.homeScreen, app, navigateTo: navigateTo, navigateToScreen: navigateToScreen, navigateHome: navigateHome, backPress: backPress, screenConfig: screenConfig
            ).navigationDestination(for: Screen.self) { route in
                targetScreen(route, app, navigateTo: navigateTo, navigateToScreen: navigateToScreen, navigateHome: navigateHome, backPress: backPress, screenConfig: screenConfig)
                    //.toolbar(.hidden, for: .navigationBar)
            }
        }.onReceive(app.objectWillChange) {
            /*.onAppeared { // MARK: HINT => SHOUD BE USED IN SUB SCREEN
                app.shouldNotify = false
            }.onDisappear {
                app.shouldNotify = true
            }*/
            guard self.app.shouldNotify else { return }
            let _ = print("Main rendered objectWillChange")
            renderTrigger += 1 // force SwiftUI to re-evaluate
        }/*.prepareStatusBarConfigurator(
          isSplash ? theme.background : theme.primary, isSplash, theme.isDarkStatusBarText
          )*/
    }
}

struct SplashScreen : View {
    
    
    private let theme = Theme(isDarkMode: UITraitCollection.current.userInterfaceStyle.isDarkMode)
    @State private var scale: Double = 1
    @State private var width: CGFloat = 50

    var body: some View {
        FullZStack {
            Image(
                uiImage: UIImage(
                    named: "sociality"
                )?.withTintColor(
                    UIColor(theme.textColor)
                ) ?? UIImage()
            ).resizable()
                .scaleEffect(scale)
                .frame(width: width, height: width, alignment: .center)
                .onAppear {
                    withAnimation() {
                        width = 150
                    }
                }
        }.background(theme.background)
    }
}

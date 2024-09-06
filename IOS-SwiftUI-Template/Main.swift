import SwiftUI

struct Main: View {
    @StateObject var app: AppObserve
    
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
        NavigationStack(path: $app.navigationPath) {
            targetScreen(
                app.state.homeScreen, app, navigateTo: navigateTo, navigateToScreen: navigateToScreen, navigateHome: navigateHome, backPress: backPress, screenConfig: screenConfig
            ).navigationDestination(for: Screen.self) { route in
                targetScreen(route, app, navigateTo: navigateTo, navigateToScreen: navigateToScreen, navigateHome: navigateHome, backPress: backPress, screenConfig: screenConfig)//.toolbar(.hidden, for: .navigationBar)
            }
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

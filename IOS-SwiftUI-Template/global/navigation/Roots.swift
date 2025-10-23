import SwiftUI

extension View {
    
    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppObserve,
        navigator: Navigator
    ) -> some View {
        switch target {
        case .AUTH_SCREEN_ROUTE:
            HomeScreen(app: app)
        case .HOME_SCREEN_ROUTE:
            HomeScreen(app: app)
        }
    }
}


@MainActor
protocol Navigator : Sendable {
    
    var navigateTo: @MainActor (Screen) -> Void { get }
    
    var navigateToScreen: @MainActor (ScreenConfig, Screen) -> Void { get }
        
    var backPress: @MainActor () -> Void { get }
    
    var screenConfig: @MainActor (Screen) -> (any ScreenConfig)? { get }

}

enum Screen : Hashable {
    
    case AUTH_SCREEN_ROUTE
    case HOME_SCREEN_ROUTE
}


protocol ScreenConfig {}

class SplashConfig: ScreenConfig {
    
}

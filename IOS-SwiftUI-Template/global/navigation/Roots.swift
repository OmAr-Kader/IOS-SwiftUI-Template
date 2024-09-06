import SwiftUI

extension View {
    
    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppObserve,
        navigateTo: @MainActor @escaping (Screen) -> Unit,
        navigateToScreen: @MainActor @escaping (ScreenConfig, Screen) -> Unit,
        navigateHome: @MainActor @escaping (Screen) -> Unit,
        backPress: @MainActor @escaping () -> Unit,
        screenConfig: @MainActor @escaping (Screen) -> (any ScreenConfig)?
    ) -> some View {
        switch target {
        case .AUTH_SCREEN_ROUTE:
            SplashScreen()
        case .HOME_SCREEN_ROUTE:
            SplashScreen()
        }
    }
}

enum Screen : Hashable {
    
    case AUTH_SCREEN_ROUTE
    case HOME_SCREEN_ROUTE
}


protocol ScreenConfig {}

class SplashConfig: ScreenConfig {
    
}

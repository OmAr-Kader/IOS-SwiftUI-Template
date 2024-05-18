import SwiftUI

extension View {
    
    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppObserve
    ) -> some View {
        switch target {
        case .SPLASH_SCREEN_ROUTE :
            SplashScreen(app: app)
        }
    }
}

enum Screen : Hashable {
    
    case SPLASH_SCREEN_ROUTE
}


protocol ScreenConfig {}

class SplashConfig: ScreenConfig {
    
}

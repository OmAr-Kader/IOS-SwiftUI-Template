//
//  IOS_SwiftUI_TemplateApp.swift
//  IOS-SwiftUI-Template
//
//  Created by OmAr on 18/05/2024.
//

import SwiftUI

@main
struct IOS_SwiftUI_TemplateApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State var isInjected: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInjected {
                    Main(app: delegate.app)
                } else {
                    SplashScreen().task {
                        let _ = await Task { @MainActor in
                            delegate.app.findUserBase { it in
                                Task { @BackgroundActor in
                                    await Task.sleep(sec: 0.7)
                                    Task { @MainActor in
                                        if !isInjected {
                                            withAnimation {
                                                delegate.app.navigateHomeNoAnimation(it != nil ? .HOME_SCREEN_ROUTE : .AUTH_SCREEN_ROUTE)
                                                isInjected.toggle()
                                            }
                                        }
                                    }
                                }
                            }
                        }.result
                    }
                }
            }
        }
    }
}

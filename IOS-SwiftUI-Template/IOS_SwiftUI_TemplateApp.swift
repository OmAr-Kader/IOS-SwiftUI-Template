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
    
    var body: some Scene {
        WindowGroup {
            Main(app: delegate.app)
        }
    }
}

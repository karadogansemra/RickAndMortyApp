//
//  AppDelegate.swift
//  RickAndMortyApp
//
//  Application entry point.
//  Handles Firebase configuration and app lifecycle.
//

import UIKit
import FirebaseCore
import FirebaseCrashlytics

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Application Lifecycle
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Print configuration in debug
        AppConfiguration.printConfiguration()
        
        // Configure based on feature flags
        if AppConfiguration.Features.isAnalyticsEnabled || AppConfiguration.Features.isCrashlyticsEnabled {
            configureFirebase()
        }
        
        return true
    }
    
    // MARK: - Firebase Configuration
    
    private func configureFirebase() {
        // Firebase requires GoogleService-Info.plist in the bundle.
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("⚠️ GoogleService-Info.plist not found. Firebase will not be configured.")
            #endif
            return
        }
        
        FirebaseApp.configure()
        
        // Configure Crashlytics based on feature flag and environment
        let enableCrashlytics = AppConfiguration.Features.isCrashlyticsEnabled
            && AppConfiguration.environment.isProduction
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enableCrashlytics)
    }
    
    // MARK: - Scene Configuration
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}

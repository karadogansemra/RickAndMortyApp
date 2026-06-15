//
//  AppConfiguration.swift
//  RickAndMortyApp
//
//  Centralized app configuration that reads values from Info.plist (xcconfig).
//  Single source of truth for all environment-specific settings.
//

import Foundation

// MARK: - App Configuration

enum AppConfiguration {
    
    // MARK: - Info.plist Access
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Info.plist not found")
        }
        return dict
    }()
    
    private static func value<T>(for key: String) -> T {
        guard let value = infoDictionary[key] as? T else {
            fatalError("Missing key '\(key)' in Info.plist")
        }
        return value
    }
    
    private static func optionalValue<T>(for key: String) -> T? {
        infoDictionary[key] as? T
    }
    
    // MARK: - Environment
    
    enum Environment: String {
        case development
        case staging
        case production
        
        var isDevelopment: Bool { self == .development }
        var isStaging: Bool { self == .staging }
        var isProduction: Bool { self == .production }
    }
    
    static var environment: Environment {
        let envString: String = value(for: "AppEnvironment")
        return Environment(rawValue: envString) ?? .production
    }
    
    // MARK: - App Info
    
    static var appName: String {
        value(for: "CFBundleName")
    }
    
    static var displayName: String {
        optionalValue(for: "CFBundleDisplayName") ?? appName
    }
    
    static var version: String {
        value(for: "CFBundleShortVersionString")
    }
    
    static var buildNumber: String {
        value(for: "CFBundleVersion")
    }
    
    static var fullVersion: String {
        "\(version) (\(buildNumber))"
    }
    
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? ""
    }
    
    // MARK: - API Configuration
    
    enum API {
        
        static var rickAndMortyBaseURL: URL {
            let urlString: String = value(for: "RickAndMortyAPIBaseURL")
            guard let url = URL(string: urlString) else {
                fatalError("Invalid Rick and Morty API URL: \(urlString)")
            }
            return url
        }
        
        static var exampleAPIBaseURL: URL? {
            guard let urlString: String = optionalValue(for: "ExampleAPIBaseURL"),
                  !urlString.isEmpty else {
                return nil
            }
            return URL(string: urlString)
        }
        
        static var picsumBaseURL: URL {
            let urlString: String = value(for: "PicsumAPIBaseURL")
            guard let url = URL(string: urlString) else {
                fatalError("Invalid Picsum API URL: \(urlString)")
            }
            return url
        }
        
        static var picsumImageBaseURL: URL {
            let urlString: String = value(for: "PicsumImageBaseURL")
            guard let url = URL(string: urlString) else {
                fatalError("Invalid Picsum Image URL: \(urlString)")
            }
            return url
        }
        
        static var version: String {
            optionalValue(for: "APIVersion") ?? "v1"
        }
        
        static var timeout: TimeInterval {
            guard let timeoutString: String = optionalValue(for: "APITimeout"),
                  let timeout = TimeInterval(timeoutString) else {
                return 30.0
            }
            return timeout
        }
    }
    
    // MARK: - Feature Flags
    
    enum Features {
        
        static var isAnalyticsEnabled: Bool {
            boolValue(for: "EnableAnalytics")
        }
        
        static var isCrashlyticsEnabled: Bool {
            boolValue(for: "EnableCrashlytics")
        }
        
        static var isLoggingEnabled: Bool {
            boolValue(for: "EnableLogging")
        }
        
        static var isDebugMenuEnabled: Bool {
            boolValue(for: "EnableDebugMenu")
        }
        
        private static func boolValue(for key: String) -> Bool {
            guard let value: String = optionalValue(for: key) else {
                return false
            }
            return value.uppercased() == "YES" || value == "1" || value.uppercased() == "TRUE"
        }
    }
    
    // MARK: - Logging
    
    enum LogLevel: String {
        case verbose
        case debug
        case info
        case warning
        case error
        case none
    }
    
    static var logLevel: LogLevel {
        guard let levelString: String = optionalValue(for: "LogLevel") else {
            return .info
        }
        return LogLevel(rawValue: levelString.lowercased()) ?? .info
    }
}

// MARK: - Debug Description

extension AppConfiguration {
    
    static var debugDescription: String {
        """
        ═══════════════════════════════════════════
        📱 App Configuration
        ═══════════════════════════════════════════
        Environment: \(environment.rawValue.uppercased())
        App: \(displayName) v\(fullVersion)
        Bundle ID: \(bundleIdentifier)
        
        🔗 API Configuration
        ───────────────────────────────────────────
        Rick & Morty URL: \(API.rickAndMortyBaseURL.absoluteString)
        API Version: \(API.version)
        Timeout: \(API.timeout)s
        
        🚀 Feature Flags
        ───────────────────────────────────────────
        Analytics: \(Features.isAnalyticsEnabled ? "✅" : "❌")
        Crashlytics: \(Features.isCrashlyticsEnabled ? "✅" : "❌")
        Logging: \(Features.isLoggingEnabled ? "✅" : "❌")
        Debug Menu: \(Features.isDebugMenuEnabled ? "✅" : "❌")
        Log Level: \(logLevel.rawValue)
        ═══════════════════════════════════════════
        """
    }
    
    static func printConfiguration() {
        #if DEBUG
        print(debugDescription)
        #endif
    }
}

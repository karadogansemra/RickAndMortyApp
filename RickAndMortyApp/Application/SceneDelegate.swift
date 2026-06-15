//
//  SceneDelegate.swift
//  RickAndMortyApp
//
//  Manages the app's window and root coordinator.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    // MARK: - Scene Lifecycle
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Show splash screen first
        showSplashScreen()
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Splash Screen
    
    private func showSplashScreen() {
        let splashVC = SplashViewController()
        splashVC.onAnimationComplete = { [weak self] in
            self?.transitionToMainApp()
        }
        window?.rootViewController = splashVC
    }
    
    private func transitionToMainApp() {
        // Setup navigation controller
        let navigationController = UINavigationController()
        configureNavigationController(navigationController)
        
        // Setup coordinator
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()
        
        // Animated transition to main app
        guard let window = window else { return }
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = navigationController
            },
            completion: nil
        )
    }
    
    // MARK: - Configuration
    
    private func configureNavigationController(_ navigationController: UINavigationController) {
        navigationController.navigationBar.prefersLargeTitles = false
    }
}

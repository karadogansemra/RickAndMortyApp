//
//  AppCoordinator.swift
//  RickAndMortyApp
//
//  Root coordinator that manages the app's main navigation flow.
//

import UIKit

// MARK: - App Coordinator

@MainActor
final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let dependencyContainer: DependencyContainerProtocol
    
    // MARK: - Initialization
    
    init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyContainerProtocol = DependencyContainer.shared
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Start
    
    func start() {
        showCharacterList()
    }
    
    // MARK: - Navigation
    
    private func showCharacterList() {
        let coordinator = CharacterListCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        addChild(coordinator)
        coordinator.start()
    }
}

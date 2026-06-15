//
//  CharacterListCoordinator.swift
//  RickAndMortyApp
//
//  Coordinator for the Character List module.
//  Handles navigation to character details and photo details.
//

import UIKit

// MARK: - Character List Coordinator

@MainActor
final class CharacterListCoordinator: Coordinator {
    
    // MARK: - Properties
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let dependencyContainer: DependencyContainerProtocol
    
    // MARK: - Initialization
    
    init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyContainerProtocol
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Start
    
    func start() {
        let viewModel = dependencyContainer.makeCharacterListViewModel()
        let viewController = CharacterListViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    // MARK: - Navigation
    
    func showCharacterDetail(_ character: CharacterEntity) {
        let viewModel = dependencyContainer.makeCharacterDetailViewModel(character: character)
        let viewController = CharacterDetailViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPhotoDetail(characterName: String, imageURL: URL?) {
        let viewModel = dependencyContainer.makePhotoDetailViewModel(
            characterName: characterName,
            imageURL: imageURL
        )
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        navigationController.present(navController, animated: true)
    }
}

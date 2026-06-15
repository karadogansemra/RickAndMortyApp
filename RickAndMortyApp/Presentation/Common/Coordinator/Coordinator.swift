//
//  Coordinator.swift
//  RickAndMortyApp
//
//  Base Coordinator protocol for navigation management.
//  Implements the Coordinator pattern for decoupled navigation.
//

import UIKit

// MARK: - Coordinator Protocol

@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
}

// MARK: - Default Implementation

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}

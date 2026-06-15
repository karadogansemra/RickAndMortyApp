//
//  UIViewController+Extensions.swift
//  RickAndMortyApp
//
//  Convenient extensions for UIViewController.
//

import UIKit

// MARK: - Alert Presentation

extension UIViewController {
    
    /// Shows a simple alert with a title and message.
    func showAlert(
        title: String?,
        message: String?,
        buttonTitle: String = L10n.General.ok,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    /// Shows an error alert.
    func showError(_ error: Error) {
        showAlert(title: L10n.General.error, message: error.localizedDescription)
    }
    
    /// Shows a success message.
    func showSuccess(message: String, completion: (() -> Void)? = nil) {
        showAlert(title: "Success", message: message, completion: completion)
    }
}

// MARK: - Navigation Bar Styling

extension UIViewController {
    
    /// Configures navigation bar with a clean, modern appearance.
    func configureNavigationBarAppearance(backgroundColor: UIColor = .systemBackground) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}

// MARK: - Loading State

extension UIViewController {
    
    private static var loadingViewKey: UInt8 = 0
    
    private var loadingView: UIView? {
        get { objc_getAssociatedObject(self, &Self.loadingViewKey) as? UIView }
        set { objc_setAssociatedObject(self, &Self.loadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Shows a loading overlay.
    func showLoading() {
        guard loadingView == nil else { return }
        
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.center = overlay.center
        spinner.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        spinner.startAnimating()
        
        overlay.addSubview(spinner)
        view.addSubview(overlay)
        
        loadingView = overlay
    }
    
    /// Hides the loading overlay.
    func hideLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}

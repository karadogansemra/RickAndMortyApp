//
//  SplashViewController.swift
//  RickAndMortyApp
//
//  Animated splash screen shown after app launch.
//  Created programmatically without storyboard.
//

import UIKit

// MARK: - Splash View Controller

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    var onAnimationComplete: (() -> Void)?
    
    // MARK: - UI Components
    
    private let portalView: PortalAnimationView = {
        let view = PortalAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rick & Morty"
        label.font = .systemFont(ofSize: 36, weight: .heavy)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Character Explorer"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemGreen
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(portalView)
        view.addSubview(characterImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            // Portal background
            portalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portalView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            portalView.widthAnchor.constraint(equalToConstant: 180),
            portalView.heightAnchor.constraint(equalToConstant: 180),
            
            // Character icon
            characterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            characterImageView.widthAnchor.constraint(equalToConstant: 100),
            characterImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Loading indicator
            loadingIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        // Initial state for animations
        portalView.alpha = 0
        portalView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        characterImageView.alpha = 0
        characterImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        loadingIndicator.alpha = 0
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        // Portal animation
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.portalView.alpha = 1
            self.portalView.transform = .identity
        }
        
        portalView.startAnimating()
        
        // Character icon animation
        UIView.animate(
            withDuration: 0.8,
            delay: 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.characterImageView.alpha = 1
            self.characterImageView.transform = .identity
        }
        
        // Title animation
        UIView.animate(
            withDuration: 0.6,
            delay: 0.6,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        
        // Subtitle animation
        UIView.animate(
            withDuration: 0.6,
            delay: 0.8,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }
        
        // Loading indicator
        UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseIn) {
            self.loadingIndicator.alpha = 1
        } completion: { _ in
            self.loadingIndicator.startAnimating()
        }
        
        // Complete and transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.animateOut()
        }
    }
    
    private func animateOut() {
        loadingIndicator.stopAnimating()
        portalView.stopAnimating()
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: .curveEaseIn
        ) {
            self.view.alpha = 0
            self.portalView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.characterImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            self.onAnimationComplete?()
        }
    }
}

// MARK: - Portal Animation View

final class PortalAnimationView: UIView {
    
    private var gradientLayer: CAGradientLayer?
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Create gradient
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor.systemGreen.withAlphaComponent(0.9).cgColor,
            UIColor.systemGreen.withAlphaComponent(0.5).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.3, 0.6, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        layer.addSublayer(gradient)
        gradientLayer = gradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        layer.cornerRadius = bounds.width / 2
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Rotation animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 4
        rotation.repeatCount = .infinity
        layer.add(rotation, forKey: "rotation")
        
        // Pulse animation
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 0.95
        pulse.toValue = 1.08
        pulse.duration = 1.2
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: "pulse")
    }
    
    func stopAnimating() {
        isAnimating = false
        layer.removeAllAnimations()
    }
}

//
//  PhotoDetailViewController.swift
//  RickAndMortyApp
//
//  Full screen photo viewer with zoom and save capabilities.
//  Features: pinch to zoom, double tap zoom, pull to dismiss.
//

import UIKit
import Kingfisher

// MARK: - Photo Detail View Controller

final class PhotoDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: PhotoDetailViewModel
    private var panStartCenter: CGPoint = .zero
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.backgroundColor = .black
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: PhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupGestures()
        loadImage()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        title = viewModel.characterName
        
        // Navigation buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(downloadTapped)
        )
        
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        scrollView.delegate = self
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func setupGestures() {
        // Double tap to zoom
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        // Pull to dismiss
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        scrollView.addGestureRecognizer(pan)
    }
    
    private func loadImage() {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: viewModel.imageURL)
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func downloadTapped() {
        guard let image = imageView.image else { return }
        
        Task {
            do {
                try await viewModel.saveToGallery(image)
                await MainActor.run {
                    showSuccess(message: L10n.Photo.saved)
                }
            } catch {
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let rect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            panStartCenter = imageView.center
            
        case .changed:
            guard translation.y > 0 else { return }
            imageView.center = CGPoint(x: panStartCenter.x, y: panStartCenter.y + translation.y)
            let progress = min(translation.y / 300, 1.0)
            view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress * 0.6)
            
        case .ended, .cancelled:
            if translation.y > 120 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imageView.center = self.panStartCenter
                    self.view.backgroundColor = .black
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PhotoDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

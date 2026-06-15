//
//  PicsumPhotoCell.swift
//  RickAndMortyApp
//
//  Cell for displaying Picsum photos fetched from xcconfig URL.
//

import UIKit
import Kingfisher

// MARK: - Picsum Photo Cell

final class PicsumPhotoCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "PicsumPhotoCell"
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemGray5
        
        contentView.addSubview(imageView)
        contentView.addSubview(authorLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            authorLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with photo: PicsumPhoto) {
        authorLabel.text = photo.author
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: photo.thumbnailURL,
            options: [.transition(.fade(0.2)), .cacheOriginalImage]
        )
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
}

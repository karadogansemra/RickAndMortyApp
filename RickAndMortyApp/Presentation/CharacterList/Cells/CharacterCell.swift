//
//  CharacterCell.swift
//  RickAndMortyApp
//
//  Collection view cell for displaying a character.
//

import UIKit
import Kingfisher

// MARK: - Character Cell

final class CharacterCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "CharacterCell"
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusDot, nameLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(labelStack)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8),
            
            labelStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            labelStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            labelStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            labelStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with character: CharacterEntity) {
        nameLabel.text = character.name
        statusDot.backgroundColor = statusColor(for: character.status)
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: character.imageURL,
            placeholder: UIImage(systemName: "person.crop.square"),
            options: [.transition(.fade(0.2)), .cacheOriginalImage]
        )
    }
    
    private func statusColor(for status: CharacterStatus) -> UIColor {
        switch status {
        case .alive: return .systemGreen
        case .dead: return .systemRed
        case .unknown: return .systemGray
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
}

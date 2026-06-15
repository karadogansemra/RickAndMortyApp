//
//  CharacterListViewController.swift
//  RickAndMortyApp
//
//  Main screen showing character list and gallery photos.
//  Uses UICollectionViewCompositionalLayout with DiffableDataSource.
//

import UIKit

// MARK: - Character List View Controller

final class CharacterListViewController: UIViewController {
    
    // MARK: - Type Aliases
    
    typealias DataSource = UICollectionViewDiffableDataSource<ListSection, ListItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ListSection, ListItem>
    
    // MARK: - Properties
    
    private let viewModel: CharacterListViewModel
    private weak var coordinator: CharacterListCoordinator?
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    
    // MARK: - Initialization
    
    init(viewModel: CharacterListViewModel, coordinator: CharacterListCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupDataSource()
        setupNavigationBar()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = L10n.CharacterList.title
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        configureNavigationBarAppearance()
        setupSortMenu()
    }
    
    private func setupSortMenu() {
        let menuItems = PhotoSortOrder.allCases.map { order in
            UIAction(
                title: order.localizedDisplayName,
                image: UIImage(systemName: order.iconName)
            ) { [weak self] _ in
                self?.viewModel.setSortOrder(order)
            }
        }
        
        let menu = UIMenu(title: L10n.CharacterList.sortTitle, children: menuItems)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            menu: menu
        )
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        
        // Register cells
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.reuseIdentifier)
        collectionView.register(GalleryPhotoCell.self, forCellWithReuseIdentifier: GalleryPhotoCell.reuseIdentifier)
        collectionView.register(PicsumPhotoCell.self, forCellWithReuseIdentifier: PicsumPhotoCell.reuseIdentifier)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // MARK: - Layout
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self,
                  let snapshot = self.dataSource?.snapshot(),
                  sectionIndex < snapshot.sectionIdentifiers.count else {
                // Fallback: use rawValue mapping
                guard let section = ListSection(rawValue: sectionIndex) else { return nil }
                switch section {
                case .gallery, .picsumPhotos:
                    return self?.createGallerySection()
                case .characters:
                    return self?.createCharactersSection(environment: environment)
                }
            }
            
            let section = snapshot.sectionIdentifiers[sectionIndex]
            switch section {
            case .gallery, .picsumPhotos:
                return self.createGallerySection()
            case .characters:
                return self.createCharactersSection(environment: environment)
            }
        }
    }
    
    private func createGallerySection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(96),
            heightDimension: .absolute(96)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(96),
            heightDimension: .absolute(96)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12)
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createCharactersSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let columns = columnCount(for: environment.container.effectiveContentSize.width)
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: columns)
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 12, trailing: 6)
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(36)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    private func columnCount(for width: CGFloat) -> Int {
        switch width {
        case ..<400: return 2
        case 400..<700: return 3
        default: return 4
        }
    }
    
    // MARK: - Data Source
    
    private func setupDataSource() {
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            self?.configureCell(for: collectionView, at: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! SectionHeaderView
            
            // Read section from snapshot to match correctly
            if let snapshot = self?.dataSource?.snapshot(),
               indexPath.section < snapshot.sectionIdentifiers.count {
                let section = snapshot.sectionIdentifiers[indexPath.section]
                switch section {
                case .gallery:
                    header.configure(title: L10n.CharacterList.gallerySection)
                case .picsumPhotos:
                    header.configure(title: "Picsum Photos")
                case .characters:
                    header.configure(title: L10n.CharacterList.charactersSection)
                }
            }
            
            return header
        }
    }
    
    private func configureCell(
        for collectionView: UICollectionView,
        at indexPath: IndexPath,
        item: ListItem
    ) -> UICollectionViewCell {
        switch item {
        case .galleryPhoto(let photo):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryPhotoCell.reuseIdentifier,
                for: indexPath
            ) as! GalleryPhotoCell
            cell.configure(with: photo, useCase: DependencyContainer.shared.makeGalleryPhotosUseCase())
            return cell
            
        case .picsumPhoto(let photo):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PicsumPhotoCell.reuseIdentifier,
                for: indexPath
            ) as! PicsumPhotoCell
            cell.configure(with: photo)
            return cell
            
        case .character(let character):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterCell.reuseIdentifier,
                for: indexPath
            ) as! CharacterCell
            cell.configure(with: character)
            return cell
            
        case .loading:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: LoadingCell.reuseIdentifier,
                for: indexPath
            )
        }
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.onItemsChanged = { [weak self] in
            self?.applySnapshot()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: L10n.General.error, message: message)
        }
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        
        let galleryItems = viewModel.items(for: .gallery)
        if !galleryItems.isEmpty {
            snapshot.appendSections([.gallery])
            snapshot.appendItems(galleryItems, toSection: .gallery)
        }
        
        // TODO: Uncomment to enable Picsum Photos section
        // let picsumItems = viewModel.items(for: .picsumPhotos)
        // if !picsumItems.isEmpty {
        //     snapshot.appendSections([.picsumPhotos])
        //     snapshot.appendItems(picsumItems, toSection: .picsumPhotos)
        // }
        
        snapshot.appendSections([.characters])
        snapshot.appendItems(viewModel.items(for: .characters), toSection: .characters)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Actions
    
    @objc private func handleRefresh() {
        Task {
            await viewModel.refresh()
            await MainActor.run {
                collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension CharacterListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .character(let character):
            coordinator?.showCharacterDetail(character)
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard ListSection(rawValue: indexPath.section) == .characters else { return }
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.item)
    }
}

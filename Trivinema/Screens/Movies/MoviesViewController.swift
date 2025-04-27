//
//  MoviesViewController.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class MoviesViewController: UIViewController {
    private lazy var collectionView: UICollectionView =  {
        let layout             = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection         = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var scrollToTopBadge: TNBadgeView = {
        let badge = TNBadgeView(title: "Scroll to top", size: .button, color: .clear)
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.alpha = 0
        badge.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
        badge.addGestureRecognizer(tapGesture)
        
        return badge
    }()
    
    private let segmentedControl    = UISegmentedControl(items: ["Now Playing", "Popular", "Upcoming"])
    private let searchController    = UISearchController(searchResultsController: nil)
    
    private var movies: [MoviewOverview]         = []
    private var filteredMovies: [MoviewOverview] = []
    private var currPage                         = 1
    private var currCategory: MovieCategory      = .nowPlaying
    private var isLoadingMoreMovies              = false
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupLayout()
        fetchMovies(for: .nowPlaying)
    }
}

// MARK: - Styles
extension MoviesViewController {
    private func setupStyles(){
        navigationItem.title = "About Movies 🎬"
        configureSegmentedControl()
        configureCollectionView()
        configureSearchController()
        setupScrollTopBadge()
    }
    private func setupLayout(){
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureCollectionView(){
        collectionView.delegate             = self
        collectionView.dataSource           = self
        collectionView.register(TNItemCollectionViewCell.self, forCellWithReuseIdentifier: TNItemCollectionViewCell.identifier)
        collectionView.prefetchDataSource   = self
        collectionView.decelerationRate     = .fast
        view.addSubview(collectionView)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let spacing: CGFloat                = 8
            flowLayout.minimumInteritemSpacing  = spacing
            flowLayout.minimumLineSpacing       = spacing
            flowLayout.sectionInset             = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        }
        
        collectionView.alpha = 0
        UIView.animate(withDuration: 0.8) {
            self.collectionView.alpha = 1
        }
    }
    
    private func configureSegmentedControl(){
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        view.addSubview(segmentedControl)
    }
    
    private func configureSearchController(){
        searchController.searchResultsUpdater   = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder  = "Search movies..."
        searchController.delegate               = self
        navigationItem.searchController         = searchController
        definesPresentationContext              = true
    }
    
    private func setupScrollTopBadge() {
        view.addSubview(scrollToTopBadge)
        
        NSLayoutConstraint.activate([
            scrollToTopBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollToTopBadge.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12)
        ])
    }
    
    @objc private func scrollToTop() {
        collectionView.setContentOffset(.zero, animated: true)
    }
    
    @objc private func segmentedControlChanged(){
        currPage = 1
        movies.removeAll()
        filteredMovies.removeAll()
        
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve) {
            self.collectionView.reloadData()
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            currCategory = .nowPlaying
            fetchMovies(for: .nowPlaying)
        case 1:
            currCategory = .popular
            fetchMovies(for: .popular)
        case 2:
            currCategory = .upcoming
            fetchMovies(for: .upcoming)
        default:
            break
        }
    }
}

// MARK: -Network
extension MoviesViewController {
    // Fetch movies based on selected category
    private func fetchMovies(for category: MovieCategory, page: Int = 1) {
        if isLoadingMoreMovies { return }
        isLoadingMoreMovies = true
        
        showLoadingView()
        switch category {
        case .nowPlaying:
            NetworkManager.shared.getNowPlaying(page: page) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    self.handleResponse(result, page: page)
                }
            }
        case .popular:
            NetworkManager.shared.getPopular(page: page) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    self.handleResponse(result, page: page)
                }
            }
        case .upcoming:
            NetworkManager.shared.getUpcoming(page: page) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    self.handleResponse(result, page: page)
                }
            }
        }
    }
    
    private func handleResponse(_ result: Result<MovieResponse, AFError>, page: Int){
        isLoadingMoreMovies = false
        
        switch result {
        case .success(let movieResponse):
            let newMovies = movieResponse.results
            
            if page == 1 {
                movies = newMovies
                UIView.transition(with: collectionView, duration: 0.8, options: .transitionCrossDissolve) {
                    self.collectionView.reloadData()
                }
            } else {
                movies.append(contentsOf: newMovies)
                collectionView.reloadData()
            }
            
            if movies.isEmpty {
                print("empty")
            }
            
        case .failure(let error):
            print(error.rawValue)
        }
    }
    
    private func loadMoreIfNeeded(for indexPath: IndexPath){
        let thresholdIndex = movies.count - 5
        if thresholdIndex <= indexPath.row && !isLoadingMoreMovies {
            currPage += 1
            fetchMovies(for: currCategory, page: currPage)
        }
    }
    
    private func filterContentForSearchText(_ searchText: String){
        filteredMovies = movies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        UIView.transition(with: collectionView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.collectionView.reloadData() })
    }
}

// MARK: - Collection View Delegate + Data Source
extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredMovies.count : movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TNItemCollectionViewCell.identifier, for: indexPath) as? TNItemCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        // Ensure we don't access an index that is out of bounds
        let dataSource = isSearching ? filteredMovies : movies
        guard indexPath.row < dataSource.count else {
            return cell
        }
        
        let movie = dataSource[indexPath.row]
        cell.configure(with: movie)
        
        if !isSearching {
            loadMoreIfNeeded(for: indexPath)
        }
        
        return cell
    }
}

// MARK: - Collection Flow
extension MoviesViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat        = 8
        // 4 : trailing + leading + between center spacing leading & trailing
        let totalWidth: CGFloat     = collectionView.bounds.width - (spacing * 4)
        let width: CGFloat          = totalWidth / 3
        let height: CGFloat         = width * 1.5
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Collection Data Source Prefetching
extension MoviesViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if isSearching { return }
        
        for indexPath in indexPaths {
            // Prevent out of bounds access
            if indexPath.row < movies.count && indexPath.row >= movies.count - 5 && !isLoadingMoreMovies {
                currPage += 1
                fetchMovies(for: currCategory, page: currPage)
                break
            }
        }
    }
}

//MARK: - Search result updating
extension MoviesViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {return}
        filterContentForSearchText(searchText)
    }
}

// MARK: - SearchController Delegate
extension MoviesViewController: UISearchControllerDelegate{
    func willPresentSearchController(_ searchController: UISearchController) {
        // Animate when search appears
        UIView.animate(withDuration: 0.3) {
            self.segmentedControl.alpha = 0
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        // Animate when search disappears
        UIView.animate(withDuration: 0.3) {
            self.segmentedControl.alpha = 1
        }
        
        // Smooth transition back to normal results
        UIView.transition(with: collectionView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.collectionView.reloadData() })
    }
}

// MARK: - Scroll View Delegate
extension MoviesViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollThreshold: CGFloat = 30
        
        // Show the badge when scrolled down beyond threshold
        if scrollView.contentOffset.y > scrollThreshold && scrollToTopBadge.alpha == 0 {
            UIView.animate(withDuration: 0.3) {
                self.scrollToTopBadge.alpha = 1
                
                // Add a subtle entrance animation from bottom
                self.scrollToTopBadge.transform = CGAffineTransform(translationX: 0, y: 20)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                    self.scrollToTopBadge.transform = .identity
                })
            }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        }
        // Hide the badge when near the top
        else if scrollView.contentOffset.y < scrollThreshold && scrollToTopBadge.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.scrollToTopBadge.alpha = 0
            }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // If user scrolled to top without the badge, ensure it's hidden
        if scrollView.contentOffset.y < 50 {
            UIView.animate(withDuration: 0.2) {
                self.scrollToTopBadge.alpha = 0
            }
        }
    }
    
}

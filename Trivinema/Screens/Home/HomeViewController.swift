//
//  HomeViewController.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

enum HomeSection: Int, CaseIterable {
    case nowPlayingMovies
    case trendingSeries
    case popularArtist

    var title: String {
        switch self {
        case .nowPlayingMovies  : return "Now Playing Movies"
        case .trendingSeries    : return "Trending TV Series"
        case .popularArtist     : return "Popular Artists"
        }
    }
}

class HomeViewController: UIViewController {

    private let headerView = HomeHeaderView()
    private var headerViewTopConstraint: NSLayoutConstraint?
    
    private let tableView = UITableView()
    
    private var movies: [MoviewOverview] = [] {
        didSet {
            // Update headerView when movies updated
            if let firstMovie = movies.first {
                headerView.configure(with: firstMovie)
            }
        }
    }
    
    // Sections and tiles
    let sections = HomeSection.allCases
    private var tiles: [[any OverviewPresentable]] = Array(repeating: [], count: HomeSection.allCases.count)
    var height: CGFloat = 0.0
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenHeight <= 667 { // iPhone SE (1st, 2nd gen) and similar
            height = 300
        } else if screenHeight <= 736 { // iPhone 8 Plus
            height = 380
        } else {
            height = 420
        }
        setupTableView()
        configureStyles()
        configureLayout()
        getOverviewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Network Call

extension HomeViewController {
    private func getOverviewData() {
        showLoadingView()
        
        let fetchGroup = DispatchGroup()
        
        // Fetch Movies
        fetchGroup.enter()
        NetworkManager.shared.getNowPlaying(page: 1) { [weak self] result in
            guard let self = self else {
                fetchGroup.leave()
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.movies.append(contentsOf: response.results)
                    self.tiles[HomeSection.nowPlayingMovies.rawValue] = Array(response.results.prefix(10))
                case .failure(let error):
                    print(error.rawValue)
                }
                fetchGroup.leave()  // Leave the group inside the closure after the data handling
            }
        }

        // Fetch Trending Series
        fetchGroup.enter()
        NetworkManager.shared.getTrendingSeries(page: 1) { [weak self] result in
            guard let self = self else {
                fetchGroup.leave()
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.tiles[HomeSection.trendingSeries.rawValue] = Array(response.results.prefix(10))
                case .failure(let error):
                    print(error.rawValue)
                }
                fetchGroup.leave()  // Leave the group inside the closure after the data handling
            }
        }
        
        // Fetch Popular Artist
        fetchGroup.enter()
        NetworkManager.shared.getPopularPerson(page: 1) { [weak self] result in
            guard let self = self else {
                fetchGroup.leave()
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.tiles[HomeSection.popularArtist.rawValue] = Array(response.results.prefix(10))
                case .failure(let error):
                    print(error.rawValue)
                }
                fetchGroup.leave()
            }
        }

        
        // Finally
        fetchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {return}
            self.hideLoadingView()
            self.tableView.reloadData()
        }
    }
}

// MARK: - Styles Configuration

extension HomeViewController {
    private func configureStyles() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
    }
    
    private func configureLayout() {
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            headerViewTopConstraint!,
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: height),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - TableView

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.register(TNHomeSectionCell.self, forCellReuseIdentifier: TNHomeSectionCell.identifier)
        // Add bottom padding
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        footerView.backgroundColor  = .clear
        tableView.tableFooterView   = footerView
        tableView.separatorColor    = .clear
        tableView.decelerationRate  = .fast
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Only 1 horizontal list per section
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = TNCollectionTitleView()
        titleView.set(title: sections[section].title) {
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = section + 1
            }
        }
        return titleView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TNHomeSectionCell.identifier,for: indexPath) as? TNHomeSectionCell else {
            return UITableViewCell()
        }

        cell.tilesSection = tiles[indexPath.section]
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y                   = scrollView.contentOffset.y
        let swipingDownAt       = y <= 0
        let shouldSnapHeaderAt  = y > 8
        let labelHeight         = headerView.overviewSection.frame.height + 16 + view.safeAreaInsets.top
        
        UIView.animate(withDuration: 0.8) {
            self.headerView.overviewSection.alpha = swipingDownAt ? 1 : 0
        }
         
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0) {
            self.headerViewTopConstraint?.constant = shouldSnapHeaderAt ? -labelHeight : 0
            self.view.layoutIfNeeded()
        }
  
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0) {
            if shouldSnapHeaderAt {
                self.navigationItem.title = "Explore"
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor     = .systemBackground
                appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
                
                self.navigationController?.navigationBar.standardAppearance     = appearance
                self.navigationController?.navigationBar.scrollEdgeAppearance   = appearance
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            } else {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
            
        }
    }
}

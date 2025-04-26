//
//  HomeViewController.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

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
    
    let cellId = "cellId"
    let tiles = [
        "Star wars",
        "Bonus Track",
        "Despicable Me",
        "Hangover 3"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        NetworkManager.shared.getNowPlaying(page: 1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoadingView()
                
                switch result {
                case .success(let response):
                    self.movies.append(contentsOf: response.results)
                case .failure(let error):
                    print(error.rawValue)
                }
            }
        }
    }
}

// MARK: - Styles Configuration

extension HomeViewController {
    private func configureStyles() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLayout() {
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            headerViewTopConstraint!,
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 420),
            
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
        tableView.dataSource        = self
        tableView.delegate          = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView   = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text    = tiles[indexPath.row]
        cell.accessoryType      = .disclosureIndicator
        
        return cell
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y                   = scrollView.contentOffset.y
        let swipingDownAt       = y <= 0
        let shouldSnapHeaderAt  = y > 15
        let labelHeight         = headerView.overviewSection.frame.height + 16 * 10
        
        UIView.animate(withDuration: 0.3) {
            self.headerView.overviewSection.alpha = swipingDownAt ? 1 : 0
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
            self.headerViewTopConstraint?.constant = shouldSnapHeaderAt ? -labelHeight : 0
            if shouldSnapHeaderAt {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.title = "Explore"
            } else {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
            self.view.layoutIfNeeded()
        }
    }
}

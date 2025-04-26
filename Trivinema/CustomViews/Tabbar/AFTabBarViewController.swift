//
//  AFTabBarViewController.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class AFTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UITabBarAppearance()
         appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThickMaterial)
         appearance.backgroundColor = .clear
         
         tabBar.standardAppearance = appearance
         if #available(iOS 15.0, *) {
             tabBar.scrollEdgeAppearance = appearance
         }
        
        self.tabBar.tintColor       = .systemRed
        self.viewControllers        = [
            createHomeNavController(), createMoviesNavController(),
            createTVNavController(), createActorsNavController()
        ]
    }
 
    private func createHomeNavController() -> UINavigationController {
        let homeViewController        = HomeViewController()
        let icon                      = AFSfSymbolImageView.makeImage(symbol: .home)
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: icon, tag: 0)
        
        return UINavigationController(rootViewController: homeViewController)
    }

    private func createMoviesNavController() -> UINavigationController {
        let moviesViewController        = MoviesViewController()
        let icon                        = AFSfSymbolImageView.makeImage(symbol: .movies)
        moviesViewController.tabBarItem = UITabBarItem(title: "Movies", image: icon, tag: 1)
        
        return UINavigationController(
            rootViewController: moviesViewController)
    }
    
    private func createTVNavController() -> UINavigationController {
        let tvViewController         = TvViewController()
        let icon                     = AFSfSymbolImageView.makeImage(symbol: .tv)
        tvViewController.tabBarItem  = UITabBarItem(title: "Series", image: icon, tag: 2)
        
        return UINavigationController(rootViewController: tvViewController)
    }
    
    private func createActorsNavController() -> UINavigationController{
        let actorViewController        = ActorsViewController()
        let icon                       = AFSfSymbolImageView.makeImage(symbol: .actor)
        actorViewController.tabBarItem = UITabBarItem(title: "Actors", image: icon, tag: 3)
        
        return UINavigationController(rootViewController: actorViewController)
    }
}

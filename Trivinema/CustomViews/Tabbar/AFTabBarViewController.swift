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
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
         appearance.backgroundColor = .clear
        delegate = self
         
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
        let moviesViewController        = MediaViewController(provider: MovieProvider())
        let icon                        = AFSfSymbolImageView.makeImage(symbol: .movies)
        moviesViewController.tabBarItem = UITabBarItem(title: "Movies", image: icon, tag: 1)
        
        return UINavigationController(
            rootViewController: moviesViewController)
    }
    
    private func createTVNavController() -> UINavigationController {
        let tvViewController         = MediaViewController(provider: TvSeriesProvider())
        let icon                     = AFSfSymbolImageView.makeImage(symbol: .tv)
        tvViewController.tabBarItem  = UITabBarItem(title: "Series", image: icon, tag: 2)
        
        return UINavigationController(rootViewController: tvViewController)
    }
    
    private func createActorsNavController() -> UINavigationController{
        let actorViewController        = MediaViewController(provider: ArtistsProvider())
        let icon                       = AFSfSymbolImageView.makeImage(symbol: .actor)
        actorViewController.tabBarItem = UITabBarItem(title: "Artists", image: icon, tag: 3)
        
        return UINavigationController(rootViewController: actorViewController)
    }
}

extension AFTabBarViewController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(viewControllers: tabBarController.viewControllers)
    }
}

class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.4

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}

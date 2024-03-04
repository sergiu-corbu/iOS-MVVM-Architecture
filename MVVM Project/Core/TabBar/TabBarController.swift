//
//  TabBarController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2022.
//

import UIKit

final class TabBarController: UITabBarController {
    
    var selectedTab: TabBarItemType? {
        get { return TabBarItemType(rawValue: selectedIndex) }
        set {
            if let newIndex = newValue?.rawValue {
                selectedIndex = newIndex
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: Configuration
    private func configureTabBar() {
        tabBar.isMultipleTouchEnabled = false
        tabBar.layer.masksToBounds = false
        tabBar.layer.cornerRadius = 2
        tabBar.clipsToBounds = true
        
        addTopBorderLayer()
        configureTabBarAppearance()
    }
    
    private func addTopBorderLayer() {
        let topBorderLayer = CALayer()
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1)
        topBorderLayer.backgroundColor = UIColor.ebony.withAlphaComponent(0.15).cgColor
        tabBar.layer.addSublayer(topBorderLayer)
    }
    
    private func configureTabBarAppearance() {
        let tabBarItemAppearance = UITabBarItemAppearance()
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.backgroundColor = .cultured.withAlphaComponent(0.35)
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    func changeTabViewController(_ newViewController: UIViewController, for tabBarItemType: TabBarItemType, animated: Bool = true) {
        let newTabIndex = indexForTab(tabBarItemType)
        if animated {
            UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
                self?.viewControllers?[newTabIndex] = newViewController
            }
        } else {
            viewControllers?[newTabIndex] = newViewController
        }
    }
    
    func indexForTab(_ tabBarItemType: TabBarItemType) -> Int {
        guard let viewController = viewControllers?[tabBarItemType.rawValue] else {
            return 0
        }
        return viewControllers?.firstIndex(of: viewController) ?? 0
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        if let viewControllers = tabBarController.viewControllers {
            return TabBarAnimatedTransition(viewControllers: viewControllers)
        }
        return nil
    }
}

extension UIViewController {
    
    func configureTabBarItem(_ item: TabBarController.TabBarItemType) {
        tabBarItem.image = item.image
        tabBarItem.selectedImage = item.selectedImage
        tabBarItem.title = nil
        tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
    }
}

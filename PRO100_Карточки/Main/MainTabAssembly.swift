//
//  MainTabAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - MainTabAssembly
final class MainTabAssembly {
    func makeModule() -> UIViewController {
        let setsAssembly = SetsListAssembly()
        let setsNav = UINavigationController(rootViewController: setsAssembly.makeModule())
        setsNav.tabBarItem = UITabBarItem(title: "Наборы", image: UIImage(systemName: "folder"), tag: 0)

        let cardsAssembly = CardsListAssembly()
        let cardsNav = UINavigationController(rootViewController: cardsAssembly.makeModule())
        cardsNav.tabBarItem = UITabBarItem(title: "Карточки", image: UIImage(systemName: "rectangle.stack"), tag: 1)

        let publicAssembly = PublicListAssembly()
        let publicNav = UINavigationController(rootViewController: publicAssembly.makeModule())
        publicNav.tabBarItem = UITabBarItem(title: "Публичные", image: UIImage(systemName: "globe"), tag: 2)

        let profileAssembly = ProfileAssembly()
        let profileNav = UINavigationController(rootViewController: profileAssembly.makeModule())
        profileNav.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person"), tag: 3)

        let tabBar = UITabBarController()
        tabBar.viewControllers = [setsNav, cardsNav, publicNav, profileNav]
        tabBar.tabBar.tintColor = AppConstants.accentColor
        return tabBar
    }
}

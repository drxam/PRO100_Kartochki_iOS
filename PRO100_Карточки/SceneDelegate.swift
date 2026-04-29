//
//  SceneDelegate.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SceneDelegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        UITabBar.applyDarkStyle()
        window.overrideUserInterfaceStyle = .dark
        let assembly = AppAssembly()
        let rootVC = AuthStorage.shared.isAuthorized ? assembly.makeMainTabModule() : assembly.makeAuthModule()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}


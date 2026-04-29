//
//  AppAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - AppAssembly
final class AppAssembly {
    func makeAuthModule() -> UIViewController {
        let assembly = LoginAssembly()
        return assembly.makeModule()
    }

    func makeMainTabModule() -> UIViewController {
        let assembly = MainTabAssembly()
        return assembly.makeModule()
    }
}

//
//  ProfileEditAssembly.swift
//  PRO100_Карточки
//

import UIKit

// MARK: - ProfileEditAssembly
final class ProfileEditAssembly {
    func makeModule(profile: UserProfileModel) -> UIViewController {
        let vc = ProfileEditViewController(profile: profile)
        return vc
    }
}

import UIKit

final class ProfileEditAssembly {
    func makeModule(profile: UserProfileModel) -> UIViewController {
        let vc = ProfileEditViewController(profile: profile)
        return vc
    }
}

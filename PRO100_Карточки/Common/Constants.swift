//
//  Constants.swift
//  PRO100_Карточки
//

import UIKit

enum AppConstants {
    static let accentColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1) // #007AFF
}

enum ValidationRules {
    static let minPasswordLength = 8

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func hasLettersAndDigits(_ password: String) -> Bool {
        let hasLetters = password.range(of: #"[A-Za-zА-Яа-я]"#, options: .regularExpression) != nil
        let hasDigits = password.range(of: #"\d"#, options: .regularExpression) != nil
        return hasLetters && hasDigits
    }
}

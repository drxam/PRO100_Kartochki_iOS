//
//  AppDesign.swift
//  PRO100_Карточки
//


import UIKit


// MARK: - DS
enum DS {
    static let bgTop     = UIColor(red: 0.04, green: 0.06, blue: 0.18, alpha: 1)
    static let bgMid     = UIColor(red: 0.05, green: 0.16, blue: 0.46, alpha: 1)
    static let bgBot     = UIColor(red: 0.16, green: 0.04, blue: 0.07, alpha: 1)

    static let crimson   = UIColor(red: 0.88, green: 0.16, blue: 0.14, alpha: 1)
    static let royal     = UIColor(red: 0.06, green: 0.28, blue: 0.88, alpha: 1)

    static let glass     = UIColor.white.withAlphaComponent(0.09)
    static let glassBdr  = UIColor.white.withAlphaComponent(0.18)
    static let surface   = UIColor.white.withAlphaComponent(0.06)

    static let textPrim  = UIColor.white
    static let textDim   = UIColor.white.withAlphaComponent(0.55)
    static let textMuted = UIColor.white.withAlphaComponent(0.35)

    static let field     = UIColor.white.withAlphaComponent(0.11)
    static let fieldBdr  = UIColor.white.withAlphaComponent(0.28)
}


// MARK: - UIFont Extension
extension UIFont {
    static func app(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let desc = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: desc, size: size)
    }
}


// MARK: - UIViewController Extension
extension UIViewController {
    func applyDarkNavBar() {
        let app = UINavigationBarAppearance()
        app.configureWithOpaqueBackground()
        app.backgroundColor = DS.bgTop.withAlphaComponent(0.97)
        app.shadowColor = .clear
        app.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.app(17, .bold)
        ]
        app.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.app(34, .black)
        ]
        navigationController?.navigationBar.standardAppearance   = app
        navigationController?.navigationBar.scrollEdgeAppearance = app
        navigationController?.navigationBar.compactAppearance    = app
        navigationController?.navigationBar.tintColor = .white
    }
}


// MARK: - UIView Extension
extension UIView {
    func applyGlassCard(cornerRadius r: CGFloat = 20) {
        backgroundColor   = DS.glass
        layer.cornerRadius = r
        layer.cornerCurve  = .continuous
        layer.borderWidth  = 1
        layer.borderColor  = DS.glassBdr.cgColor
        layer.shadowColor  = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius  = 18
        layer.shadowOffset  = CGSize(width: 0, height: 8)
    }
}


func applyAppBackground(to view: UIView,
                         bgLayer: CAGradientLayer,
                         orbA: UIView,
                         orbB: UIView,
                         orbC: UIView) {
    bgLayer.colors    = [DS.bgTop.cgColor, DS.bgMid.cgColor, DS.bgBot.cgColor]
    bgLayer.locations = [0, 0.52, 1]
    bgLayer.startPoint = CGPoint(x: 0.25, y: 0)
    bgLayer.endPoint   = CGPoint(x: 0.75, y: 1)
    view.layer.insertSublayer(bgLayer, at: 0)

    func configOrb(_ v: UIView, fill: UIColor, glow: UIColor) {
        v.backgroundColor       = fill
        v.layer.shadowColor     = glow.cgColor
        v.layer.shadowOpacity   = 0.75
        v.layer.shadowRadius    = 50
        v.layer.shadowOffset    = .zero
        view.addSubview(v)
    }
    configOrb(orbA, fill: UIColor.white.withAlphaComponent(0.10), glow: .white)
    configOrb(orbB, fill: DS.royal.withAlphaComponent(0.18), glow: DS.royal)
    configOrb(orbC, fill: DS.crimson.withAlphaComponent(0.14), glow: DS.crimson)
}

func layoutAppOrbs(_ orbA: UIView, _ orbB: UIView, _ orbC: UIView, in view: UIView) {
    let w = view.bounds.width; let h = view.bounds.height
    func place(_ v: UIView, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        v.frame = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
        v.layer.cornerRadius = r
    }
    place(orbA, cx: w * 0.85, cy: h * 0.07, r: 80)
    place(orbB, cx: w * 0.10, cy: h * 0.40, r: 100)
    place(orbC, cx: w * 0.90, cy: h * 0.88, r: 90)
}


// MARK: - UITabBar Extension
extension UITabBar {
    static func applyDarkStyle() {
        let app = UITabBarAppearance()
        app.configureWithOpaqueBackground()
        app.backgroundColor = UIColor(red: 0.04, green: 0.06, blue: 0.18, alpha: 0.97)
        app.shadowColor = .clear

        let item = UITabBarItemAppearance()
        item.normal.iconColor    = UIColor.white.withAlphaComponent(0.40)
        item.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.40),
                                           .font: UIFont.app(10, .semibold)]
        item.selected.iconColor  = DS.royal
        item.selected.titleTextAttributes = [.foregroundColor: DS.royal,
                                             .font: UIFont.app(10, .bold)]
        app.stackedLayoutAppearance = item
        app.inlineLayoutAppearance  = item
        app.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance   = app
        UITabBar.appearance().scrollEdgeAppearance = app
    }
}

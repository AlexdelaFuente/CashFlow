//
//  SceneDelegate.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 17/6/24.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        setupWindow(with: scene)
    }
    
    
    private func setupWindow(with scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // This changes the color of the Alert's default style buttons
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.accent
        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: Screens.mainStoryboard, bundle: nil)
        
        let navigationController = Factory.provideNavigationController(storyboard: storyboard)
        window?.rootViewController = navigationController
        
        DispatchQueue.main.async {
            let shouldShowLogin = self.checkAuthentication()
            
            if let loginVC = navigationController.topViewController as? LoginViewController {
                loginVC.showHomeIfNeeded(shouldShowLogin: shouldShowLogin)
            }
        }
        
        if checkAuthentication() {
            self.window?.makeKeyAndVisible()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.window?.makeKeyAndVisible()
            }
        }
        
        
    }
    
    
    /// Checks if the user is signed in
    /// - Returns: if the user is signed in or not
    private func checkAuthentication() -> Bool { return Auth.auth().currentUser == nil }
}


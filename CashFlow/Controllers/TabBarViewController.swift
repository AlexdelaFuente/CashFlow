//
//  TabBarViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 20/6/24.
//

import UIKit


protocol TabBarViewControllerDelegate: AnyObject {
    func usernameHasLoad()
}


class TabBarViewController: UITabBarController {
    
    public weak var delegt: TabBarViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tabBar.unselectedItemTintColor =  .label.withAlphaComponent(0.7)
        
    }
    
    
    /// Fetchs the user from the database, then notifies his child ViewController that it has been completed.
    private func fetchUser() {
        AuthService.shared.fetchUser { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showFetchingUserError(on: self, with: error)
            }
            
            if let user = user {
                User.shared = user
                delegt?.usernameHasLoad()
            } else {
                AlertManager.showUnknownFetchingUserError(on: self)
            }
        }
    }
    
}



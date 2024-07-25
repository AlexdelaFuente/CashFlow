//
//  AccountViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 20/6/24.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    
    deinit {
        removeMenuNotification()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMenuNotification()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateUsername()
    }
    
    
    private func addMenuNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(menuDidHide), name: UIMenuController.willHideMenuNotification, object: nil)
    }
    
    
    private func removeMenuNotification() {
        NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
    }
    
    
    private func animateUsername() {
        if nameLabel.text != User.shared.username {
            UIView.animate(withDuration: 0.2, animations: {
                self.nameLabel.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            }) { _ in
                self.nameLabel.layer.opacity = 0
                self.nameLabel.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
                self.setupUI()
                UIView.animate(withDuration: 0.2, animations: {
                    self.nameLabel.layer.opacity = 1
                    self.nameLabel.transform = .identity
                })
            }
        } else {
            setupUI()
        }
    }
    
    
    private func setupUI() {
        nameLabel.text = User.shared.username
        emailLabel.text = User.shared.email
    }
    
    
    @IBAction func emailLongPressed(_ sender: Any) {
        guard let gestureRecognizer = sender as? UILongPressGestureRecognizer,
              let label = gestureRecognizer.view as? UILabel else {
            return
        }
        
        if gestureRecognizer.state == .began {
            UIView.animate(withDuration: 0.3, animations: {
                label.textColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
                label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            
            
            let menuController = UIMenuController.shared
            
            let copyAction = UIMenuItem(title: "Copy", action: #selector(copyText(_:)))
            menuController.menuItems = [copyAction]
            
            let menuLocation = gestureRecognizer.location(in: label)
            let menuRect = CGRect(x: menuLocation.x, y: menuLocation.y, width: 0, height: 0)
            menuController.showMenu(from: label, rect: menuRect)
            
            label.becomeFirstResponder()
        }
    }
    
    
    @objc func copyText(_ sender: Any?) {
        UIPasteboard.general.string = emailLabel.text
        
        AlertManager.showCopiedTextAlert(on: self)
        
        UIView.animate(withDuration: 0.3) {
            self.emailLabel.textColor = self.emailLabel.tintColor
            self.emailLabel.transform = CGAffineTransform.identity
        }
    }
    
    
    @objc func menuDidHide() {
        UIView.animate(withDuration: 0.3) {
            self.emailLabel.textColor = .tintColor
            self.emailLabel.transform = CGAffineTransform.identity
        }
    }
}

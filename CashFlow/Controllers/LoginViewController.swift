//
//  LoginViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 17/6/24.
//

import UIKit
import SearchTextField
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: SearchTextField!
    @IBOutlet var passwordTextField: UITextField!
    
    private var isPasswordVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    private func setupTextFields() {
        emailTextField.inlineMode = true
        emailTextField.startFilteringAfter = "@"
        emailTextField.startSuggestingImmediately = true
        emailTextField.filterStrings(["gmail.com", "hotmail.com", "outlook.com", "icloud.com"])
        
        setupPasswordTextField()
    }
    
    
    private func resetView() {
        emailTextField.text = ""
        
        passwordTextField.text = ""
        if !passwordTextField.isSecureTextEntry { togglePasswordVisibility() }
        passwordTextField.rightView?.isHidden = true
    }
    
    
    private func setupPasswordTextField() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        passwordTextField.rightView = button
        passwordTextField.rightViewMode = .always
        passwordTextField.rightView?.isHidden = true
        passwordTextField.delegate = self
    }
    
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        
        let imageSystemName = isPasswordVisible ? SFSymbols.eyeSlash : SFSymbols.eye
        if let button = passwordTextField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageSystemName), for: .normal)
        }
    }
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        let loginUserRequest = LoginUserRequest(
            email: self.emailTextField.text ?? "",
            password: self.passwordTextField.text ?? "")
        
        if !Validator.isValidEmail(for: loginUserRequest.email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        if !Validator.isPasswordValid(for: loginUserRequest.password) {
            AlertManager.showInvalidPasswordAlert(on: self)
            return
        }
        
        
        AuthService.shared.signIn(with: loginUserRequest) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showSignInErrorAlert(on: self, with: error)
                return
            }
            
            if Auth.auth().currentUser!.isEmailVerified {
                view.endEditing(true)
                navigateTabBarController(animated: true)
                resetView()
                
            } else {
                AlertManager.showEmailNotVerifiedAlert(on: self)
                do{
                    try? Auth.auth().signOut()
                }
            }
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
    /// If there is an account signed in, the Home Screen is pushed
    /// - Parameters:
    ///   - shouldShowLogin: if the home screen has to be shown (or if the Login Screen doesnt have to be shown)
    func showHomeIfNeeded(shouldShowLogin: Bool) {
        if !shouldShowLogin {
            navigationController?.isNavigationBarHidden = true
            navigateTabBarController(animated: false)
        }
    }
    
    
    // MARK: - Navigation
    private func navigateRegisterScreen(animated: Bool) {
        let vc = Factory.provideRegisterScreen(storyboard: storyboard!)
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    
    private func navigateForgotPasswordScreen(animated: Bool) {
        let vc = Factory.provideForgotPasswordScreen(storyboard: storyboard!)
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    
    private func navigateTabBarController(animated: Bool) {
        let vc = Factory.provideTabBarController(storyboard: storyboard!)
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    
    @IBAction func showRegisterScreen(_ sender: Any) {
        navigateRegisterScreen(animated: true)
    }
    
    
    @IBAction func showForgotPasswordScreen(_ sender: Any) {
        navigateForgotPasswordScreen(animated: true)
    }
}

// MARK: - UITextFieldDelegate Methods
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if(!textField.text!.isEmpty) {
            textField.rightView?.isHidden = false
        }else {
            textField.rightView?.isHidden = true
        }
    }
}
//
//  LoginViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 17/6/24.
//

import UIKit
import SearchTextField
import FirebaseAuth
import WebKit
import Loady

class LoginViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var emailTextField: SearchTextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var signInButton: LoadyButton!
    
    private var isPasswordVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupWebView()
        setupSignInButton()
        setupKeyboardObservers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    private func setupSignInButton() {
        signInButton.setAnimation(LoadyAnimationType.downloading(with: .init(
            downloadingLabel: (title: "Signing In...", font: UIFont.boldSystemFont(ofSize: 18), textColor : .accent),
            percentageLabel: (font: UIFont.boldSystemFont(ofSize: 0), textColor : .systemBackground),
            downloadedLabel: (title: "Completed.", font: UIFont.boldSystemFont(ofSize: 20), textColor : .accent)
            )
        ))
    }
    
    
    private func setupWebView() {
        webView.layer.masksToBounds = true
        webView.layer.cornerRadius = 16
        webView.translatesAutoresizingMaskIntoConstraints = true
        guard let url = URL(string: "https://my.spline.design/designingfemaleworkersandbankcards-955fdace555fb0402af450b32c83f00d/") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
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
        
        signInButton.startLoading()
        AuthService.shared.signIn(with: loginUserRequest) { [weak self] error in
            guard let self = self else {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self?.signInButton.stopLoading()
                }
                return
            }
            if let error = error {
                AlertManager.showSignInErrorAlert(on: self, with: error)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.signInButton.stopLoading()
                }
                return
            }
            
            if Auth.auth().currentUser!.isEmailVerified {
                view.endEditing(true)
                navigateTabBarController(animated: true)
                resetView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                    self.signInButton.setTitle("Sign In", for: .normal)
                }
                
            } else {
                AlertManager.showEmailNotVerifiedAlert(on: self)
                do{
                    try? Auth.auth().signOut()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.signInButton.stopLoading()
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
    
    
    // MARK: - Keyboard Notifications
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
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

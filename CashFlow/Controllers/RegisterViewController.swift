//
//  RegisterViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 17/6/24.
//

import UIKit
import SearchTextField
import Loady


class RegisterViewController: UIViewController {
    
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: SearchTextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var registerButton: LoadyButton!
    
    private var isPasswordVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupPasswordTextField()
        setupRegisterButton()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        print("will appear register")
    }
    
    
    private func setupRegisterButton() {
        registerButton.setAnimation(LoadyAnimationType.downloading(with: .init(
            downloadingLabel: (title: "Registering...", font: UIFont.boldSystemFont(ofSize: 18), textColor : .accent),
            percentageLabel: (font: UIFont.boldSystemFont(ofSize: 0), textColor : .systemBackground),
            downloadedLabel: (title: "Completed.", font: UIFont.boldSystemFont(ofSize: 20), textColor : .accent)
            )
        ))
    }
    
    
    private func setupTextFields() {
        emailTextField.inlineMode = true
        emailTextField.startFilteringAfter = "@"
        emailTextField.startSuggestingImmediately = true
        emailTextField.filterStrings(["gmail.com", "hotmail.com", "outlook.com", "icloud.com"])
    }
    
    
    private func setupPasswordTextField() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        passwordTextField.rightView = button
        passwordTextField.rightView?.isHidden = true
        passwordTextField.rightViewMode = .always
        passwordTextField.delegate = self
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let registerUserRequest = RegisterUserRequest(
            username: usernameTextField.text ?? "",
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? "")
        
        if !Validator.isValidUsername(for: registerUserRequest.username) {
            AlertManager.showInvalidUsernameAlert(on: self)
            return
        }
        
        if !Validator.isValidEmail(for: registerUserRequest.email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        if !Validator.isPasswordValid(for: registerUserRequest.password) {
            AlertManager.showInvalidPasswordAlert(on: self)
            return
        }
        
        registerButton.startLoading()
        AuthService.shared.registerUser(with: registerUserRequest) { [weak self] wasRegistered, error in
            guard let self = self else {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self?.registerButton.stopLoading()
                }
                return
            }
            
            if let error = error {
                AlertManager.showRegistrationErrorAlert(on: self, with: error)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.registerButton.stopLoading()
                }
                
                return
            }
            
            if wasRegistered {
                AlertManager.showEmailVerificationSentAlert(on: self, email: registerUserRequest.email)
                navigationController?.viewControllers.forEach({ vc in
                    if vc is LoginViewController{
                        let login = vc as! LoginViewController
                        login.emailTextField.text = registerUserRequest.email
                    }
                })
                self.navigationController?.popViewController(animated: true)
            } else {
                AlertManager.showRegistrationErrorAlert(on: self)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.registerButton.stopLoading()
            }
        }
    }
    
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        
        let imageSystemName = isPasswordVisible ? SFSymbols.eyeSlash : SFSymbols.eye
        if let button = passwordTextField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageSystemName), for: .normal)
        }
    }
    
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func dismissVC(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}



//MARK: - UITextFieldDelegate Methods
extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if(!textField.text!.isEmpty) {
            textField.rightView?.isHidden = false
            
        }else {
            textField.rightView?.isHidden = true
        }
    }
}

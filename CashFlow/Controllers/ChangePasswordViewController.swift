//
//  ChangePasswordViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/6/24.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet var oldPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var repeatPasswordTextField: UITextField!
    
    private var isOldPasswordVisible = false
    private var isNewPasswordVisible = false
    private var isRepeatPasswordVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }
    
    
    private func setupView() {
        setupPasswordTextField(oldPasswordTextField, action: #selector(toggleOldPasswordVisibility))
        setupPasswordTextField(newPasswordTextField, action: #selector(toggleNewPasswordVisibility))
        setupPasswordTextField(repeatPasswordTextField, action: #selector(toggleRepeatPasswordVisibility))
    }
    
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    
    @objc private func toggleOldPasswordVisibility() {
        togglePasswordVisibility(for: oldPasswordTextField, isVisible: &isOldPasswordVisible)
    }
    
    
    @objc private func toggleNewPasswordVisibility() {
        togglePasswordVisibility(for: newPasswordTextField, isVisible: &isNewPasswordVisible)
    }
    
    
    @objc private func toggleRepeatPasswordVisibility() {
        togglePasswordVisibility(for: repeatPasswordTextField, isVisible: &isRepeatPasswordVisible)
    }
    
    
    private func togglePasswordVisibility(for textField: UITextField, isVisible: inout Bool) {
        isVisible.toggle()
        textField.isSecureTextEntry = !isVisible
        let imageSystemName = isVisible ? SFSymbols.eyeSlash : SFSymbols.eye
        if let button = textField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageSystemName), for: .normal)
        }
    }
    
    
    private func setupPasswordTextField(_ textField: UITextField, action: Selector) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        textField.rightView?.isHidden = true
        textField.delegate = self
    }
    
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {
        guard let oldPassword = oldPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let repeatPassword = repeatPasswordTextField.text else { return }
        
        if newPassword != repeatPassword {
            AlertManager.passwordsDontMatchAlert(on: self)
            return
        }
        
        if newPassword == oldPassword {
            AlertManager.passwordsCannotBeTheSameAlert(on: self)
            return
        }
        
        if !Validator.isPasswordValid(for: newPassword) {
            AlertManager.showInvalidPasswordAlert(on: self)
            return
        }
        
        AuthService.shared.changePassword(currentPassword: oldPassword, newPassword: newPassword) { error in
            if let error = error {
                AlertManager.failedChangingPasswordAlert(on: self, with: error)
            } else {
                AlertManager.passwordChangedAlert(on: self)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate Methods
extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if !textField.text!.isEmpty {
            textField.rightView?.isHidden = false
        } else {
            textField.rightView?.isHidden = true
        }
    }
}

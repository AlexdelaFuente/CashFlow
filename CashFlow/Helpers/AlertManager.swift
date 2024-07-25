//
//  AlertManager.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 19/6/24.
//

import UIKit

class AlertManager {
    
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
    
    
    private static func showBasicAlertWithAction(on vc: UIViewController, title: String, message: String?, handler: @escaping ((UIAlertAction) -> Void)) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: handler))
            vc.present(alert, animated: true)
        }
    }
    
    
    private static func showYesOrNoAlert(on vc: UIViewController, title: String, message: String?, sureHandler: @escaping ((UIAlertAction) -> Void)) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: sureHandler))
            
            vc.present(alert, animated: true)
        }
    }
    
    
    private static func showCustomAlert(on vc: UIViewController, title: String, image: UIImage?, imageColor: UIColor) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            if let image = image {
                let imageView = UIImageView(image: image)
                alert.view.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.tintColor = imageColor
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
                    imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 45),
                    imageView.widthAnchor.constraint(equalToConstant: 30),
                    imageView.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
            
            vc.present(alert, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                UIView.animate(withDuration: 0.5, animations: {
                    alert.view.frame.origin.x = vc.view.frame.width
                }) { _ in
                    alert.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
}


// MARK: - Show Validation Alerts
extension AlertManager {
    
    public static func showInvalidEmailAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Email", message: "Please enter a valid email.")
    }
    
    
    public static func showInvalidPasswordAlert(on vc: UIViewController) {
        let title = "Invalid Password"
        let message = "Please enter a valid password. The password must be 9 or more digits long and contain at least one special character, one uppercase letter, one lowercase letter and one number."
        self.showBasicAlert(on: vc, title: title, message: message)
    }
    
    
    public static func showInvalidNumberAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Phone Number", message: "Please enter a valid phone number.")
    }
    
    
    public static func showInvalidUsernameAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Username", message: "Please enter a valid username.")
    }
}


// MARK: - Registration Errors
extension AlertManager {
    
    public static func showRegistrationErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Unknown Registration Error", message: nil)
    }
    
    
    public static func showRegistrationErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Registration Error", message: "\(error.localizedDescription)")
    }
}


// MARK: - Log In Errors
extension AlertManager {
    
    public static func showSignInErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Unknown Error Signing In", message: nil)
    }
    
    
    public static func showSignInErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Signing In", message: "\(error.localizedDescription)")
    }
    
    
    public static func showEmailNotVerifiedAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Email not verified", message: "Please verify your email before signing in.")
    }
}


// MARK: - Log Out Errors
extension AlertManager {
    
    public static func showLogOutErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Log Out Error", message: "\(error.localizedDescription)")
    }
}


// MARK: - Forgot Password Errors
extension AlertManager {
    
    public static func showPasswordResetSent(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Password Reset Sent", message: "Please check your inbox.")
    }
    
    
    public static func showErrorSendingPasswordReset(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Sending Password Reset", message: "\(error.localizedDescription)")
    }
}


// MARK: - Fetching User Errors
extension AlertManager {
    
    public static func showUnknownFetchingUserError(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Unknown Error Fetching User", message: nil)
    }
    
    
    public static func showFetchingUserError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Fetching User", message: "\(error.localizedDescription)")
    }
}

// MARK: - Changing Currency Error
extension AlertManager {
    
    public static func showChangingCurrencyError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Changing the Currency", message: "\(error.localizedDescription)")
    }
}

// MARK: - Changing Currency Error
extension AlertManager {
    
    public static func showChangingLanguageError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Changing the Language", message: "\(error.localizedDescription)")
    }
}

//MARK: - Loging Out Confirmation
extension AlertManager {
    
    public static func showLogingOutConfirmationAlert(on vc: UIViewController) {
        self.showYesOrNoAlert(on: vc, title: "Are you sure you want to log out?", message: "You can sign back into your account later on...") { _ in
            AuthService.shared.signOut { error in
                if let error = error {
                    AlertManager.showLogOutErrorAlert(on: vc, with: error)
                    return
                }
                
                if let navigationController = vc.navigationController?.tabBarController?.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
        }
    }
}

//MARK: - Copied Text Alert
extension AlertManager {
    
    public static func showCopiedTextAlert(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        self.showCustomAlert(on: vc, title: "Copied text!", image: tickImage, imageColor: .accent)
    }
}

//MARK: - Login Succesfull Alert
extension AlertManager {
    
    public static func signedInAlert(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showCustomAlert(on: vc, title: "Login Succesful!", image: tickImage, imageColor: .accent)
    }
}

//MARK: - Registration Email Alert
extension AlertManager {
    
    static func showEmailVerificationSentAlert(on viewController: UIViewController, email: String) {
        self.showBasicAlertWithAction(on: viewController, title: "Email Verification Sent", message: "A verification email has been sent to \(email). Please verify your email before logging in.") { _ in
            viewController.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - Create Account Succesfull Alert
extension AlertManager {
    
    public static func createdAccountAlert(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showCustomAlert(on: vc, title: "Account created!", image: tickImage, imageColor: .accent)
    }
}

//MARK: - Change Password Alert
extension AlertManager {
    
    public static func passwordsDontMatchAlert(on vc: UIViewController) {
        AlertManager.showBasicAlert(on: vc, title: "New passwords do not match", message: nil)
    }
    
    
    public static func passwordsCannotBeTheSameAlert(on vc: UIViewController) {
        AlertManager.showBasicAlert(on: vc, title: "New password cant be the same as the old one", message: nil)
    }
    
    
    public static func failedChangingPasswordAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Changing Password", message: "\(error.localizedDescription)")
    }
    
    
    public static func passwordChangedAlert(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showCustomAlert(on: vc, title: "Password Changed!", image: tickImage, imageColor: .accent)
    }
    
}

//MARK: - Change Personal Info
extension AlertManager {
    
    public static func showWrongPersonalInformation(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Error Updating Personal Information", message: "You have entered invalid data.")
    }
    
    
    public static func showWrongPersonalInformationWithError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Updating Personal Information", message: "\(error.localizedDescription)")
    }
    
    
    public static func personalInformationUpdatedAlert(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showCustomAlert(on: vc, title: "Personal Information Updated!", image: tickImage, imageColor: .accent)
    }
}

//MARK: - Bad Filtering
extension AlertManager {
    
    public static func invalidAmountFiltering(on vc: UIViewController) {
        let xImage = UIImage(systemName: SFSymbols.xCircle)
        AlertManager.showCustomAlert(on: vc, title: "Invalid amounts, filtering was cancelled.", image: xImage, imageColor: .systemRed)
    }
}

//MARK: - Transaction Saved
extension AlertManager {
    
    public static func transactionWasSaved(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showCustomAlert(on: vc, title: "Your transaction was saved succesfully.", image: tickImage, imageColor: .accent)
    }
    
    
    public static func transactionNotSaved(on vc: UIViewController, with error: Error) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showBasicAlert(on: vc, title: "Error Adding Transaction", message: "\(error.localizedDescription)")
    }
}

//MARK: - Add Invalid Transaction
extension AlertManager {
    
    public static func transactionInvalidAmountAndDescription(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Amount and Description", message: nil)
    }
    
    
    public static func transactionInvalidDescription(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Description", message: nil)
    }
    
    
    public static func transactionInvalidAmount(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Amount", message: nil)
    }
    
    
    public static func transactionNegativeAmount(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Amount", message: "Amount must be greater than 0.")
    }
    
}

//MARK: - Edit Transaction
extension AlertManager {
    
    public static func editTransactionError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error editing transaction", message: "\(error.localizedDescription)")
    }
    
    
    public static func editTransactionSuccesful(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        AlertManager.showCustomAlert(on: vc, title: "Your transaction was edited succesfully.", image: tickImage, imageColor: .accent)
    }
}

//MARK: - Delete Transaction
extension AlertManager {
    
    public static func deleteTransactionAlert(on vc: UIViewController, transaction: Transaction) {
        self.showYesOrNoAlert(on: vc, title: "Delete Transaction", message: "Are you sure you want to delete this transaction?") { _ in
            AuthService.shared.deleteTransaction(transaction: transaction) { error in
                if let error = error {
                    deleteTransactionError(on: vc, with: error)
                    return
                }
                AuthService.shared.fetchUser { user, error in
                    if let error = error {
                        showFetchingUserError(on: vc, with: error)
                    }
                    if let user = user {
                        User.shared = user
                    } else {
                        showUnknownFetchingUserError(on: vc)
                    }
                }
                User.shared.transactions.removeAll { tr in
                    tr == transaction
                }
                deleteTransactionSuccesful(on: vc)
                vc.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    public static func deleteTransactionError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error Deleting Transaction", message: "\(error.localizedDescription)")
    }
    
    
    public static func deleteTransactionSuccesful(on vc: UIViewController) {
        let tickImage = UIImage(systemName: SFSymbols.checkmark)
        self.showCustomAlert(on: vc, title: "Your transaction was deleted succesfully.", image: tickImage, imageColor: .accent)
    }
}

//MARK: - TotalBalance Screen
extension AlertManager {
    
    public static func showTotalBalanceInfo(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Total Summary", message: "All-time balance.")
    }
    
    
    public static func showMonthlySummaryInfo(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Monthly Summary", message: "The balance based only on the transactions of that specific month.")
    }
    
    
    public static func showMonthlyExpensesInfo(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Monthly Expenses", message: "The total expenses that happened only in that specific month.")
    }
}

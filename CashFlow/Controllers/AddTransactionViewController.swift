//
//  AddTransactionViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 28/6/24.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    @IBOutlet var transactionTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var moneyTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwitches()
        setupDatePicker()
        setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
    }
    
    private func setupTextFields() {
        descriptionTextField.delegate = self
        amountTextField.delegate = self
    }
    
    private func setupDatePicker() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        if let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: currentDate) {
            datePicker.minimumDate = tenYearsAgo
        }
        
        datePicker.maximumDate = currentDate
    }
    
    private func setupSwitches() {
        let switchConfig: (AnimatedSegmentSwitch) -> Void = { switchControl in
            switchControl.backgroundColor = .accent
            switchControl.selectedTitleColor = .accent
            switchControl.titleColor = .label
            switchControl.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
            switchControl.thumbColor = .white
            switchControl.cornerRadius = 20
        }
        
        transactionTypeSwitch.items = ["Income", "Expense"]
        switchConfig(transactionTypeSwitch)
        
        moneyTypeSwitch.items = ["Cash", "Card"]
        switchConfig(moneyTypeSwitch)
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Add Transaction"
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        var invalidAmount = false
        var negativeAmount = false
        var invalidDescription = false
        var amountValue: Double?

        if let amountText = amountTextField.text?.replacingOccurrences(of: ",", with: "."), !amountText.isEmpty {
            if let value = Double(amountText) {
                if value > 0 {
                    amountValue = value
                } else {
                    negativeAmount = true
                }
            } else {
                invalidAmount = true
            }
        } else {
            invalidAmount = true
        }

        if let description = descriptionTextField.text, !description.isEmpty, Validator.isValidDescription(for: description) {
        } else {
            invalidDescription = true
        }

        if invalidAmount && invalidDescription {
            AlertManager.transactionInvalidAmountAndDescription(on: self)
            return
        } else if negativeAmount{
            AlertManager.transactionNegativeAmount(on: self)
            return
        } else if invalidAmount {
            AlertManager.transactionInvalidAmount(on: self)
            return
        } else if invalidDescription {
            AlertManager.transactionInvalidDescription(on: self)
            return
        }


        let transactionTypeIndex = transactionTypeSwitch.selectedIndex
        let moneyTypeIndex = moneyTypeSwitch.selectedIndex

        let transactionType: TransactionType = transactionTypeIndex == 0 ? .income : .expense
        let moneyType: MoneyType = moneyTypeIndex == 0 ? .cash : .card

        let transaction = Transaction(
            id: UUID(),
            description: descriptionTextField.text!,
            money: amountValue!,
            date: datePicker.date,
            transactionType: transactionType,
            moneyType: moneyType
        )

        AuthService.shared.insertTransaction(transaction: transaction) { error in
            if let error = error {
                AlertManager.transactionNotSaved(on: self, with: error)
                return
            } else {
                AuthService.shared.fetchUser { [weak self] user, error in
                    guard let self = self else { return }
                    if let error = error {
                        AlertManager.showFetchingUserError(on: self, with: error)
                    }
                    if let user = user {
                        User.shared = user
                        self.navigationController?.viewControllers.forEach({ vc in
                            if vc is HomeViewController {
                                (vc as! HomeViewController).delegate?.userHasLoad()
                            }
                        })
                        AlertManager.transactionWasSaved(on: self)
                    } else {
                        AlertManager.showUnknownFetchingUserError(on: self)
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func shakeTextField(textField: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 0.5
        animation.repeatCount = 2
        animation.values = [
            NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y)),
            NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))
        ]
        textField.layer.add(animation, forKey: "position")
    }
}

// MARK: - UITextFieldDelegate Methods
extension AddTransactionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

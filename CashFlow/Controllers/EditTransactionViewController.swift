//
//  EditTransactionViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 12/7/24.
//

import UIKit

class EditTransactionViewController: UIViewController {
    
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var transactionTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var moneyTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var datePicker: UIDatePicker!
    
    var transaction: Transaction!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwitches()
        loadData()
        setupTextFields()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    
    private func setupView() {
        navigationController?.navigationBar.isHidden = false
        title = "Edit Transaction"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    private func loadData() {
        amountTextField.text = String(transaction.money)
        descriptionTextField.text = transaction.description
        datePicker.date = transaction.date
        
        loadSwitches()
    }
    
    
    private func setupTextFields() {
        descriptionTextField.delegate = self
        amountTextField.delegate = self
    }
    
    
    private func loadSwitches() {
        switch transaction.transactionType {
        case .income:
            transactionTypeSwitch.selectedIndex = 0
        case .expense:
            transactionTypeSwitch.selectedIndex = 1
        }
        
        switch transaction.moneyType {
        case .cash:
            moneyTypeSwitch.selectedIndex = 0
        case .card:
            moneyTypeSwitch.selectedIndex = 1
        }
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
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
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

        let transactionToSave = Transaction(
            id: transaction.id,
            description: descriptionTextField.text!,
            money: amountValue!,
            date: datePicker.date,
            transactionType: transactionType,
            moneyType: moneyType
        )
        
        AuthService.shared.updateTransaction(transaction: transactionToSave) { error in
            if let error = error {
                AlertManager.editTransactionError(on: self, with: error)
                return
            }
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
                    if(transaction != transactionToSave) {
                        AlertManager.editTransactionSuccesful(on: self)
                    }
                } else {
                    AlertManager.showUnknownFetchingUserError(on: self)
                }
            }
            self.navigationController?.viewControllers.forEach({ vc in
                if vc is TransactionDetailViewController {
                    (vc as! TransactionDetailViewController).transaction = transactionToSave
                }
                
                if vc is AllTransactionsTableViewController {
                    let allTransactionsVC: AllTransactionsTableViewController = vc as! AllTransactionsTableViewController
                    allTransactionsVC.transactions.removeAll { $0.id == transactionToSave.id }
                    allTransactionsVC.transactions.append(transactionToSave)
                }
                
            })
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate Methods
extension EditTransactionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

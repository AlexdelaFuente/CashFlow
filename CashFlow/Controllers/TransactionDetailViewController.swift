//
//  TransactionDetailViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 11/7/24.
//

import UIKit

class TransactionDetailViewController: UIViewController {

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var transactionTypeLabel: UILabel!
    @IBOutlet var transactionIdLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    
    public var transaction: Transaction!
    
    public var hasToUpdate = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupLabels()
        setupNavigation()
    }
    
    
    private func setupNavigation() {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = .systemRed
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
        title = "Transaction"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    @objc func editButtonTapped() {
        let vc = Factory.provideEditTransactionScreen(storyboard: storyboard!)
        vc.transaction = transaction
        title = "Back"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func deleteButtonTapped() {
        AlertManager.deleteTransactionAlert(on: self, transaction: transaction)
    }
        
    
    private func setupLabels() {
        setupTitleLabels()
        setupDateLabel()
        setupTransactionTypeLabel()
        setupTransactionIdLabel()
    }
    
    
    private func setupTransactionIdLabel() {
        transactionIdLabel.text = "Transaction #\(transaction.id)"
    }
    
    
    private func setupTitleLabels() {
        amountLabel.text = "\(transaction.formattedMoneyString) \(User.shared.currency.symbol)"
        if transaction.transactionType == .income {
            amountLabel.textColor = .accent
        } else {
            amountLabel.textColor = .systemRed
        }
        descriptionLabel.text = transaction.description
    }
    
    
    private func setupDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .year) {
            dateFormatter.dateFormat = "MMMM d, HH:mm"
        } else {
            dateFormatter.dateFormat = "MMMM d, yyyy, HH:mm"
        }
        
        dateLabel.text = "Processed on \(dateFormatter.string(from: transaction.date))"
    }
    
    
    private func setupTransactionTypeLabel() {
        switch transaction.transactionType {
            case .income:
                switch transaction.moneyType {
                    case .card:
                        transactionTypeLabel.text = "Deposited in your card balance"
                    case .cash:
                        transactionTypeLabel.text = "Deposited in your cash balance"
                }
                
            case .expense:
                switch transaction.moneyType {
                    case .card:
                        transactionTypeLabel.text = "Paid with card"
                    case .cash:
                        transactionTypeLabel.text = "Paid with cash"
                }
        }
    }
    
    
    private func setupBackgroundView() {
        backgroundView.layer.cornerRadius = 46
        backgroundView.backgroundColor = .systemGray4
    }
}

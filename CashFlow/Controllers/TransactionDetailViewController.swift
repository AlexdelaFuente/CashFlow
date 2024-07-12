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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
        setupBackgroundView()
        
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

    @IBAction func editButtonTapped(_ sender: Any) {
        let vc = Factory.provideEditTransactionScreen(storyboard: storyboard!)
        present(vc, animated: true)
    }
}

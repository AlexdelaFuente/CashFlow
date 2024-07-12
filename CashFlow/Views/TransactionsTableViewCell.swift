//
//  TransactionsTableViewCell.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 25/6/24.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    @IBOutlet var moneyTypeImage: UIImageView!
    
    private var transaction: Transaction?
    
    
    func load(with transaction: Transaction, isDayHidden: Bool) {
        self.transaction = transaction
        descriptionLabel.text = transaction.description
        if isDayHidden {
            dateLabel.text = transaction.date.formatted(date: .omitted, time: .shortened)
        } else {
            dateLabel.text = transaction.date.formattedString()
        }
        updateMoneyLabel()
        updateImage()
    }
    
    
    private func updateImage(){
        guard let transaction = transaction else { return }
        switch(transaction.moneyType) {
            
        case .cash:
            moneyTypeImage.image = UIImage(systemName: SFSymbols.banknote)
        case .card:
            moneyTypeImage.image = UIImage(systemName: SFSymbols.creditCard)
        }
    }
    
    
    func setMoneyVisibility(_ visibility: Bool) {
        guard let transaction = transaction else { return }
        
        if visibility {
            moneyLabel.text = "\(transaction.formattedMoneyString) \(User.shared.currency.symbol)"
            moneyLabel.textColor = (transaction.transactionType == .income) ? .accent : .systemRed
            moneyTypeImage.isHidden = false
        } else {
            moneyLabel.text = "~~~ \(User.shared.currency.symbol)"
            moneyLabel.textColor = .label
            moneyTypeImage.isHidden = true
        }
    }
    
    
    private func updateMoneyLabel() {
        guard let transaction = transaction else { return }
        
        moneyLabel.text = "\(transaction.formattedMoneyString) \(User.shared.currency.symbol)"
        moneyLabel.textColor = (transaction.transactionType == .income) ? .accent : .systemRed
    }
    
    
    
}

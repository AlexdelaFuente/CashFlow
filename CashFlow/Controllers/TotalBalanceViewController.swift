//
//  AddWithdrawViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/7/24.
//

import UIKit

class TotalBalanceViewController: UIViewController {

    @IBOutlet var totalBalanceLabel: UILabel!
    @IBOutlet var totalBalanceGraphButton: UIButton!

    @IBOutlet var cashLabel: UILabel!
    @IBOutlet var cashGraphButton: UIButton!
    
    @IBOutlet var cardLabel: UILabel!
    @IBOutlet var cardGraphButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        calculateBalance()
    }
    
    private func calculateBalance() {
        let totalBalance = User.shared.transactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        totalBalanceLabel.text = "\(String(format: "%.2f", totalBalance)) \(User.shared.currency.symbol)"
        if totalBalance < 0 {
            totalBalanceLabel.textColor = .systemRed
            totalBalanceGraphButton.setImage(UIImage(systemName: SFSymbols.downtrendChart), for: .normal)
        } else if totalBalance == 0 {
            totalBalanceLabel.textColor = .label
            totalBalanceGraphButton.setImage(UIImage(systemName: SFSymbols.flattrendChart), for: .normal)
        } else {
            totalBalanceLabel.textColor = .label
            totalBalanceGraphButton.setImage(UIImage(systemName: SFSymbols.uptrendChart), for: .normal)
        }
        
        let cashTransactions = User.shared.transactions.filter({ $0.moneyType == .cash })
        let cashBalance = cashTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        cashLabel.text = "\(String(format: "%.2f", cashBalance)) \(User.shared.currency.symbol)"
        
        if cashBalance < 0 {
            cashLabel.textColor = .systemRed
            cashGraphButton.setImage(UIImage(systemName: SFSymbols.downtrendChart), for: .normal)
        } else if cashBalance == 0 {
            cashLabel.textColor = .label
            cashGraphButton.setImage(UIImage(systemName: SFSymbols.flattrendChart), for: .normal)
        } else {
            cashLabel.textColor = .label
            cashGraphButton.setImage(UIImage(systemName: SFSymbols.uptrendChart), for: .normal)
        }
        
        
        let cardTransactions = User.shared.transactions.filter({ $0.moneyType == .card })
        let cardBalance = cardTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        cardLabel.text = "\(String(format: "%.2f", cardBalance)) \(User.shared.currency.symbol)"
        
        if cardBalance < 0 {
            cardLabel.textColor = .systemRed
            cardGraphButton.setImage(UIImage(systemName: SFSymbols.downtrendChart), for: .normal)
        } else if cardBalance == 0 {
            cardLabel.textColor = .label
            cardGraphButton.setImage(UIImage(systemName: SFSymbols.flattrendChart), for: .normal)
        } else {
            cardLabel.textColor = .label
            cardGraphButton.setImage(UIImage(systemName: SFSymbols.uptrendChart), for: .normal)
        }
        
        
        
    }
    
    private func setupNavigation() {
        self.title = "Your Balance Details"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    

}

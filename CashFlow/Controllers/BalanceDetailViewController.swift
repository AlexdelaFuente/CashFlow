//
//  AddWithdrawViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/7/24.
//

import UIKit

class BalanceDetailViewController: UIViewController {

    @IBOutlet var totalBalanceLabel: UILabel!
    @IBOutlet var totalBalanceGraphButton: UIButton!

    @IBOutlet var cashLabel: UILabel!
    @IBOutlet var cashGraphButton: UIButton!
    
    @IBOutlet var cardLabel: UILabel!
    @IBOutlet var cardGraphButton: UIButton!
    
    @IBOutlet var backgroundViews: [UIView]!
    
    @IBOutlet var thisMonthSummaryLabel: UILabel!
    @IBOutlet var previousMonthSummaryLabel: UILabel!
    
    @IBOutlet var thisMonthExpensesLabel: UILabel!
    @IBOutlet var previousMonthExpensesLabel: UILabel!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        calculateBalance()
        calculateSummary()
        calculateExpenses()
        setupView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = "Back"
    }
    
    
    private func setupView() {
        backgroundViews.forEach { backgroundView in
            backgroundView.roundCorners(.allCorners, radius: 12)
        }
        
    }
    
    
    private func calculateBalance() {
        calculateTotalBalance()
        calculateCashBalance()
        calculateCardBalance()
    }
    
    
    private func calculateSummary() {
        calculateThisMonthSummary()
        calculatePreviousMonthSummary()
    }
    
    
    private func calculateExpenses() {
        calculateThisMonthExpenses()
        calculatePreviousMonthExpenses()
    }
    
    
    private func calculateTotalBalance() {
        let totalBalance = User.shared.transactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        totalBalanceLabel.text = "\(String(format: "%.2f", totalBalance)) \(User.shared.currency.symbol)"
        
        if totalBalance < 0 {
            totalBalanceLabel.textColor = .systemRed
            if #available(iOS 17, *) {
                totalBalanceGraphButton.setImage(UIImage(systemName: SFSymbols.downtrendChart), for: .normal)
            }
        } else if totalBalance == 0 {
            totalBalanceLabel.textColor = .label
            if #available(iOS 17, *) {
                totalBalanceGraphButton.setImage(UIImage(systemName: SFSymbols.flattrendChart), for: .normal)
            }
        } else {
            totalBalanceLabel.textColor = .label
            if #available(iOS 17, *) {
                totalBalanceGraphButton.setImage(UIImage(systemName: SFSymbols.uptrendChart), for: .normal)
            }
        }
    }
    
    
    private func calculateCashBalance() {
        let cashTransactions = User.shared.transactions.filter({ $0.moneyType == .cash })
        let cashBalance = cashTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        cashLabel.text = "\(String(format: "%.2f", cashBalance)) \(User.shared.currency.symbol)"
        
        if cashBalance < 0 {
            cashLabel.textColor = .systemRed
            if #available(iOS 17, *) {
                cashGraphButton.setImage(UIImage(systemName: SFSymbols.downtrendChart), for: .normal)
            }
        } else if cashBalance == 0 {
            cashLabel.textColor = .label
            if #available(iOS 17, *) {
                cashGraphButton.setImage(UIImage(systemName: SFSymbols.flattrendChart), for: .normal)
            }
        } else {
            cashLabel.textColor = .label
            if #available(iOS 17, *) {
                cashGraphButton.setImage(UIImage(systemName: SFSymbols.uptrendChart), for: .normal)
            }
        }
    }
    
    
    private func calculateCardBalance() {
        let cardTransactions = User.shared.transactions.filter({ $0.moneyType == .card })
        let cardBalance = cardTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        cardLabel.text = "\(String(format: "%.2f", cardBalance)) \(User.shared.currency.symbol)"
        
        if cardBalance < 0 {
            cardLabel.textColor = .systemRed
            if #available(iOS 17, *) {
                cardGraphButton.setImage(UIImage(systemName: SFSymbols.downtrendChart), for: .normal)
            }
        } else if cardBalance == 0 {
            cardLabel.textColor = .label
            if #available(iOS 17, *) {
                cardGraphButton.setImage(UIImage(systemName: SFSymbols.flattrendChart), for: .normal)
            }
        } else {
            cardLabel.textColor = .label
            if #available(iOS 17, *) {
                cardGraphButton.setImage(UIImage(systemName: SFSymbols.uptrendChart), for: .normal)
            }
        }
    }
    
    
    private func calculateThisMonthSummary() {
        let thisMonthTransactions = User.shared.transactions.filter { $0.date.isThisMonth()
        }
        
        let thisMonthBalance = thisMonthTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        thisMonthSummaryLabel.text = "\(String(format: "%.2f", thisMonthBalance)) \(User.shared.currency.symbol)"
        thisMonthSummaryLabel.textColor = thisMonthBalance < 0 ? .systemRed : .label
    }
    
    
    private func calculatePreviousMonthSummary() {
        let previousMonthTransactions = User.shared.transactions.filter { $0.date.isPreviousMonth()
        }
        
        let previousMonthBalance = previousMonthTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
        previousMonthSummaryLabel.text = "\(String(format: "%.2f", previousMonthBalance)) \(User.shared.currency.symbol)"
        previousMonthSummaryLabel.textColor = previousMonthBalance < 0 ? .systemRed : .label
    }
    
    
    private func calculateThisMonthExpenses() {
        let thisMonthTransactions = User.shared.transactions.filter { $0.date.isThisMonth()
        }
        
        let thisMonthExpenses = thisMonthTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : 0) }
        thisMonthExpensesLabel.text = "\(String(format: "%.2f", thisMonthExpenses)) \(User.shared.currency.symbol)"
    }
    
    
    private func calculatePreviousMonthExpenses() {
        let previousMonthTransactions = User.shared.transactions.filter { $0.date.isPreviousMonth()
        }
        
        let previousMonthExpenses = previousMonthTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : 0) }
        previousMonthExpensesLabel.text = "\(String(format: "%.2f", previousMonthExpenses)) \(User.shared.currency.symbol)"
    }
    
    
    
    
    private func setupNavigation() {
        self.title = "Your Balance Details"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    
    @IBAction func totalBalanceButtonTapped(_ sender: Any) {
        guard !User.shared.transactions.isEmpty else {
            AlertManager.showTotalBalanceAlert(on: self)
            return
        }
        let vc = Factory.providetotalBalanceChartScreen(storyboard: storyboard!, dataType: .totalBalance)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func totalCashButtonTapped(_ sender: Any) {
        
        guard !User.shared.transactions.filter({ $0.moneyType == .cash}).isEmpty else {
            AlertManager.showTotalCashAlert(on: self)
            return
        }
        let vc = Factory.providetotalBalanceChartScreen(storyboard: storyboard!, dataType: .totalCash)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func totalCardButtonTapped(_ sender: Any) {
        guard !User.shared.transactions.filter({ $0.moneyType == .card}).isEmpty else {
            AlertManager.showTotalCardAlert(on: self)
            return
        }
        let vc = Factory.providetotalBalanceChartScreen(storyboard: storyboard!, dataType: .totalCard)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func seeAllSummaryButtonTapped(_ sender: Any) {
        guard !User.shared.transactions.isEmpty else {
            AlertManager.showMonthlySummaryAlert(on: self)
            return
        }
        let vc = Factory.providetotalBalanceChartScreen(storyboard: storyboard!, dataType: .monthlySummary)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func seeMonthlyExpensesButtonTapped(_ sender: Any) {
        guard !User.shared.transactions.filter({ $0.transactionType == .expense}).isEmpty else {
            AlertManager.showMonthlyExpensesInfo(on: self)
            return
        }
        let vc = Factory.providetotalMonthlyExpensesScreen(storyboard: storyboard!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func totalBalanceInfoButtonTapped(_ sender: Any) {
        AlertManager.showTotalBalanceInfo(on: self)
    }
    
    
    @IBAction func summaryInfoButtonTapped(_ sender: Any) {
        AlertManager.showMonthlySummaryInfo(on: self)
    }
    
    
    @IBAction func totalMonthlyExpensesTapped(_ sender: Any) {
        AlertManager.showMonthlyExpensesInfo(on: self)
    }
}

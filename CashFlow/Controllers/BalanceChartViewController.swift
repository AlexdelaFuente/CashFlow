//
//  BalanceChartViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 29/7/24.
//

import UIKit
import Combine
import SwiftUI

class BalanceChartViewController: UIViewController {

    private let vm = ChartLineViewModel()
    public var dataType: LinearChartDataType!
    
    private var sortedTransactions: [(Date, Double, Bool)] = []
    private var transactionsForSelectedMonth: [Transaction] = []
    
    private var cancellable: AnyCancellable?
    
    private var childVC: UIHostingController<ChartLine>!
    
    private let moneyTitleLabel = UILabel(frame: .zero)
    private let moneyLabel = UILabel(frame: .zero)
    
    private let averageMonthlySummaryTitleLabel = UILabel(frame: .zero)
    private let averageMonthlySummaryLabel = UILabel(frame: .zero)
    
    private var emptyState = EmptyStateView(frame: .zero, message: "There was not any transactions in this month.")
    
    private let tableView = UITableView(frame: .zero)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTransactions()
        vm.selectedIndex = sortedTransactions.count - 1
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterTransactions()
        setupNavigation()
        setupChart()
        setupLabels()
        setupEmptyState()
        setupTable()
        updateScreen(vm.selectedIndex)
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        DispatchQueue.main.async {
            self.title = "Back"
        }
    }
    
    
    private func filterTransactions() {
        var transactions = User.shared.transactions
        
        switch dataType {
        case .totalBalance:
            calculateBalance(transactions: transactions)
        case .totalCash:
            transactions = transactions.filter { $0.moneyType == .cash }
            calculateBalance(transactions: transactions)
        case .totalCard:
            transactions = transactions.filter { $0.moneyType == .card }
            calculateBalance(transactions: transactions)
        case .monthlySummary:
            calculateSummary(transactions: transactions)
        case .none:
            break
        }
    }
    
    
    private func calculateBalance(transactions: [Transaction]) {
        let groupedByMonth = Dictionary(grouping: transactions) { transaction -> Date in
            let components = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return Calendar.current.date(from: components)!
        }

        let minDate = transactions.map { $0.date }.min()!
        let maxDate = Date()

        var date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: minDate))!
        let endDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: maxDate))!

        var completeMonths: [(Date, Double, Bool)] = []
        var previousBalance: Double = 0.0
        
        let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        completeMonths.append((previousMonthDate, 0.0, false))

        while date <= endDate {
            if let transactions = groupedByMonth[date] {
                let monthlyBalance = transactions.reduce(0) { $1.transactionType == .income ? $0 + $1.money : $0 - $1.money }
                let totalBalance = previousBalance + monthlyBalance
                let hasTransactions = transactions.count > 0
                completeMonths.append((date, totalBalance, hasTransactions))
                previousBalance = totalBalance
            } else {
                completeMonths.append((date, previousBalance, false))
            }
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        }

        sortedTransactions = completeMonths.sorted { $0.0 < $1.0 }
    }

    
    private func calculateSummary(transactions: [Transaction]) {
        let groupedByMonth = Dictionary(grouping: transactions) { transaction -> Date in
            let components = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return Calendar.current.date(from: components)!
        }

        let minDate = transactions.map { $0.date }.min()!
        let maxDate = Date()

        var date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: minDate))!
        let endDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: maxDate))!

        var completeMonths: [(Date, Double, Bool)] = []
        
        let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        completeMonths.append((previousMonthDate, 0.0, false))

        while date <= endDate {
            if let transactions = groupedByMonth[date] {
                let totalBalance = transactions.reduce(0) { $1.transactionType == .income ? $0 + $1.money : $0 - $1.money }
                let hasTransactions = transactions.count > 0
                completeMonths.append((date, totalBalance, hasTransactions))
            } else {
                completeMonths.append((date, 0, false))
            }
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        }
        sortedTransactions = completeMonths.sorted { $0.0 < $1.0 }
    }
    
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        switch dataType {
        case .totalBalance:
            self.title = "Total Balance"
        case .totalCash:
            self.title = "Total Cash"
        case .totalCard:
            self.title = "Total Card"
        case .monthlySummary:
            self.title = "Monthly Summary"
        case .none:
            self.title = ""
        }
    }
    

    private func setupChart() {
        childVC = UIHostingController(rootView: ChartLine(viewModel: vm, data: sortedTransactions))
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            childVC.view.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        cancellable = childVC.rootView.viewModel.$selectedIndex.sink(receiveValue: { [weak self] value in
            guard let self = self else { return }
            self.updateScreen(value)
        })
    }
    
    
    private func updateScreen(_ value: Int) {
        guard value >= 0 && value < sortedTransactions.count else { return }
        
        let selectedMonth = sortedTransactions[value].0
        let moneyToDisplay = sortedTransactions[value].1
        moneyLabel.text = "\(String(format: "%.2f", moneyToDisplay)) \(User.shared.currency.symbol)"
        
        moneyLabel.textColor = moneyToDisplay >= 0 ? .label : .systemRed
        
        transactionsForSelectedMonth = User.shared.transactions.filter {
            let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
            return Calendar.current.date(from: components) == selectedMonth
        }
        
        if dataType == .totalCard {
            transactionsForSelectedMonth = transactionsForSelectedMonth.filter { $0.moneyType ==  .card}
        } else if dataType == .totalCash{
            transactionsForSelectedMonth = transactionsForSelectedMonth.filter { $0.moneyType ==  .cash}
        }
        
        guard transactionsForSelectedMonth.count != 0 else {
            emptyState.isHidden = false
            transactionsForSelectedMonth = []
            view.bringSubviewToFront(emptyState)
            tableView.reloadData()
            return
        }
        
        
        
        emptyState.isHidden = true
        
        tableView.reloadData()
    }
    
    
    private func setupLabels() {
        switch dataType {
        case .totalBalance:
            moneyTitleLabel.text = "Total balance until selected month"
        case .totalCash:
            moneyTitleLabel.text = "Total cash until selected month"
        case .totalCard:
            moneyTitleLabel.text = "Total money card until selected month"
        case .monthlySummary:
            moneyTitleLabel.text = "Isolated balance in selected month"
        case .none:
            break
        }
        moneyLabel.text = "Loading..."
 
        moneyTitleLabel.font = .systemFont(ofSize: 13)
        moneyLabel.font = .systemFont(ofSize: 28, weight: .regular)

        moneyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moneyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(moneyTitleLabel)
        view.addSubview(moneyLabel)

        NSLayoutConstraint.activate([
            moneyTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            moneyTitleLabel.topAnchor.constraint(equalTo: childVC.view.bottomAnchor, constant: 16),

            moneyLabel.leadingAnchor.constraint(equalTo: moneyTitleLabel.leadingAnchor),
            moneyLabel.topAnchor.constraint(equalTo: moneyTitleLabel.bottomAnchor, constant: 4)
        ])
        
        if dataType == .monthlySummary {
            averageMonthlySummaryTitleLabel.text = "Average balance"
            averageMonthlySummaryLabel.text = "Loading..."
            
            let totalSum = sortedTransactions.reduce(0) { (sum, item) in sum + item.1 }
            let count = Double(sortedTransactions.count)
            let average = count > 0 ? totalSum / count : 0
            
            averageMonthlySummaryLabel.text = "\(String(format: "%.2f", average)) \(User.shared.currency.symbol)"
            
            averageMonthlySummaryLabel.textColor = average >= 0 ? .label : .systemRed
            
            averageMonthlySummaryTitleLabel.font = .systemFont(ofSize: 13)
            averageMonthlySummaryLabel.font = .systemFont(ofSize: 28, weight: .regular)
            
            averageMonthlySummaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            averageMonthlySummaryLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            view.addSubview(averageMonthlySummaryTitleLabel)
            view.addSubview(averageMonthlySummaryLabel)
            
            
            NSLayoutConstraint.activate([
                averageMonthlySummaryTitleLabel.centerYAnchor.constraint(equalTo: moneyTitleLabel.centerYAnchor),
                averageMonthlySummaryTitleLabel.trailingAnchor.constraint(equalTo: childVC.view.trailingAnchor, constant: -16),
                
                averageMonthlySummaryLabel.centerYAnchor.constraint(equalTo: moneyLabel.centerYAnchor),
                averageMonthlySummaryLabel.trailingAnchor.constraint(equalTo: averageMonthlySummaryTitleLabel.trailingAnchor)
            ])
        }
    }
    
    
    private func setupEmptyState() {
        emptyState.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyState)

        NSLayoutConstraint.activate([
            emptyState.topAnchor.constraint(equalTo: moneyLabel.bottomAnchor),
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        emptyState.isHidden = true
    }
    
    
    private func setupTable() {
        let separatorView = UIView(frame: .zero)
        separatorView.backgroundColor = .label
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)
        
        tableView.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")

        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: moneyLabel.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.2),
            
            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Table view data source
extension BalanceChartViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsForSelectedMonth.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
        let transaction = transactionsForSelectedMonth[indexPath.row]
        cell.load(with: transaction, isDayHidden: false)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)
        
        if indexPath.row == numberOfRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - Table view delegate
extension BalanceChartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = transactionsForSelectedMonth[indexPath.row]
        let vc = Factory.provideTransactionDetailScreen(storyboard: storyboard!, transaction: transaction)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

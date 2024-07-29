//  MonthlyExpensesViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 26/7/24.
//

import UIKit
import SwiftUI
import Combine

class MonthlyExpensesViewController: UIViewController {

    private let vm = ChartBarViewModel()
    private var sortedExpenses: [(Date, Double)] = []
    private var transactionsForSelectedMonth: [CashFlow.Transaction] = []

    private var cancellable: AnyCancellable?

    private var childVC: UIHostingController<ChartBar>!

    let averageExpensesTitleLabel = UILabel(frame: .zero)
    let averageExpensesLabel = UILabel(frame: .zero)
    let thisMonthExpensesTitleLabel = UILabel(frame: .zero)
    let thisMonthExpensesLabel = UILabel(frame: .zero)

    let emptyState = EmptyStateView(frame: .zero, message: "You didn't spend anything in this month!")

    let tableView = UITableView(frame: .zero)


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortTransactions()
        setupNavigation()
        setupChart()
        setupLabels()
        setupEmptyState()
        setupTable()
        updateScreen(vm.selectedIndex)
    }


    private func sortTransactions() {
        let transactions = User.shared.transactions

        let expenses = transactions.filter { $0.transactionType == .expense }

        let groupedByMonth = Dictionary(grouping: expenses) { transaction -> Date in
            let components = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return Calendar.current.date(from: components)!
        }

        let minDate = expenses.map { $0.date }.min()!
        let maxDate = expenses.map { $0.date }.max()!

        var date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: minDate))!
        let endDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: maxDate))!

        var completeMonths: [(Date, Double)] = []

        while date <= endDate {
            if let transactions = groupedByMonth[date] {
                let totalExpense = transactions.reduce(0) { $0 + $1.money }
                completeMonths.append((date, totalExpense))
            } else {
                completeMonths.append((date, 0))
            }
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        }

        sortedExpenses = completeMonths.sorted { $0.0 < $1.0 }
    }


    private func setupNavigation() {
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Monthly Expenses"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }


    private func updateScreen(_ value: Int) {
        guard value >= 0 && value < sortedExpenses.count else {
            return
        }

        let selectedMonth = sortedExpenses[value].0
        let expenses = sortedExpenses[value].1
        thisMonthExpensesLabel.text = "\(String(format: "%.2f", expenses)) \(User.shared.currency.symbol)"
        guard expenses > 0 else {
            emptyState.isHidden = false
            transactionsForSelectedMonth = []
            view.bringSubviewToFront(emptyState)
            tableView.reloadData()
            return
        }
        emptyState.isHidden = true

        transactionsForSelectedMonth = User.shared.transactions.filter {
            let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
            return Calendar.current.date(from: components) == selectedMonth
        }.filter { $0.transactionType == .expense }
        tableView.reloadData()
    }


    private func setupChart() {
        vm.selectedIndex = sortedExpenses.count - 1
        childVC = UIHostingController(rootView: ChartBar(viewModel: vm, data: sortedExpenses))
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationController!.navigationBar.frame.height + 32),
            childVC.view.heightAnchor.constraint(equalToConstant: 232)
        ])

        cancellable = childVC.rootView.viewModel.$selectedIndex.sink(receiveValue: { [weak self] value in
            guard let self = self else { return }
            self.updateScreen(value)
        })
    }


    private func setupLabels() {
        averageExpensesTitleLabel.text = "Average month expenses"
        thisMonthExpensesLabel.text = "Loading..."
        thisMonthExpensesTitleLabel.text = "Expenses in this month"
 
        let totalSum = sortedExpenses.reduce(0) { (sum, item) in
            sum + item.1
        }
        let count = Double(sortedExpenses.count)
        let average = count > 0 ? totalSum / count : 0

        averageExpensesLabel.text = "\(String(format: "%.2f", average)) \(User.shared.currency.symbol)"

        averageExpensesTitleLabel.font = .preferredFont(forTextStyle: .footnote)
        averageExpensesLabel.font = .preferredFont(forTextStyle: .title1)
        thisMonthExpensesTitleLabel.font = .preferredFont(forTextStyle: .footnote)
        thisMonthExpensesLabel.font = .preferredFont(forTextStyle: .title1)

        averageExpensesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        averageExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        thisMonthExpensesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        thisMonthExpensesLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(averageExpensesTitleLabel)
        view.addSubview(averageExpensesLabel)
        view.addSubview(thisMonthExpensesTitleLabel)
        view.addSubview(thisMonthExpensesLabel)

        NSLayoutConstraint.activate([
            thisMonthExpensesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            thisMonthExpensesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            thisMonthExpensesTitleLabel.topAnchor.constraint(equalTo: childVC.view.bottomAnchor, constant: 16),

            averageExpensesTitleLabel.centerYAnchor.constraint(equalTo: thisMonthExpensesTitleLabel.centerYAnchor),
            averageExpensesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            thisMonthExpensesLabel.leadingAnchor.constraint(equalTo: thisMonthExpensesTitleLabel.leadingAnchor),
            thisMonthExpensesLabel.topAnchor.constraint(equalTo: thisMonthExpensesTitleLabel.bottomAnchor, constant: 4),

            averageExpensesLabel.centerYAnchor.constraint(equalTo: thisMonthExpensesLabel.centerYAnchor),
            averageExpensesLabel.leadingAnchor.constraint(equalTo: averageExpensesTitleLabel.leadingAnchor),
        ])
    }


    private func setupEmptyState() {
        emptyState.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyState)

        NSLayoutConstraint.activate([
            emptyState.topAnchor.constraint(equalTo: averageExpensesLabel.bottomAnchor),
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
            separatorView.topAnchor.constraint(equalTo: averageExpensesLabel.bottomAnchor, constant: 8),
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
extension MonthlyExpensesViewController: UITableViewDataSource {
    
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
extension MonthlyExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = transactionsForSelectedMonth[indexPath.row]
        let vc = Factory.provideTransactionDetailScreen(storyboard: storyboard!, transaction: transaction)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

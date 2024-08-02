//
//  AllTransactionsTableViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 25/6/24.
//

import UIKit

enum Section: Hashable {
    case today
    case yesterday
    case day(String, Date)
    
    var date: Date? {
        switch self {
        case .today:
            return Date()
        case .yesterday:
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        case .day(_, let date):
            return date
        }
    }
}

class AllTransactionsTableViewController: UITableViewController {
    
    private let searchController = UISearchController()
    public var transactions: [Transaction] = []
    private var filteredTransactions: [Transaction] = []
    
    private var dataSource: UITableViewDiffableDataSource<Section, Transaction>!
    private var incomeButton = FilterButton(title: "Income")
    private var expenseButton = FilterButton(title: "Expense")
    private var cashButton = FilterButton(title: "Cash")
    private var cardButton = FilterButton(title: "Card")
    private var categoryButton = FilterButton(title: "Category")
    private var dateButton = FilterButton(title: "By date")
    private var amountButton = FilterButton(title: "By amount")
    
    
    private var orderButton = FilterOrderButton()
    
    
    private var emptyState: EmptyStateView?
    private var stackView: UIStackView?
    
    private var filteringCategories: [Category] = []
    
    private var minAmount: Double?
    private var maxAmount: Double?
    
    private var minDate: Date?
    private var maxDate: Date?
    
    private var sortedSections: [Section] = []
    private var groupedTransactions: [Section: [Transaction]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
        
        
        setupEmptyState()
        setupSearchController()
        
        configureDataSource()
        setupFilterButtons()
        
        tableView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
        setupNavigationController()
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Your transactions"
    }
    
    
    private func setupEmptyState() {
        emptyState = EmptyStateView(frame: tableView.bounds.inset(by: UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)), message: "There are not any transactions matching the selected filters.")
    }
    
    
    private func loadTransactions() {
        transactions = User.shared.transactions
        filteredTransactions = transactions
        applyFilters()
    }
    
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    private func setupFilterButtons() {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        
        stackView = UIStackView()
        guard let stackView = stackView else { return }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        
        stackView.addArrangedSubview(orderButton)
        stackView.addArrangedSubview(incomeButton)
        stackView.addArrangedSubview(expenseButton)
        stackView.addArrangedSubview(cashButton)
        stackView.addArrangedSubview(cardButton)
        stackView.addArrangedSubview(categoryButton)
        stackView.addArrangedSubview(dateButton)
        stackView.addArrangedSubview(amountButton)
        
        scrollView.addSubview(stackView)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        headerView.addSubview(scrollView)
        tableView.tableHeaderView = headerView
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: headerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: CGFloat(stackView.arrangedSubviews.count * 150))
        ])
        
        orderButton.addTarget(self, action: #selector(filterTransactions), for: .touchUpInside)
        incomeButton.addTarget(self, action: #selector(basicFilterButtonPressed), for: .touchUpInside)
        expenseButton.addTarget(self, action: #selector(basicFilterButtonPressed), for: .touchUpInside)
        cashButton.addTarget(self, action: #selector(basicFilterButtonPressed), for: .touchUpInside)
        cardButton.addTarget(self, action: #selector(basicFilterButtonPressed), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(showCategoryFilterView), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(showDateFilterView), for: .touchUpInside)
        amountButton.addTarget(self, action: #selector(showAmountFilterAlert), for: .touchUpInside)
        
        basicFilterButtonPressed(incomeButton)
        basicFilterButtonPressed(expenseButton)
        basicFilterButtonPressed(cashButton)
        basicFilterButtonPressed(cardButton)
        
        reorderButtons()
    }
    
    
    @objc private func showCategoryFilterView(_ sender: UIButton) {
        
        let vc = Factory.provideCategoryFiltersSelectionScreen()
        vc.delegate = self
        vc.selectedCategories = filteringCategories
        
        vc.transitioningDelegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            presentationController.detents = [.large()]
        }
        self.present(vc, animated: true)
        
        
        
        
        
    }
    
    
    @objc private func basicFilterButtonPressed(_ sender: UIButton) {
        guard let filterButton = sender as? FilterButton else { return }
        filterButton.setTitleBold(title: filterButton.title(for: .normal)!, isBold: !filterButton.isFiltering)
        
        filterTransactions(sender)
    }
    
    
    @objc private func showDateFilterView(_ sender: UIButton) {
        guard let filterButton = sender as? FilterButton else { return }
        
        
        if !dateButton.isFiltering {
            let vc = Factory.provideDateRangeFilter()
            
            vc.transitioningDelegate = self
            vc.delegate = self
            if let presentationController = vc.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            self.present(vc, animated: true)
        } else {
            minDate = nil
            maxDate = nil
            filterTransactions(dateButton)
            filterButton.setTitleBold(title: "By date", isBold: false)
        }
    }
    
    
    private func reorderButtons() {
        guard let stackView = stackView else { return }
        
        let filteringButtons = stackView.arrangedSubviews.compactMap { $0 as? FilterButton }.filter { $0.isFiltering }
        let nonFilteringButtons = stackView.arrangedSubviews.compactMap { $0 as? FilterButton }.filter { !$0.isFiltering }
        
        let allButtons = filteringButtons + nonFilteringButtons
        
        UIView.animate(withDuration: 0.3) {
            stackView.arrangedSubviews.forEach { view in
                if view is FilterButton {
                    view.removeFromSuperview()
                }
            }
            allButtons.forEach { stackView.addArrangedSubview($0) }
            stackView.layoutIfNeeded()
        }
    }
    
    
    @objc private func showAmountFilterAlert(_ sender: UIButton) {
        guard let filterButton = sender as? FilterButton else { return }
        if !self.amountButton.isFiltering {
            let alert = UIAlertController(title: "Filter by Amount", message: "Enter minimum and maximum amount", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Minimum amount"
                textField.keyboardType = .decimalPad
            }
            
            alert.addTextField { textField in
                textField.placeholder = "Maximum amount"
                textField.keyboardType = .decimalPad
            }
            
            let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak self] _ in
                guard let self = self else { return }
                guard let minAmountText = alert.textFields?[0].text!.replacingOccurrences(of: ",", with: "."), let minAmount = Double(minAmountText),
                      let maxAmountText = alert.textFields?[1].text!.replacingOccurrences(of: ",", with: "."), let maxAmount = Double(maxAmountText),
                      maxAmount >= minAmount else {
                    AlertManager.invalidAmountFiltering(on: self)
                    return
                }
                
                filterButton.toggleFiltering()
                self.minAmount = minAmount
                self.maxAmount = maxAmount
                self.applyFilters()
                if maxAmount == minAmount {
                    filterButton.setTitleBold(title: "\(minAmount)\(User.shared.currency.symbol)", isBold: true)
                } else {
                    filterButton.setTitleBold(title: "\(minAmount)\(User.shared.currency.symbol) - \(maxAmount)\(User.shared.currency.symbol)", isBold: true)
                }
                
                self.reorderButtons()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(filterAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            self.minAmount = nil
            self.maxAmount = nil
            filterButton.setTitleBold(title: "By amount", isBold: false)
            filterTransactions(amountButton)
        }
    }
    
    
    @objc func filterTransactions(_ sender: UIButton?) {
        if sender is FilterButton {
            (sender as! FilterButton).toggleFiltering()
        }
        applyFilters()
        reorderButtons()
    }
    
    
    private func applyFilters() {
        filteredTransactions = transactions
        
        if incomeButton.isFiltering && expenseButton.isFiltering {
            filteredTransactions = transactions.filter { $0.transactionType == .income || $0.transactionType == .expense }
        } else if incomeButton.isFiltering {
            filteredTransactions = transactions.filter { $0.transactionType == .income }
        } else if expenseButton.isFiltering {
            filteredTransactions = transactions.filter { $0.transactionType == .expense }
        } else {
            filteredTransactions = []
        }
        
        if cashButton.isFiltering && cardButton.isFiltering {
            filteredTransactions = filteredTransactions.filter { $0.moneyType == .card || $0.moneyType == .cash }
        } else if cashButton.isFiltering {
            filteredTransactions = filteredTransactions.filter { $0.moneyType == .cash }
        } else if cardButton.isFiltering {
            filteredTransactions = filteredTransactions.filter { $0.moneyType == .card }
        } else {
            filteredTransactions = []
        }
        
        if let minAmount = minAmount, let maxAmount = maxAmount {
            filteredTransactions = filteredTransactions.filter { $0.money >= minAmount && $0.money <= maxAmount }
        }
        
        if let minDate = minDate, let maxDate = maxDate {
            filteredTransactions = filteredTransactions.filter { $0.date >= minDate && $0.date <= maxDate }
        }
        
        if !filteringCategories.isEmpty {
            filteredTransactions = filteredTransactions.filter({ transaction in
                filteringCategories.contains { category in
                    transaction.category == category
                }
            })
        }
        
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredTransactions = filteredTransactions.filter { $0.description.lowercased().contains(searchText.lowercased()) }
        }
        
        if orderButton.orderState == .ascending {
            filteredTransactions.sort { $0.date < $1.date }
        } else {
            filteredTransactions.sort { $0.date > $1.date }
        }
        
        updateSnapshot()
    }
    
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Transaction>(tableView: tableView) { (tableView, indexPath, transaction) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
            cell.load(with: transaction, isDayHidden: true)
            return cell
        }
    }
    
    
    private func groupTransactionsByDate(transactions: [Transaction]) -> [Section: [Transaction]] {
        var groupedTransactions: [Section: [Transaction]] = [:]
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let currentYear = Calendar.current.component(.year, from: Date())
        
        for transaction in transactions {
            let transactionDate = Calendar.current.startOfDay(for: transaction.date)
            let section: Section
            
            if transactionDate == today {
                section = .today
            } else if transactionDate == yesterday {
                section = .yesterday
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM d"
                var dateString = dateFormatter.string(from: transactionDate)
                
                let transactionYear = Calendar.current.component(.year, from: transactionDate)
                if transactionYear != currentYear {
                    dateString += ", \(transactionYear)"
                }
                
                section = .day(dateString, transactionDate)
            }
            
            if groupedTransactions[section] != nil {
                groupedTransactions[section]!.append(transaction)
            } else {
                groupedTransactions[section] = [transaction]
            }
        }
        
        return groupedTransactions
    }
    
    
    private func updateSnapshot() {
        if filteredTransactions.isEmpty {
            view.addSubview(emptyState!)
        } else {
            emptyState!.removeFromSuperview()
        }
        
        groupedTransactions = groupTransactionsByDate(transactions: filteredTransactions)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Transaction>()
        
        sortedSections = groupedTransactions.keys.sorted { (section1, section2) -> Bool in
            guard let date1 = section1.date, let date2 = section2.date else {
                return false
            }
            if orderButton.orderState == .ascending {
                return date1 < date2
            } else {
                return date1 > date2
            }
        }
        
        for section in sortedSections {
            if let transactions = groupedTransactions[section] {
                snapshot.appendSections([section])
                snapshot.appendItems(transactions, toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}

// MARK: - UITableViewDelegate and Datasource

extension AllTransactionsTableViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .accent
        
        switch dataSource.snapshot().sectionIdentifiers[section] {
        case .today:
            titleLabel.text = "Today"
        case .yesterday:
            titleLabel.text = "Yesterday"
        case .day(let dateString, _):
            titleLabel.text = dateString
        }
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        let greenLine = UIView()
        greenLine.translatesAutoresizingMaskIntoConstraints = false
        greenLine.backgroundColor = .accent
        headerView.addSubview(greenLine)
        
        NSLayoutConstraint.activate([
            greenLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            greenLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            greenLine.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            greenLine.heightAnchor.constraint(equalToConstant: 0.8)
        ])
        
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)
        
        if indexPath.row == numberOfRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sortedSections[indexPath.section]
        
        let transactions = groupedTransactions[section]!
        
        let transaction = transactions[indexPath.row]
        
        let vc = Factory.provideTransactionDetailScreen(storyboard: storyboard!, transaction: transaction)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension AllTransactionsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        applyFilters()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AllTransactionsTableViewController: UIViewControllerTransitioningDelegate {}

// MARK: - DateRangeFilterViewControllerDelegate
extension AllTransactionsTableViewController: DateRangeFilterViewControllerDelegate {
    
    func dateBeenSaved(firstDate: Date, secondDate: Date) {
        minDate = firstDate
        maxDate = secondDate
        let calendar = Calendar.current
        let secondDateAdjusted = calendar.date(byAdding: .day, value: -1, to: secondDate)!
        
        if firstDate.formatted(date: .abbreviated, time: .omitted) == secondDateAdjusted.formatted(date: .abbreviated, time: .omitted) {
            
            dateButton.setTitleBold(title: "\(firstDate.formatted(date: .abbreviated, time: .omitted))", isBold: true)
            
        } else {
            dateButton.setTitleBold(title: "\(firstDate.formatted(date: .abbreviated, time: .omitted)) - \n \(secondDateAdjusted.formatted(date: .abbreviated, time: .omitted))", isBold: true)
        }
        filterTransactions(dateButton)
    }
}

extension AllTransactionsTableViewController: CategoryFiltersSelectionViewControllerDelegate {
    
    func filtersSelected(categories: [Category]) {
        filteringCategories = categories
        
        categoryButton.setIsFiltering(!filteringCategories.isEmpty)
        applyFilters()
        reorderButtons()
        
        if categoryButton.isFiltering {
            categoryButton.setTitleBold(title: filteringCategories.count == 1 ? filteringCategories.first!.title : "Multiple categories", isBold: true)
        } else {
            
            categoryButton.setTitleBold(title: "Category", isBold: false)
        }
    }
    
    
}

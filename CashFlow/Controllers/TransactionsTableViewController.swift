//
//  TransactionsTableViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 25/6/24.
//

import UIKit

class TransactionsTableViewController: UITableViewController {
    
    private var moneyShouldHide = false
    
    private var emptyState: EmptyStateView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupEmptyState()
    }
    
    
    private func setupEmptyState() {
        emptyState = EmptyStateView(frame: tableView.bounds, message: "You didnt add any transactions yet")
    }
    
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
        tableView.isScrollEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if User.shared.username == "" || User.shared.transactions.isEmpty {
            view.addSubview(emptyState!)
        } else {
            emptyState?.removeFromSuperview()
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.shared.transactions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
        
        let transaction = User.shared.transactions[indexPath.row]
        cell.load(with: transaction, isDayHidden: false)
        cell.setMoneyVisibility(!moneyShouldHide)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = User.shared.transactions[indexPath.row]
        let vc = Factory.provideTransactionDetailScreen(storyboard: storyboard!, transaction: transaction)
        present(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension TransactionsTableViewController: HomeViewControllerDelegate {
    
    func userHasLoad() {
        tableView.reloadData()
        if User.shared.transactions.isEmpty {
            view.addSubview(emptyState!)
        } else {
            emptyState?.removeFromSuperview()
        }
    }
    
    
    func setMoneyVisibility(_ visibility: Bool) {
        moneyShouldHide = !visibility
        tableView.visibleCells.forEach { cell in
            if let transactionsCell = cell as? TransactionsTableViewCell {
                transactionsCell.setMoneyVisibility(visibility)
            }
        }
    }
}

//
//  HomeViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 19/6/24.
//

import UIKit
import NVActivityIndicatorView
import SkeletonView


protocol HomeViewControllerDelegate: AnyObject {
    func userHasLoad()
    func setMoneyVisibility(_ visibility: Bool)
}

class HomeViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var eyeButton: UIButton!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var cashLabel: UILabel!
    @IBOutlet var cardLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    
    weak var delegate: HomeViewControllerDelegate?
    
    private var childrenVC: TransactionsTableViewController?
    
    private let balanceVisibilityKey = "isBalanceVisible"
    
    private var isBalanceVisible: Bool {
        get {
            // Comprobar si el valor ya está establecido en UserDefaults
            if UserDefaults.standard.object(forKey: balanceVisibilityKey) == nil {
                // Establecer el valor predeterminado como true
                UserDefaults.standard.set(true, forKey: balanceVisibilityKey)
                return true
            }
            return UserDefaults.standard.bool(forKey: balanceVisibilityKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: balanceVisibilityKey)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupDelegate()
        loadTransactions()
        updateBalanceVisibilityUI()
        setupSkeletonViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    
    private func setupView() {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
        
        if User.shared.username != "" {
            titleLabel.text = "Welcome back \(User.shared.username)!"
            delegate?.setMoneyVisibility(isBalanceVisible)
            
            updateBalanceVisibilityUI()
        }
    }
    
    
    private func setupSkeletonViews() {
        titleLabel.isSkeletonable = true
        titleLabel.showGradientSkeleton()
        titleLabel.skeletonTextLineHeight = .fixed(25)
        
        balanceLabel.isSkeletonable = true
        balanceLabel.showGradientSkeleton()
        balanceLabel.skeletonTextLineHeight = .fixed(50)
        
        cashLabel.isSkeletonable = true
        cashLabel.showGradientSkeleton()
        cashLabel.skeletonTextLineHeight = .fixed(30)
        
        cardLabel.isSkeletonable = true
        cardLabel.showGradientSkeleton()
        cardLabel.skeletonTextLineHeight = .fixed(30)
    }
    
    
    private func loadTransactions() {
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60), type: .ballBeat, color: .accent)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    
    private func setupTabBar() {
        let tabBar = tabBarController as! TabBarViewController
        tabBar.delegt = self
    }
    
    
    private func setupDelegate() {
        children.forEach { vc in
            if let vc = vc as? TransactionsTableViewController {
                delegate = vc
                childrenVC = vc
            }
        }
    }
    
    
    @IBAction func seeAllButtonTapped(_ sender: Any) {
        let vc = Factory.provideAllTransactionsScreen(storyboard: storyboard!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func calculateBalance() {
        if isBalanceVisible {
            let totalBalance = User.shared.transactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
            balanceLabel.text = "\(String(format: "%.2f", totalBalance)) \(User.shared.currency.symbol)"
            balanceLabel.textColor = totalBalance < 0 ? .systemRed : .label
            
            
            let cashTransactions = User.shared.transactions.filter({ $0.moneyType == .cash })
            let cashBalance = cashTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
            cashLabel.text = "\(String(format: "%.2f", cashBalance)) \(User.shared.currency.symbol)"
            cashLabel.textColor = cashBalance < 0 ? .systemRed : .label
            
            let cardTransactions = User.shared.transactions.filter({ $0.moneyType == .card })
            let cardBalance = cardTransactions.reduce(0) { $0 + ($1.transactionType == .expense ? -$1.money : $1.money) }
            cardLabel.text = "\(String(format: "%.2f", cardBalance)) \(User.shared.currency.symbol)"
            cardLabel.textColor = cardBalance < 0 ? .systemRed : .label
        }
    }
    
    
    @IBAction func addTransactionButtonTapped(_ sender: Any) {
        let vc = Factory.provideAddTransactionScreen(storyboard: storyboard!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func eyeButtonTapped(_ sender: Any) {
        isBalanceVisible.toggle()
        updateBalanceVisibilityUI()
    }
    
    
    private func updateBalanceVisibilityUI() {
        delegate?.setMoneyVisibility(isBalanceVisible)
        toggleCellsMoneyVisibility(isBalanceVisible)
        
        if isBalanceVisible {
            calculateBalance()
            eyeButton.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        } else {
            balanceLabel.textColor = .label
            cashLabel.textColor = .label
            cardLabel.textColor = .label
            balanceLabel.text = "~~~ \(User.shared.currency.symbol)"
            cashLabel.text = "~~~ \(User.shared.currency.symbol)"
            cardLabel.text = "~~~ \(User.shared.currency.symbol)"
            eyeButton.setImage(UIImage(systemName: SFSymbols.eyeSlash), for: .normal)
        }
    }
    
    
    @IBAction func balanceDetailButtonPressed(_ sender: Any) {
        let vc = Factory.provideBalanceDetailScreen(storyboard: storyboard!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func toggleCellsMoneyVisibility(_ visibility: Bool) {
        childrenVC?.tableView.visibleCells.forEach({ cell in
            guard let cell = cell as? TransactionsTableViewCell else { return }
            cell.setMoneyVisibility(visibility)
        })
    }
}

// MARK: - TabBarViewControllerDelegate Methods
extension HomeViewController: TabBarViewControllerDelegate {
    
    func usernameHasLoad() {
        
        delegate?.userHasLoad()
        loadingView.isHidden = true
        calculateBalance()
        hideSkeletonViews()
        titleLabel.text = "Welcome back \(User.shared.username)!"
    }
    
    
    private func hideSkeletonViews() {
        titleLabel.hideSkeleton()
        balanceLabel.hideSkeleton()
        cashLabel.hideSkeleton()
        cardLabel.hideSkeleton()
    }
}

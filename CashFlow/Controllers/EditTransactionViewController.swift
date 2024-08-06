//
//  EditTransactionViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 12/7/24.
//

import UIKit
import FirebaseFirestoreInternal
import CoreLocation
import MapKit

class EditTransactionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var transactionTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var moneyTypeSwitch: AnimatedSegmentSwitch!
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var categoryBackgroundView: UIView!
    @IBOutlet var categoryImageBackgroundView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var map: MKMapView!
    
    private var centerCoordinateView: UIImageView!
    
    var transaction: Transaction!
    
    private var previousCategory: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwitches()
        loadData()
        setupMap()
        setupTextFields()
        setupCategory()
        setupCenterCoordinateView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    
    private func setupCenterCoordinateView() {
        centerCoordinateView = UIImageView(image: UIImage(systemName: SFSymbols.pin))
        centerCoordinateView.tintColor = .red
        centerCoordinateView.translatesAutoresizingMaskIntoConstraints = false
        map.addSubview(centerCoordinateView)
        
        NSLayoutConstraint.activate([
            centerCoordinateView.centerXAnchor.constraint(equalTo: map.centerXAnchor),
            centerCoordinateView.centerYAnchor.constraint(equalTo: map.centerYAnchor, constant: -16),
            centerCoordinateView.widthAnchor.constraint(equalToConstant: 32),
            centerCoordinateView.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    
    private func setupCategory() {
        previousCategory = transaction.category
        categoryBackgroundView.layer.borderColor = UIColor.gray.cgColor
        categoryBackgroundView.layer.borderWidth = 2
        categoryBackgroundView.clipsToBounds = true
        categoryBackgroundView.layer.cornerRadius = 26
    
        categoryImageView.tintColor = .white
        
        categoryImageBackgroundView.layer.cornerRadius = 20
        categoryImageBackgroundView.clipsToBounds = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(categoryBackgroundTouched(_:)))
        longPressGesture.minimumPressDuration = 0
        categoryBackgroundView.addGestureRecognizer(longPressGesture)
        categoryBackgroundView.isUserInteractionEnabled = true
        
        updateCategory()
    }
    
    
    private func updateCategory() {
        categoryLabel.text = transaction.category.title
        categoryImageView.image = transaction.category.image
        categoryImageBackgroundView.backgroundColor = transaction.category.color
    }
    
    
    @objc private func categoryBackgroundTouched(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: categoryBackgroundView)
            
        let isInside = categoryBackgroundView.bounds.contains(location)
        
        
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.08) {
                self.categoryBackgroundView.backgroundColor = UIColor.lightGray
            }
            
        case .cancelled, .failed:
            UIView.animate(withDuration: 0.08) {
                self.categoryBackgroundView.backgroundColor = UIColor.clear
            }
        case .ended:
            UIView.animate(withDuration: 0.08) {
                self.categoryBackgroundView.backgroundColor = UIColor.clear
            }
            if isInside {
                let vc = Factory.provideChangeCategoryScreen()
                vc.delegate = self
                vc.category = transaction.category
                vc.transitioningDelegate = self
                if let presentationController = vc.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.large()]
                }
                self.present(vc, animated: true)
            }
        default:
            break
        }
    }
    
    
    private func setupMap() {
        map.clipsToBounds = true
        map.layer.cornerRadius = 20
        map.showsUserLocation = true
        let latitude = transaction.location.latitude
        let longitude = transaction.location.longitude
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        
    }
    
    
    private func setupView() {
        navigationController?.navigationBar.isHidden = false
        title = "Edit Transaction"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    private func loadData() {
        amountTextField.text = String(transaction.money)
        descriptionTextField.text = transaction.description
        datePicker.date = transaction.date
        
        loadSwitches()
    }
    
    
    private func setupTextFields() {
        descriptionTextField.delegate = self
        amountTextField.delegate = self
    }
    
    
    private func loadSwitches() {
        switch transaction.transactionType {
        case .income:
            transactionTypeSwitch.selectedIndex = 0
        case .expense:
            transactionTypeSwitch.selectedIndex = 1
        }
        
        switch transaction.moneyType {
        case .cash:
            moneyTypeSwitch.selectedIndex = 0
        case .card:
            moneyTypeSwitch.selectedIndex = 1
        }
    }
    
    
    private func setupSwitches() {
        let switchConfig: (AnimatedSegmentSwitch) -> Void = { switchControl in
            switchControl.backgroundColor = .accent
            switchControl.selectedTitleColor = .accent
            switchControl.titleColor = .label
            switchControl.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
            switchControl.thumbColor = .white
            switchControl.cornerRadius = 20
        }
        
        transactionTypeSwitch.items = ["Income", "Expense"]
        switchConfig(transactionTypeSwitch)
        
        moneyTypeSwitch.items = ["Cash", "Card"]
        switchConfig(moneyTypeSwitch)
    }
    

    @IBAction func saveButtonTapped(_ sender: Any) {
        var invalidAmount = false
        var negativeAmount = false
        var invalidDescription = false
        var amountValue: Double?

        if let amountText = amountTextField.text?.replacingOccurrences(of: ",", with: "."), !amountText.isEmpty {
            if let value = Double(amountText) {
                if value > 0 {
                    amountValue = value
                } else {
                    negativeAmount = true
                }
            } else {
                invalidAmount = true
            }
        } else {
            invalidAmount = true
        }

        if let description = descriptionTextField.text, !description.isEmpty, Validator.isValidDescription(for: description) {
        } else {
            invalidDescription = true
        }

        if invalidAmount && invalidDescription {
            AlertManager.transactionInvalidAmountAndDescription(on: self)
            return
        } else if negativeAmount{
            AlertManager.transactionNegativeAmount(on: self)
            return
        } else if invalidAmount {
            AlertManager.transactionInvalidAmount(on: self)
            return
        } else if invalidDescription {
            AlertManager.transactionInvalidDescription(on: self)
            return
        }

        let transactionTypeIndex = transactionTypeSwitch.selectedIndex
        let moneyTypeIndex = moneyTypeSwitch.selectedIndex

        let transactionType: TransactionType = transactionTypeIndex == 0 ? .income : .expense
        let moneyType: MoneyType = moneyTypeIndex == 0 ? .cash : .card

        let centerCoordinate = map.centerCoordinate
        let location = GeoPoint(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        let category = transaction.category
        
        let transactionToSave = Transaction(
            id: transaction.id,
            description: descriptionTextField.text!,
            money: amountValue!,
            date: datePicker.date,
            transactionType: transactionType,
            moneyType: moneyType,
            location: location,
            category: category
        )
        
        AuthService.shared.updateTransaction(transaction: transactionToSave) { error in
            if let error = error {
                AlertManager.editTransactionError(on: self, with: error)
                return
            }
            AuthService.shared.fetchUser { [weak self] user, error in
                guard let self = self else { return }
                if let error = error {
                    AlertManager.showFetchingUserError(on: self, with: error)
                }
                if let user = user {
                    User.shared = user
                    self.navigationController?.viewControllers.forEach({ vc in
                        if vc is HomeViewController {
                            (vc as! HomeViewController).delegate?.userHasLoad()
                        }
                    })
                    if(transaction != transactionToSave) {
                        AlertManager.editTransactionSuccesful(on: self)
                    } else if category != previousCategory {
                        AlertManager.editTransactionSuccesful(on: self)
                    }
                } else {
                    AlertManager.showUnknownFetchingUserError(on: self)
                }
            }
            self.navigationController?.viewControllers.forEach({ vc in
                if vc is TransactionDetailViewController {
                    (vc as! TransactionDetailViewController).transaction = transactionToSave
                }
                
                if vc is AllTransactionsTableViewController {
                    let allTransactionsVC: AllTransactionsTableViewController = vc as! AllTransactionsTableViewController
                    allTransactionsVC.transactions.removeAll { $0.id == transactionToSave.id }
                    allTransactionsVC.transactions.append(transactionToSave)
                }
            })
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - ChangeCategoryViewControllerDelegate Methods
extension EditTransactionViewController: ChangeCategoryViewControllerDelegate {
    
    func categorySelected(selectedCategory: Category) {
        transaction.category = selectedCategory
        updateCategory()
    }
}

// MARK: - UITextFieldDelegate Methods
extension EditTransactionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

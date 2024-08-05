//
//  AddTransactionViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 28/6/24.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestoreInternal

class AddTransactionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet var transactionTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var moneyTypeSwitch: AnimatedSegmentSwitch!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var categoryBackgroundView: UIView!
    @IBOutlet var categoryImageBackgroundView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var map: MKMapView!
    
    private var category: Category!
    
    private var annotation: MKPointAnnotation!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwitches()
        setupDatePicker()
        setupTextFields()
        setupMap()
        setupLocationManager()
        setupCategory()
    }
    
    private func setupMap() {
        map.clipsToBounds = true
        map.layer.cornerRadius = 20
        map.showsUserLocation = true
        map.delegate = self
    }
    
    
    private func setupCategory() {
        category = .general
        
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
        categoryLabel.text = category.title
        categoryImageView.image = category.image
        categoryImageBackgroundView.backgroundColor = category.color
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
                vc.category = category
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

    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    private func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Blank Description"
        map.addAnnotation(annotation)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
        setupTabBarController()
    }
    
    
    private func setupTabBarController() {
        tabBarController?.tabBar.isHidden = true
    }
    
    
    private func setupTextFields() {
        descriptionTextField.delegate = self
        amountTextField.delegate = self
    }
    
    
    private func setupDatePicker() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        if let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: currentDate) {
            datePicker.minimumDate = tenYearsAgo
        }
        
        datePicker.maximumDate = currentDate
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
    
    
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Add Transaction"
        navigationItem.backButtonTitle = "Back"
    }
    
   
    @IBAction func descriptionTextFieldEditingChanged(_ sender: Any) {
        annotation.title = descriptionTextField.text!.isEmpty ? "Blank Description" : descriptionTextField.text
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
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
        } else if negativeAmount {
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
        
        let location = GeoPoint(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        let transaction = Transaction(
            id: UUID(),
            description: descriptionTextField.text!,
            money: amountValue!,
            date: datePicker.date,
            transactionType: transactionType,
            moneyType: moneyType,
            location: location,
            category: category
        )
        
        AuthService.shared.insertTransaction(transaction: transaction) { error in
            if let error = error {
                AlertManager.transactionNotSaved(on: self, with: error)
                return
            } else {
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
                        AlertManager.transactionWasSaved(on: self)
                    } else {
                        AlertManager.showUnknownFetchingUserError(on: self)
                    }
                }
                User.shared.transactions.append(transaction)
                User.shared.transactions.sort { $0.date > $1.date }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate Methods
extension AddTransactionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        addAnnotation(at: center)
        
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate Methods
extension AddTransactionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "DraggablePin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.isDraggable = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}

// MARK: - UITextFieldDelegate Methods
extension AddTransactionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

//MARK: - ChangeCategoryViewControllerDelegate Methods
extension AddTransactionViewController: ChangeCategoryViewControllerDelegate {
    
    func categorySelected(selectedCategory: Category) {
        category = selectedCategory
        updateCategory()
    }
}

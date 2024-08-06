//
//  TransactionDetailViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 11/7/24.
//

import UIKit
import MapKit

class TransactionDetailViewController: UIViewController {

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var transactionTypeLabel: UILabel!
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var categoryBackgroundView: UIView!
    @IBOutlet var categoryImageBackgroundView: UIView!
    
    @IBOutlet var transactionIdLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var map: MKMapView!
    
    public var transaction: Transaction!
    
    public var hasToUpdate = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupLabels()
        setupNavigation()
        setupMap()
    }
    
    
    private func setupMap() {
        map.removeAnnotations(map.annotations)
        map.clipsToBounds = true
        map.layer.cornerRadius = 32
        map.showsUserLocation = true
        map.delegate = self
        
        let latitude = transaction.location.latitude
        let longitude = transaction.location.longitude
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        addAnnotation(at: center)
    }
    
    
    private func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = transaction.description
        map.addAnnotation(annotation)
    }
    
    
    private func setupNavigation() {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = .systemRed
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
        title = "Transaction"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    @objc func editButtonTapped() {
        let vc = Factory.provideEditTransactionScreen(storyboard: storyboard!)
        vc.transaction = transaction
        title = "Back"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func deleteButtonTapped() {
        AlertManager.deleteTransactionAlert(on: self, transaction: transaction)
    }
        
    
    private func setupLabels() {
        setupTitleLabels()
        setupDateLabel()
        setupTransactionTypeLabel()
        setupTransactionIdLabel()
        setupCategory()
    }
    
    
    private func setupCategory() {
        categoryLabel.text = transaction.category.title
        
        categoryBackgroundView.layer.borderColor = UIColor.gray.cgColor
        categoryBackgroundView.layer.borderWidth = 2
        categoryBackgroundView.clipsToBounds = true
        categoryBackgroundView.layer.cornerRadius = 16
        
        categoryImageView.image = transaction.category.image
        categoryImageView.tintColor = .white
        
        categoryImageBackgroundView.layer.cornerRadius = 14
        categoryImageBackgroundView.clipsToBounds = true
        categoryImageBackgroundView.backgroundColor = transaction.category.color
        
    }
    
    
    private func setupTransactionIdLabel() {
        transactionIdLabel.text = "Transaction #\(transaction.id)"
    }
    
    
    private func setupTitleLabels() {
        amountLabel.text = "\(transaction.formattedMoneyString) \(User.shared.currency.symbol)"
        if transaction.transactionType == .income {
            amountLabel.textColor = .accent
        } else {
            amountLabel.textColor = .systemRed
        }
        descriptionLabel.text = transaction.description
    }
    
    
    private func setupDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .year) {
            dateFormatter.dateFormat = "MMMM d, HH:mm"
        } else {
            dateFormatter.dateFormat = "MMMM d, yyyy, HH:mm"
        }
        
        dateLabel.text = "Processed on \(dateFormatter.string(from: transaction.date))"
    }
    
    
    private func setupTransactionTypeLabel() {
        switch transaction.transactionType {
            case .income:
                switch transaction.moneyType {
                    case .card:
                        transactionTypeLabel.text = "Deposited in your card balance"
                    case .cash:
                        transactionTypeLabel.text = "Deposited in your cash balance"
                }
                
            case .expense:
                switch transaction.moneyType {
                    case .card:
                        transactionTypeLabel.text = "Paid with card"
                    case .cash:
                        transactionTypeLabel.text = "Paid with cash"
                }
        }
    }
    
    
    private func setupBackgroundView() {
        backgroundView.layer.cornerRadius = 46
        backgroundView.backgroundColor = .systemGray4
    }
}

// MARK: - MKMapViewDelegate Methods
extension TransactionDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "DraggablePin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.isDraggable = false
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}

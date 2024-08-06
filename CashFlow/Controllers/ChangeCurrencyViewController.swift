//
//  ChangeCurrencyViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/6/24.
//

import UIKit

class ChangeCurrencyViewController: UIViewController {
    
    private var currencies = [
        Currency.euro,
        Currency.dollar
    ]
    
    @IBOutlet var pickerView: UIPickerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCurrency()
        
    }
    
    
    private func setupView() {
        pickerView.delegate = self
        let currency = User.shared.currency
        pickerView.selectRow(currencies.firstIndex(of: currency)!, inComponent: 0, animated: false)
    }
    
    
    private func saveCurrency() {
        let currency = currencies[pickerView.selectedRow(inComponent: 0)]
        if currency != User.shared.currency {
            AuthService.shared.updateCurrency(newCurrency: currency) { error in
                if let error = error {
                    AlertManager.showChangingCurrencyError(on: self, with: error)
                } else {
                    User.shared.currency = currency
                }
            }
        }
    }
}


extension ChangeCurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencies.count
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(currencies[row].description) \(currencies[row].symbol)"
    }
    
}

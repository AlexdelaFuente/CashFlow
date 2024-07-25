//
//  ChangeLanguageViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/6/24.
//

import UIKit

class ChangeLanguageViewController: UIViewController {

    @IBOutlet var pickerView: UIPickerView!
    
    private var languages = [
        Language.english,
        Language.spanish
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveLanguage()
    }
    
    
    private func setupView() {
        pickerView.delegate = self
        let language = User.shared.language
        pickerView.selectRow(languages.firstIndex(of: language)!, inComponent: 0, animated: false)
    }
    
    
    private func saveLanguage() {
        let language = languages[pickerView.selectedRow(inComponent: 0)]
        if language != User.shared.language {
            AuthService.shared.updateLanguage(newLanguage: language) { error in
                if let error = error {
                    AlertManager.showChangingLanguageError(on: self, with: error)
                } else {
                    User.shared.language = language
                }
            }
        }
    }
    
}

extension ChangeLanguageViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        languages.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].name
    }
    
}

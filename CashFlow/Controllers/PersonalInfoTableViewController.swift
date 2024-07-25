//
//  PersonalInfoTableViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 21/6/24.
//

import UIKit
import SearchTextField

class PersonalInfoTableViewController: UITableViewController {
    
    private var sections: [(title: String, cells: [String])] = [
        (title: "Personal information", cells: [
            "Username",
            "Email",
            "Birth date",
            "Phone number",
        ]),
        (title: "Address", cells: [
            "Address",
            "City",
            "Zip code"
        ])
    ]
    
    private let cities = ["A Coruña", "Albacete", "Alcalá de Henares", "Alcorcón", "Algeciras", "Alicante", "Almería", "Alzira", "Avilés", "Badajoz", "Badalona", "Barcelona", "Barakaldo", "Basingstoke", "Bath", "Bedford", "Benidorm", "Bexley", "Bilbao", "Birkenhead", "Birmingham", "Blackburn", "Blackpool", "Bolton", "Bournemouth", "Bradford", "Brighton", "Bristol", "Burgos", "Burnley", "Bury", "Cádiz", "Cartagena", "Castellón de la Plana", "Ceuta", "Chatham", "Chelmsford", "Cheltenham", "Ciudad Real", "Córdoba", "Coventry", "Crawley", "Doncaster", "Dudley", "Dundee", "Eastbourne", "El Ejido", "Elche", "Exeter", "Fuenlabrada", "Gandía", "Gateshead", "Getafe", "Gijón", "Granada", "Grimsby", "Guadalajara", "Guildford", "Harlow", "Hartlepool", "Hastings", "Hemel Hempstead", "Huelva", "Hull", "Huesca", "Ipswich", "Jaén", "Jerez de la Frontera", "Kingston upon Hull", "Kingston upon Thames", "L’Hospitalet de Llobregat", "La Línea de la Concepción", "Las Palmas de Gran Canaria", "Las Rozas de Madrid", "Leeds", "Leganés", "Leicester", "León", "Lérida", "Leicester", "Liverpool", "Logroño", "London", "Luton", "Maidstone", "Málaga", "Manchester", "Marbella", "Mataró", "Melilla", "Middlesbrough", "Milton Keynes", "Málaga", "Manchester", "Mataró", "Melilla", "Milton Keynes", "Móstoles", "Murcia", "Newcastle upon Tyne", "Norwich", "Nottingham", "Oldham", "Orihuela", "Ourense", "Oxford", "Pamplona", "Parla", "Peterborough", "Plymouth", "Poole", "Ponferrada", "Pozuelo de Alarcón", "Redding", "Redditch", "Reus", "Rivas-Vaciamadrid", "Rochdale", "Roquetas de Mar", "Rotherham", "Sabadell", "Sagunto", "Salamanca", "San Fernando", "San Sebastián de los Reyes", "Santa Coloma de Gramenet", "Santa Cruz de Tenerife", "Santander", "Santiago de Compostela", "Segovia", "Sevilla", "Sheffield", "Solihull", "Southampton", "Southend-on-Sea", "Southport", "St Albans", "Stevenage", "Stockport", "Stoke-on-Trent", "Sunderland", "Sutton Coldfield", "Swindon", "Talavera de la Reina", "Tarragona", "Telde", "Terrassa", "Torrejón de Ardoz", "Valencia", "Valladolid", "Vitoria-Gasteiz", "Vigo", "Watford", "Wolverhampton", "Woking", "Wokingham", "Wolverhampton", "Worcester", "Worthing", "York", "Zaragoza"]
    
    private let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    private var textFieldTag = 0
    private var textFields: [UITextField] = []
    private var cellDatePicker: UIDatePicker?
    
    private var originalUser: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        
        originalUser = User.shared
        
        registerCells()
        tableView.allowsSelection = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBars()
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    private func setupBars() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tabBarController?.tabBar.isHidden = true
    }
    
    private func registerCells() {
        tableView.register(PersonalInfoCell.self, forCellReuseIdentifier: "PersonalInfoCell")
        tableView.register(BirthDateCell.self, forCellReuseIdentifier: "BirthDateCell")
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTitle = sections[indexPath.section].cells[indexPath.row]
        
        if cellTitle == "Birth date" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BirthDateCell", for: indexPath) as? BirthDateCell else { return UITableViewCell() }
            
            cell.datePicker.date = User.shared.birthDate
            cellDatePicker = cell.datePicker
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalInfoCell", for: indexPath) as? PersonalInfoCell else { return UITableViewCell()}
            
            cell.titleLabel.text = cellTitle
            cell.textField.placeholder = "Enter \(cellTitle)"
            cell.textField.delegate = self
            cell.textField.tag = textFieldTag
            textFieldTag += 1
            textFields.append(cell.textField)
            
            switch(cell.textField.tag) {
            case 0: // Username
                cell.textField.text = User.shared.username
            case 1: // Email
                cell.textField.text = User.shared.email
                cell.textField.isEnabled = false
                cell.textField.textColor = .lightGray
                cell.textField.backgroundColor = .systemGray6
            case 2: // Phone number
                cell.textField.text = User.shared.phoneNumber
                cell.textField.keyboardType = .phonePad
            case 3: // Address
                cell.textField.text = User.shared.address
            case 4: // City
                cell.textField.text = User.shared.city
                cell.textField.inlineMode = true
                cell.textField.startSuggestingImmediately = true
                cell.textField.filterStrings(cities)
                
            case 5: // Zip code
                cell.textField.text = User.shared.zipCode
                cell.textField.keyboardType = .numberPad
            default:
                return cell
            }
            return cell
        }
    }
}

// MARK: - UITextFieldDelegate Methods
extension PersonalInfoTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - UINavigationControllerDelegate
extension PersonalInfoTableViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController != self else { return }
        
        var isValid = true
        let birthDate = cellDatePicker?.date ?? Date()
        User.shared.birthDate = birthDate
        
        for textField in textFields {
            switch textField.tag {
            case 0:
                let username = textField.text ?? ""
                if Validator.isValidUsername(for: username) {
                    User.shared.username = username
                } else {
                    isValid = false
                }
            case 2:
                let phoneNumber = textField.text ?? ""
                if Validator.isValidPhoneNumber(for: phoneNumber) || phoneNumber.isEmpty {
                    User.shared.phoneNumber = phoneNumber
                } else {
                    isValid = false
                }
            case 3:
                let address = textField.text ?? ""
                User.shared.address = address
            case 4:
                let city = textField.text ?? ""
                User.shared.city = city
            case 5:
                let zipCode = textField.text ?? ""
                if Validator.isValidZipCode(for: zipCode) || zipCode.isEmpty {
                    User.shared.zipCode = zipCode
                } else {
                    isValid = false
                }
            default:
                break
            }
        }
        
        if isValid {
            if User.shared != originalUser {
                AuthService.shared.updatePersonalInfo(user: User.shared) { error in
                    if let error = error {
                        AlertManager.showWrongPersonalInformationWithError(on: self, with: error)
                    } else {
                        AlertManager.personalInformationUpdatedAlert(on: self)
                    }
                }
            }
        } else {
            AlertManager.showWrongPersonalInformation(on: self)
        }
    }
}

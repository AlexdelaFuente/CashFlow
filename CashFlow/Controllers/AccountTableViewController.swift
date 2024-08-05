//
//  AccountTableViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 20/6/24.
//

import UIKit

class AccountTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    private var sections: [(title: String, cells: [Cell])] = [
        (title: "General", cells: [
            Cell(title: "Personal information", imageName: SFSymbols.personalInformation),
            Cell(title: "Help", imageName: SFSymbols.help)
        ]),
        (title: "Account preferences", cells: [
            Cell(title: "Currency", imageName: SFSymbols.currency),
        ]),
        (title: "Security", cells: [
            Cell(title: "Change password", imageName: SFSymbols.changePassword)
        ]),
        (title: "About", cells: [
            Cell(title: "Privacy policy", imageName: SFSymbols.privacyPolicy)
        ]),
        (title: "Session", cells: [
            Cell(title: "Log out", imageName: SFSymbols.logOut)
        ])
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
    }
    
    
    private func registerCell() {
        let nib = UINib(nibName: "GeneralTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = createCell(indexPath: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GeneralTableViewCell
        
        //Personal information case
        if checkCell(cell: cell, SFSymbol: SFSymbols.personalInformation) {
            let vc = Factory.providePersonalInfoScreen(storyboard: storyboard!)
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
        // Log out case
        if checkCell(cell: cell, SFSymbol: SFSymbols.logOut) {
            AlertManager.showLogingOutConfirmationAlert(on: self)
        }
        
        //Currency case
        if checkCell(cell: cell, SFSymbol: SFSymbols.currency) {
            let vc = Factory.provideChangeCurrencyScreen()
            
            vc.transitioningDelegate = self
            if let presentationController = vc.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            self.present(vc, animated: true)
        }
        
        //Change password case
        if checkCell(cell: cell, SFSymbol: SFSymbols.changePassword) {
            let vc = Factory.provideChangePasswordScreen(storyboard: storyboard!)
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        //Privacy policy case
        if checkCell(cell: cell, SFSymbol: SFSymbols.privacyPolicy) {
            let vc = Factory.providePrivacyPolicyScreen(storyboard: storyboard!)
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        //Help case
        if checkCell(cell: cell, SFSymbol: SFSymbols.help) {
            let vc = Factory.provideHelpScreen(storyboard: storyboard!)
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    /// Used to check what cell had been tapped
    /// - Parameters:
    ///   - cell: the cell tapped
    ///   - SFSymbol: the SFSymbol enum case to differentiate the cells (as two cells cant have the same SFSymbol Image)
    /// - Returns: true if the cells image and the SFSymbol image coincide
    private func checkCell(cell: GeneralTableViewCell, SFSymbol: String) -> Bool{
        return cell.imageViewCell.image == UIImage(systemName: SFSymbol)
    }
    
    
    private func createCell(indexPath: IndexPath) -> GeneralTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GeneralTableViewCell
    }
    
    
    private func configure(cell: GeneralTableViewCell, for indexPath: IndexPath) {
        let cellData = sections[indexPath.section].cells[indexPath.row]
        cell.setup(systemImage: cellData.imageName,
                   title: cellData.title)
    }
}


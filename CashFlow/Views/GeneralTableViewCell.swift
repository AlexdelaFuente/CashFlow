//
//  GeneralTableViewCell.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 20/6/24.
//

import UIKit

class GeneralTableViewCell: UITableViewCell {


    @IBOutlet var label: UILabel!
    @IBOutlet var imageViewCell: UIImageView!
    
    func setup(systemImage: String, title: String) {
        imageViewCell.image = UIImage(systemName: systemImage)
        label.text = title
    }
}

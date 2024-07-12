//
//  FilterButton.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 26/6/24.
//

import UIKit

class FilterButton: UIButton {
    
    public var isFiltering: Bool = false
    private var crossImageView: UIImageView?
    
    
    init(title: String) {
        super.init(frame: .zero)
        commonInit(title: title)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(title: "")
    }
    
    
    private func commonInit(title: String) {
        self.configuration = .filled()
        self.setTitleColor(.white, for: .normal)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 20
        self.tintColor = UIColor.accent.withAlphaComponent(0.35)
        self.clipsToBounds = true
        self.setTitle(title, for: .normal)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        
        addCrossImageView()
    }
    
    
    private func addCrossImageView() {
        let crossImage = UIImage(systemName: SFSymbols.xmark)
        let imageView = UIImageView(image: crossImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.isHidden = true
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
        self.crossImageView = imageView
    }
    
    
    public func toggleFiltering() {
        isFiltering.toggle()
        if isFiltering {
            
            self.tintColor = .accent
            crossImageView?.isHidden = false
        } else {
            self.tintColor = UIColor.accent.withAlphaComponent(0.35)
            crossImageView?.isHidden = true
        }
    }
}

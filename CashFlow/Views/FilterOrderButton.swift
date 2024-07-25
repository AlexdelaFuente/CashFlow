//
//  FilterOrderButton.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 11/7/24.
//

import UIKit

class FilterOrderButton: UIButton {
    
    enum OrderState {
        case ascending
        case descending
        
        var title: String {
            switch self {
            case .ascending:
                return " date"
            case .descending:
                return " date"
            }
        }
        
        var image: UIImage {
            switch self {
            case .ascending:
                return UIImage(systemName: "arrow.down")!
            case .descending:
                return UIImage(systemName: "arrow.up")!
            }
        }
        
        var next: OrderState {
            switch self {
            case .ascending:
                return .descending
            case .descending:
                return .ascending
            }
        }
    }
    
    var orderState: OrderState = .descending {
        didSet {
            self.setTitle(orderState.title, for: .normal)
            self.setImage(orderState.image, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: self.titleLabel?.font.pointSize ?? 17)]
                
        let attributedTitle = NSAttributedString(string: orderState.title, attributes: attributes)
        self.setAttributedTitle(attributedTitle, for: .normal)
        self.setImage(orderState.image, for: .normal)
        self.tintColor = .white
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .accent
        
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        
        self.layer.borderColor = UIColor.systemBackground.cgColor
        self.layer.borderWidth = 5
        
        self.addTarget(self, action: #selector(toggleOrderState), for: .touchUpInside)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = UIColor.background.cgColor
        }
    }
    
    
    
    @objc private func toggleOrderState() {
        orderState = orderState.next
    }
}

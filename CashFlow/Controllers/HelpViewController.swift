//
//  HelpViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 5/8/24.
//

import UIKit
import WebKit

class HelpViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let filePath = Bundle.main.path(forResource: "CashFlow Help", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

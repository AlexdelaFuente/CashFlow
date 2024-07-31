//
//  ChangeCategoryViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 31/7/24.
//

import UIKit

protocol ChangeCategoryViewControllerDelegate: AnyObject {
    func categorySelected(selectedCategory: Category)
}

class ChangeCategoryViewController: UIViewController {

    @IBOutlet var selectCategoryLabel: UILabel!
    private var tableView: UITableView!
    
    public var delegate: ChangeCategoryViewControllerDelegate?
    
    private let categories: [Category] = [
        .general, .entertainment, .shopping, .groceries, .restaurants, .salary, .transportation, .traveling, .healthcare
    ]
    
    public var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    private func setupTable() {
        tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: selectCategoryLabel.bottomAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UINib(nibName: "GeneralTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
        tableView.selectRow(at: IndexPath(row: categories.firstIndex(of: category)!, section: 0), animated: true, scrollPosition: .none)
        
        
    }

    

}

//MARK: - UITableViewDataSource Methods
extension ChangeCategoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell") as! GeneralTableViewCell
        let category = categories[indexPath.row]
        cell.label.text = category.title
        cell.label.font = .systemFont(ofSize: 17, weight: .bold)
        cell.imageViewCell.backgroundColor = category.color
        cell.imageViewCell.clipsToBounds = false
        cell.imageViewCell.layer.cornerRadius = 25
        
        let imageView = UIImageView(image: category.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(imageView)
        
        imageView.tintColor = .white
        imageView.clipsToBounds = false
        
        let aspectRatio = category.image.size.height / category.image.size.width
        let maxDimension: CGFloat = 42
        
        let heightConstraint = aspectRatio > 1 ? maxDimension : maxDimension * aspectRatio
        let widthConstraint = aspectRatio > 1 ? maxDimension / aspectRatio : maxDimension
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: cell.imageViewCell.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: cell.imageViewCell.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: heightConstraint),
            imageView.widthAnchor.constraint(equalToConstant: widthConstraint)
        ])
        
        return cell
    }

    
    
}

//MARK: - UITableViewDelegate Methods
extension ChangeCategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        delegate?.categorySelected(selectedCategory: selectedCategory)
        dismiss(animated: true)
        
        
    }
}

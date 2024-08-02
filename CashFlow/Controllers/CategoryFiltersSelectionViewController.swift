//
//  CategoryFiltersSelectionViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 1/8/24.
//

import UIKit


protocol CategoryFiltersSelectionViewControllerDelegate: AnyObject {
    
    func filtersSelected(categories: [Category])
}

class CategoryFiltersSelectionViewController: UIViewController {

    @IBOutlet var selectCategoryLabel: UILabel!
    private var tableView: UITableView!
    
    public var selectedCategories: [Category]!
    
    private let categories: [Category] = [
        .general, .entertainment, .shopping, .groceries, .restaurants, .salary, .transportation, .traveling, .healthcare
    ]
    
    public var delegate: CategoryFiltersSelectionViewControllerDelegate!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

   
    private func setupTable() {
        tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        
        tableView.allowsMultipleSelection = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: selectCategoryLabel.bottomAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UINib(nibName: "GeneralTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
        
        selectedCategories.forEach { category in
            tableView.selectRow(at: IndexPath(row: categories.firstIndex(of: category)!, section: 0), animated: true, scrollPosition: .none)
        }
        
        
    }
    

    @IBAction func clearButtonTapped(_ sender: Any) {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            selectedIndexPaths.forEach { indexPath in
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        
        selectedCategories.removeAll()
        
        selectedIndexPaths?.forEach({ indexPath in
            selectedCategories.append(categories[indexPath.row])
        })
        
        delegate.filtersSelected(categories: selectedCategories)
        dismiss(animated: true)
    }
    
}

//MARK: - UITableViewDataSource Methods
extension CategoryFiltersSelectionViewController: UITableViewDataSource {
    
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
        imageView.clipsToBounds = true
        
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

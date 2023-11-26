//
//  ProductsListViewController.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import UIKit

class ProductsListViewController: UIViewController {
    
    private let productsTableView: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = .purple
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .white
        return indicator
    }()
    
    private let totalPriceLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "total: 0$"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    private let productsViewModel = ProductsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProductsViewModel()
        productsViewModel.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    //MARK: setup UI
    func setupUI() {
        view.backgroundColor = .orange
        setupTableView()
        setupIndicator()
        setupTotalPriceLbl()
    }
    
    func setupTableView() {
        view.addSubview(productsTableView)
        productsTableView.dataSource = self

        NSLayoutConstraint.activate([
            productsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        productsTableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
    }

    func setupIndicator() {
        DispatchQueue.main.async {
            self.view.addSubview(self.activityIndicator)
            NSLayoutConstraint.activate([
                self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }
    }
   
    
    func setupTotalPriceLbl() {
        view.addSubview(totalPriceLbl)
        
        NSLayoutConstraint.activate([
            totalPriceLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalPriceLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalPriceLbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: Setup delegates
    private func setupProductsViewModel() {
        productsViewModel.delegate = self
    }
}

extension ProductsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productsViewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentProduct = productsViewModel.products?[indexPath.row],
              let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .default
        cell.delegate = self
        cell.reload(with: currentProduct)
        return cell
    }
}

extension ProductsListViewController: ProductsListViewModelDelegate {
    func productsAmountChanged() {
        totalPriceLbl.text = "Total price: \(productsViewModel.totalPrice ?? 0)"
        productsTableView.reloadData()
    }
    
    func productsFetched() {
        activityIndicator.stopAnimating()
        productsTableView.reloadData()
    }
    
    func showAlert(message: String) {
        showAlert(title: "", message: message)
    }
}

extension ProductsListViewController: ProductCellDelegate {
    func removeProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.removeProduct(at: indexPath.row)
        }
    }
    
    func addProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.addProduct(at: indexPath.row)
        }
    }
}

//
//  ProductsListViewModel.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import Foundation

protocol ProductsListViewModelDelegate: AnyObject {    
    func productsFetched()
    func productsAmountChanged()
    func showAlert(message: String)
}

class ProductsListViewModel {
    
    weak var delegate: ProductsListViewModelDelegate?
    
    var products: [ProductModel]?
    var totalPrice: Double? { products?.reduce(0) { $0 + $1.price * Double(($1.selectedAmount ?? 0))} }
    
    func viewDidLoad() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        NetworkManager.shared.fetchProducts { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let products):
                self.products = products
                delegate?.productsFetched()
            case .failure(let error):
                delegate?.showAlert(message: error.localizedDescription)
                break
            }
        }
    }
    
    func addProduct(at index: Int) {
        let product = products?[index]
        products?[index].selectedAmount = (product?.selectedAmount ?? 0 ) + 1
        if let product = products?[index] {
            if product.selectedAmount ?? 0 > product.stock {
                delegate?.showAlert(message: "products are out of stock")
            } else {
                delegate?.productsAmountChanged()
            }
        }
    }
    
    func removeProduct(at index: Int) {
        let product = products?[index]
        products?[index].selectedAmount = (product?.selectedAmount ?? 0 ) - 1
        
        if products?[index].selectedAmount ?? 0 <= 0 {
            delegate?.showAlert(message: "product is already 0")
        } else {
            delegate?.productsAmountChanged()
        }
    }
    
    var numberOfRowsInSection: Int {
        products?.count ?? 0
    }
}

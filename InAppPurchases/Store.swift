//
//  Store.swift
//  InAppPurchases
//
//  Created by constantine kos on 03.01.2021.
//

import StoreKit


typealias FetchCompletionHandler = (([SKProduct]) -> Void)
typealias PurchaseCompletionHandler = ((SKPaymentTransaction?) -> Void)

class Store: NSObject, ObservableObject {
    
    @Published var allrecipes = [Recipe]()
    
    private let allIdentifiers = Set(["io.InAppPurchases.berry-blue", "io.InAppPurchases.lemon-berry"])
    
    
    private var completedPurchases = [String]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                for index in self.allrecipes.indices {
                    self.allrecipes[index].isLocked = !self.completedPurchases.contains(self.allrecipes[index].id)
                }
            }
        }
    }
    private var productRequest: SKProductsRequest?
    private var fetchedProducts = [SKProduct]()
    private var fetchCompletionHandler: FetchCompletionHandler?
    private var purchaseCompletionHandler: PurchaseCompletionHandler?
    
    override init() {
        super.init()
        
        startObservingPaymentQueue()
        
        fetchProducts { (products) in
            self.allrecipes = products.map { Recipe(product: $0) }
        }
    }
    
    private func startObservingPaymentQueue() {
        SKPaymentQueue.default().add(self)
    }
 
    private func fetchProducts(_ completion: @escaping FetchCompletionHandler) {
        guard self.productRequest == nil else { return }
        
        fetchCompletionHandler = completion
        
        productRequest = SKProductsRequest(productIdentifiers: allIdentifiers)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    private func buy(_ product: SKProduct, completion: @escaping PurchaseCompletionHandler) {
        purchaseCompletionHandler = completion
        
        let payment = SKPayment(product: product)
        
        SKPaymentQueue.default().add(payment)
        
    }
}


extension Store {
    
    func product(for identifier: String) -> SKProduct? {
        return fetchedProducts.first(where: { $0.productIdentifier == identifier })
    }
    
    public func purchaseProduct(_ product: SKProduct) {
        startObservingPaymentQueue()
        
        buy(product) { _ in
            
        }
    }
}


extension Store: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            var shouldFinishTransaction = false
            
            switch transaction.transactionState {

            case .purchased, .restored:
                completedPurchases.append(transaction.payment.productIdentifier)
                shouldFinishTransaction = true
            case .failed:
                shouldFinishTransaction = true
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
            
            if shouldFinishTransaction {
                SKPaymentQueue.default().finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.purchaseCompletionHandler?(transaction)
                    self.purchaseCompletionHandler = nil
                }
            }
        }
    }
    
    
}


extension Store: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let loadedProducts = response.products
        let invalidProducts = response.invalidProductIdentifiers
        
        guard !loadedProducts.isEmpty else {
            print("# Can not load products")
            if !invalidProducts.isEmpty {
                print("# Invalid products found: \(invalidProducts)")
            }
            productRequest = nil
            return
        }
        
        // cached the fetched products
        fetchedProducts = loadedProducts
        
        // Notify anyone waiting on the product load
        DispatchQueue.main.async {
            self.fetchCompletionHandler?(loadedProducts)
            
            self.fetchCompletionHandler = nil
            self.productRequest = nil
        }
        
        
        
    }
    
    
}

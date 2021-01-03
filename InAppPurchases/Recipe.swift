//
//  Recipe.swift
//  InAppPurchases
//
//  Created by constantine kos on 03.01.2021.
//

import Foundation
import StoreKit



struct Recipe: Hashable {
    var id: String
    var title: String
    var description: String
    var isLocked: Bool
    var price: String?
    
    let locale: Locale
    let imageName: String
    
    
    lazy var formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.locale = locale
        return nf
    }()
    
    
    init(product: SKProduct, isLocked: Bool = true) {
        self.id = product.productIdentifier
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        self.isLocked = isLocked
        self.locale = product.priceLocale
        self.imageName = product.productIdentifier
        
        if isLocked {
            self.price = self.formatter.string(from: product.price)
        }
    }
}

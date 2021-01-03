//
//  InAppPurchasesApp.swift
//  InAppPurchases
//
//  Created by constantine kos on 03.01.2021.
//

import SwiftUI

@main
struct InAppPurchasesApp: App {
    
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

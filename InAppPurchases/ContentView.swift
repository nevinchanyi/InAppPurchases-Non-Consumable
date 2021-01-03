//
//  ContentView.swift
//  InAppPurchases
//
//  Created by constantine kos on 03.01.2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: Store
    
    var body: some View {
        NavigationView {
            List(store.allrecipes, id: \.self) { i in
                Group {
                    if !i.isLocked {
                        NavigationLink(
                            destination: Text(i.title)) {
                            
                            RecipeRow(recipe: i) { }
                        }
                        
                    } else {
                        RecipeRow(recipe: i) {
                            if let product = store.product(for: i.id) {
                                store.purchaseProduct(product)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Store")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct RecipeRow: View {
    let recipe: Recipe
    let action: () -> Void
    
    var body: some View {
        HStack {
            ZStack {
                Image(recipe.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(9)
                    .opacity(recipe.isLocked ? 0.8 : 1)
                    .blur(radius: recipe.isLocked ? 3.0 : 0)
                    .padding()
                
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .opacity(recipe.isLocked ? 1 : 0)
                
            }
            
            VStack(alignment: .leading)  {
                Text(recipe.title)
                    .font(.title)
                
                Text(recipe.description)
                    .font(.caption)
            }
            
            Spacer()
            
            if let price = recipe.price, recipe.isLocked {
                Button(action: action, label: {
                    Text(price)
                        .foregroundColor(.white)
                        //.padding([.leading, .trailing])
                        .padding()
                        .background(Color.black)
                        .cornerRadius(25)
                })
            }
        }
    }
}

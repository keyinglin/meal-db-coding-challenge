//
//  ContentView.swift
//  recipesTheMealdb
//
//  Created by Keying Lin on 8/4/24.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel = DataViewModel()
    
    var body: some View {
        NavigationView{
            VStack {
                
                Text("Desserts")
                    .fontWeight(.bold)
                    .font(.title)
                
                if viewModel.isLoading {
                    ProgressView("Loading data...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = viewModel.error {
                    Text(error).foregroundColor(.red)
                } else if !viewModel.displayData.isEmpty {
                    List(viewModel.displayData) { item in
                        NavigationLink(destination: MealDetailedView(meal: item)) {
                            VStack(alignment: .leading) {
                                Text(item.mealName ?? "Unknown")
                            }
                        }
                    }
                } else {
                    Text("No data")
                }
            }
            .padding()
            .task {
                await viewModel.fetchData()
            }
        }
    }
}

#Preview {
    ContentView()
}

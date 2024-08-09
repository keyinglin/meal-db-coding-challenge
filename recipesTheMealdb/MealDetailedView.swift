//
//  MealDetailedView.swift
//  recipesTheMealdb
//
//  Created by Keying Lin on 8/4/24.
//

import SwiftUI

struct MealDetailedView: View {
    @StateObject private var viewModel = DataViewModel()
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let mealDetail = viewModel.mealDetail {
                    Text(mealDetail.strMeal ?? "Unknown")
                        .font(.title)
                        .padding()
                    
                    if let url = URL(string: mealDetail.strMealThumb ?? "image.png") {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .padding()
                    }
                    
                    // Ingredients Header
                    Text("Ingredients")
                        .font(.headline)
                        .padding(.leading, 15)
                        .padding(.bottom, 2)

                    // Ingredients List
                    
                    ForEach(Array(zip(mealDetail.strIngredients, mealDetail.strMeasures).enumerated()), id: \.offset) { index, element in
                        let (ingredient, measure) = element
                        HStack {
                            Text(ingredient)
                                .padding(.leading, 20)
                            Spacer()
                            Text(measure)
                                .padding(.trailing, 20)
                        }
                    }
                    
                    
                    // Instructions Header
                    Text("Instructions")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.leading, 15)
                        .padding(.bottom, 2)
                    
                    
                    // Instructions Detail
                    Text(mealDetail.strInstructions ?? "Unknown")
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        
                    
                    
                } else if viewModel.isLoading {
                    ProgressView("Loading details...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = viewModel.error {
                    Text(error).foregroundColor(.red)
                } else {
                    Text("No details available")
                }
                Spacer()
            }
            .navigationTitle(meal.mealName ?? "Meal Details")
            .padding()
            .task {
                await viewModel.fetchMealDetail(id: meal.id)
            }
        }
    }
}

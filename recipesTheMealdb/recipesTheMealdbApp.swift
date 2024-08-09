//
//  recipesTheMealdbApp.swift
//  recipesTheMealdb
//
//  Created by Keying Lin on 8/4/24.
//

import SwiftUI
import Foundation

struct Meal: Identifiable, Codable {
    let id: String
    let mealName: String?
    let mealThumb: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case mealName = "strMeal"
        case mealThumb = "strMealThumb"
    }
}

struct MealsResponse: Codable {
    let meals: [Meal]
}

struct MealDetail: Identifiable, Codable {
    let id: String
    let strMeal: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strIngredients: [String]
    let strMeasures: [String]

    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case strMeal
        case strInstructions
        case strMealThumb
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        strMeal = try container.decodeIfPresent(String.self, forKey: .strMeal)?.trimmingCharacters(in: .whitespaces) ?? "Default Meal Name"
        strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions)?.trimmingCharacters(in: .whitespaces) ?? "Default Instructions"
        strMealThumb = try container.decodeIfPresent(String.self, forKey: .strMealThumb)?.trimmingCharacters(in: .whitespaces) ?? "Default Meal Thumbnail"
        
        
        strIngredients = (1...20).compactMap { i in
            let key = CodingKeys(rawValue: "strIngredient\(i)")!
            return try? container.decodeIfPresent(String.self, forKey: key)?.trimmingCharacters(in: .whitespaces)
        }.filter { !$0.isEmpty }

        strMeasures = (1...20).compactMap { i in
            let key = CodingKeys(rawValue: "strMeasure\(i)")!
            return try? container.decodeIfPresent(String.self, forKey: key)?.trimmingCharacters(in: .whitespaces)
        }.filter { !$0.isEmpty }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(strMeal, forKey: .strMeal)
        try container.encode(strInstructions, forKey: .strInstructions)
        try container.encode(strMealThumb, forKey: .strMealThumb)

        for (index, ingredient) in strIngredients.enumerated() {
            let key = CodingKeys(rawValue: "strIngredient\(index + 1)")!
            try container.encode(ingredient, forKey: key)
        }
        
        for (index, measure) in strMeasures.enumerated() {
            let key = CodingKeys(rawValue: "strMeasure\(index + 1)")!
            try container.encode(measure, forKey: key)
        }
    }

}



struct MealDetailResponse: Codable {
    let meals: [MealDetail]
}

class DataViewModel: ObservableObject {
    @Published var displayData: [Meal] = []
    @Published var error: String?
    @Published var isLoading: Bool = false
    @Published var mealDetail: MealDetail?

    // Fetch data for the list view
    func fetchData() async {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            await MainActor.run {
                self.error = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        self.isLoading = true
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                await MainActor.run {
                    self.error = "Invalid response or no data"
                    self.isLoading = false
                }
                return
            }
            
            let decodedResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
            
            let filteredData = decodedResponse.meals.filter { meal in
                return !(meal.mealName?.isEmpty ?? true) && !(meal.mealThumb?.isEmpty ?? true)
            }
            let sortedData = filteredData.sorted { $0.mealName ?? "" < $1.mealName ?? "" }
            
            await MainActor.run {
                self.displayData = sortedData
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Fetch detailed information about a specific meal
    func fetchMealDetail(id: String) async {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            await MainActor.run {
                self.error = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        self.isLoading = true
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                await MainActor.run {
                    self.error = "Invalid response or no data"
                    self.isLoading = false
                }
                return
            }
            
            let decodedResponse = try JSONDecoder().decode(MealDetailResponse.self, from: data)
            guard let meal = decodedResponse.meals.first else {
                await MainActor.run {
                    self.error = "No meal details found"
                    self.isLoading = false
                }
                return
            }
            
            await MainActor.run {
                self.mealDetail = meal
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}


@main
struct recipesTheMealdbApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

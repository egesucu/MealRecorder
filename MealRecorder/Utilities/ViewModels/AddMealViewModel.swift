//
//  AddMealViewModel.swift
//  MealRecorder
//
//  Created by Ege Sucu on 11.02.2023.
//

import SwiftUI
import CoreData

class AddMealViewModel: ObservableObject {

    @Published var location = ""
    @Published var date: Date = .now
    @Published var selectedLocation: MapItem?
    @Published var meals: [String] = []
    @Published var customAlertText = ""
    @Published var activeSheet: ActiveSheets?
    @Published var mealType: MealType = .snack

    func updateLocation(location: MapItem) {
        self.selectedLocation = location
    }

    func saveMeal(model: MealListViewModel,
                  context: NSManagedObjectContext,
                  action: () -> Void) {
        model.addMeal(items: meals, date: date,
                     selectedLocation: selectedLocation,
                     context: context,
                     type: mealType)
            action()
    }

    func addMeal() {
        meals.append(customAlertText)
        customAlertText = ""
    }
}

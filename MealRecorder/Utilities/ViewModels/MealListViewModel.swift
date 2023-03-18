//
//  MealListViewModel.swift
//  MealRecorder
//
//  Created by Ege Sucu on 19.02.2023.
//

import SwiftUI
import CoreData

class MealListViewModel: ObservableObject {

    @Published var filteredMeals: [Meal] = []
    @Published var showAddMeal = false
    @Published var selection = Set<Meal>()
    @Published var isEditMode: EditMode = .inactive
    @Published var showMoreItems = false
    @Published var filter: MealFilter = .all

    func filterMeals(meals: FetchedResults<Meal>) {
        switch filter {
        case .all:
            filteredMeals = meals
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .thisWeek:
            filteredMeals = meals
                .filter({ DateUtility.thisWeek.contains(($0.date ?? .now)) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .thisMonth:
            filteredMeals = meals
                .filter({ DateUtility.thisMonth.contains(($0.date ?? .now)) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .today:
            filteredMeals = meals
                .filter({ DateUtility.todayMorning < ($0.date ?? .now) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        }
    }

    func addMeal(items: [String], date: Date,
                 selectedLocation: MapItem?,
                 context: NSManagedObjectContext,
                 type: MealType,
                 imageData: Data?) {
        let meal = Meal(context: context)
        meal.id = UUID()
        meal.items = items
        meal.date = date
        meal.mealType = type
        if let selectedLocation {
            let location = Location(context: context)
            location.name = selectedLocation.item.placemark.name
            location.latitude = selectedLocation.item.placemark.coordinate.latitude
            location.longitude = selectedLocation.item.placemark.coordinate.longitude
            meal.selectedLocation = location
        }
        if let imageData {
            meal.image = imageData
        }
        PersistenceController.save(context: context)
    }

}

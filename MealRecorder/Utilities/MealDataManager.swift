//
//  MealDataManager.swift
//  MealRecorder
//
//  Created by Ege Sucu on 5.01.2023.
//

import SwiftUI
import CoreData

struct MealDataManager {

    static let shared = MealDataManager()

    func filterMeals(meals: FetchedResults<Meal>, filter: MealFilter) -> [Meal] {

        switch filter {
        case .all:
            return meals
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .thisWeek:
            return meals
                .filter({ DateUtility.thisWeek.contains(($0.date ?? .now)) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .thisMonth:
            return meals
                .filter({ DateUtility.thisMonth.contains(($0.date ?? .now)) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .today:
            return meals
                .filter({ DateUtility.todayMorning < ($0.date ?? .now) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        }
    }

    func addMeal(items: [String], date: Date, selectedLocation: MapItem?,
                 context: NSManagedObjectContext, type: MealType) {
        let meal = Meal(context: context)
        (meal.id, meal.items, meal.date, meal.mealType) = (.init(), items, date, type)
        if let selectedLocation {
            let location = Location(context: context)
            let placemark = selectedLocation.item.placemark
            location.name = placemark.name
            location.latitude = placemark.coordinate.latitude
            location.longitude = placemark.coordinate.longitude
            meal.selectedLocation = location
        }
        PersistenceController.save(context: context)
    }

}

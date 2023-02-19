//
//  MealDataManager.swift
//  MealRecorder
//
//  Created by Ege Sucu on 5.01.2023.
//

import UIKit
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

    func deleteMeal(context: NSManagedObjectContext, meals: [Meal], at offsets: IndexSet) {
        for offset in offsets {
            context.delete(meals[offset])
            PersistenceController.save(context: context)
        }
    }

    func addMeal(items: [String], date: Date, selectedLocation: MapItem?, location: String, selectedImageData: Data?, context: NSManagedObjectContext) {
        let meal = Meal(context: context)
        meal.id = UUID()
        meal.items = items
        meal.date = date
        if let selectedLocation {
            let location = Location(context: context)
            location.name = selectedLocation.item.placemark.name ?? ""
            location.latitude = selectedLocation.item.placemark.coordinate.latitude
            location.longitude = selectedLocation.item.placemark.coordinate.longitude
            meal.selectedLocation = location

        } else if !location.isEmpty {
            meal.location = location
        }
        if let selectedImageData {
            meal.image = selectedImageData
        }
        PersistenceController.save(context: context)
    }

}

//
//  Persistence.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let meals = Meal.createMockup(context: viewContext)

        save(context: viewContext)
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MealRecorder")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    static func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension Meal {
    static func createMockup(context: NSManagedObjectContext) -> [Meal] {
        var meals: [Meal] = []
        (1...5).forEach { _ in
            let randomInterval = Int.random(in: 1...500)
            let meal = Meal.createMeal(context: context, date: .now.addingTimeInterval(CGFloat(randomInterval)))
            meals.append(meal)
        }
        return meals
    }

    static func createMeal(context: NSManagedObjectContext, date: Date = .now) -> Meal {
        let meal = Meal(context: context)
        meal.id = UUID()
        meal.mealType = [MealType.morning, MealType.lunch, MealType.snack, MealType.evening].randomElement() ?? .morning
        meal.items = ["Cake", "Burger"]
        meal.image = UIImage(imageLiteralResourceName: "no-meal-photo").jpegData(compressionQuality: 0.8)
        meal.date = date
        let demoLocation = Location(context: context)
        demoLocation.name = "Coffee House"
        let randomLatitude = Double.random(in: 41.02...41.032464900467325)
        let randomLongitude = Double.random(in: 28.95...28.964352429812604)
        (demoLocation.latitude, demoLocation.longitude) = (randomLatitude, randomLongitude)
        meal.selectedLocation = demoLocation
        return meal
    }
}

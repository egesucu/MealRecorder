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

        (1...5).forEach { _ in
            var meal = Meal(context: viewContext)
            PersistenceController.createMockup(meal: &meal)
            meal.date = Date.now
        }
        (1...5).forEach { _ in
            var meal = Meal(context: viewContext)
            PersistenceController.createMockup(meal: &meal)
            meal.date = Date().addingTimeInterval(24*60*6)
        }

        save(context: viewContext)
        return result
    }()

    static func createMockup(meal: inout Meal) {
        meal.id = UUID()
        meal.items = ["Cake", "Burger"]
        meal.date = .now
        let demoLocation = Location(context: PersistenceController.preview.container.viewContext)
        demoLocation.name = "Coffee House"
        (demoLocation.latitude, demoLocation.longitude) = (41.032464900467325, 28.964352429812604)
        meal.selectedLocation = demoLocation
    }

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

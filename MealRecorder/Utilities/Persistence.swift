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
        for _ in 0..<5 {
            let meal = Meal(context: viewContext)
            meal.id = UUID()
            meal.items = ["Cake", "Burger"]
            meal.date = Date.now
            meal.image = UIImage(named: "no-meal-photo")?.jpegData(compressionQuality: 0.8)
            let demoLocation = Location(context: viewContext)
            demoLocation.name = "Starbucks"
            demoLocation.latitude = 41.032464900467325
            demoLocation.longitude = 28.964352429812604
            meal.selectedLocation = demoLocation
        }
        for _ in 0..<5 {
            let meal = Meal(context: viewContext)
            meal.id = UUID()
            meal.items = ["Cake", "Burger"]
            meal.image = UIImage(named: "no-meal-photo")?.jpegData(compressionQuality: 0.8)
            let demoLocation = Location(context: viewContext)
            demoLocation.name = "Starbucks"
            demoLocation.latitude = 41.032464900467325
            demoLocation.longitude = 28.964352429812604
            meal.selectedLocation = demoLocation
            meal.date = Date().addingTimeInterval(24*60*6)
        }

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

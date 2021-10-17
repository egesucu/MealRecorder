//
//  Persistence.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<5 {
            let demoMeal = Meal(context: viewContext)
            demoMeal.id = UUID()
            demoMeal.location = "AVM"
            demoMeal.name = "Cake"
            demoMeal.date = Date()
        }
        for _ in 0..<5 {
            let demoMeal = Meal(context: viewContext)
            demoMeal.id = UUID()
            demoMeal.location = "Ev"
            demoMeal.name = "Pasta"
            demoMeal.date = Date().addingTimeInterval(24*60*6)
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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    static func save(context: NSManagedObjectContext){
        do{
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

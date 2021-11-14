//
//  ActivityManager.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import SwiftUI
import HealthKit
import CoreData

class ActivityManager : ObservableObject{
    
    @Published var items: [DashItem] = []
    var steps = "No Steps"
    var waterAmount = "0 ml"
    var exerciseMinutes = "0 minute"
    var calorieAmount = "0 kcal"
    var mealDetail = "N/A"
    let healthStore = HKHealthStore()
    
    final let waterType = HKQuantityType(HKQuantityTypeIdentifier.dietaryWater)
    final let stepsType = HKQuantityType(HKQuantityTypeIdentifier.stepCount)
    final let caloriesType = HKQuantityType(HKQuantityTypeIdentifier.activeEnergyBurned)
    final let exerciseType = HKQuantityType(HKQuantityTypeIdentifier.appleExerciseTime)
    var canAccessHealthStore = false
    let components : DateComponents = {
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        return components
    }()
    let midnight = Calendar.current.startOfDay(for: .now) // 12:00 AM of today.
    
    init(){
        accessHealthData()
#if targetEnvironment(simulator)
        exerciseMinutes = "30 minutes"
        waterAmount = "2.200 ml"
        steps = "12.934 steps"
        mealDetail = "5 meals"
        calorieAmount = "859 kcal"
#endif
        loadData()
        reloadItems()
    }
    
    func loadData(){
        accessHealthData()
        if canAccessHealthStore{
            self.collectWater()
            self.collectSteps()
            self.collectCalories()
            self.collectExerciseMinutes()
        } else {
            print("Can't reach health data")
        }
    }
    
    func reloadItems(){
        items.removeAll()
        items = [DashItem(title: "Exercise", detail: exerciseMinutes, type: .exercise, color: .green),
                 DashItem(title: "Water", detail: waterAmount, type: .water, color: .blue),
                 DashItem(title: "Steps", detail: steps, type: .steps, color: .orange),
                 DashItem(title: "Meal", detail: mealDetail, type: .meals, color: .yellow),
                 DashItem(title: "Calories", detail: calorieAmount, type: .calorie, color: .red)]
    }
    
    func getMealCount(from results: FetchedResults<Meal>) {
        switch results.count{
        case 0:
            mealDetail = "No meal."
            break
        case 1:
            mealDetail = "1 meal"
            break
        case let x where x > 1:
            mealDetail = "\(x) meals"
            break
        default:
            mealDetail = "N/A"
            break
        }
    }
    
    func fetchData(meals: FetchedResults<Meal>?){
        if let meals = meals {
            getMealCount(from: meals)
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func collectWater(){
        let predicate = HKQuery.predicateForSamples(withStart: midnight, end: nil, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
            } else {
                guard let statistics = statistics else { return }
                
                let amount = statistics.sumQuantity()
                DispatchQueue.main.async {
                    self.waterAmount = (String(describing: amount))
                }
            }
        }
        self.healthStore.execute(query)
    }
    
    func collectSteps(){
        let predicate = HKQuery.predicateForSamples(withStart: midnight, end: nil, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                if let amount = amount {
                    DispatchQueue.main.async {
                        let intAmount = Int(amount.doubleValue(for: .count()))
                        self.steps = String(localized: "\(intAmount) steps")
                    }
                }
            }
        }
        self.healthStore.execute(query)
    }
    
    func collectCalories(){
        let predicate = HKQuery.predicateForSamples(withStart: midnight, end: nil, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                if let amount = amount {
                    DispatchQueue.main.async {
                        let intAmount = Int(amount.doubleValue(for: .count()))
                        self.steps = String(localized: "\(intAmount) steps")
                    }
                }
            }
        }
        self.healthStore.execute(query)
    }
    
    func collectExerciseMinutes(){
        let predicate = HKQuery.predicateForSamples(withStart: midnight, end: nil, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                if let amount = amount {
                    DispatchQueue.main.async {
                        self.steps = "\(amount)"
                    }
                }
            }
        }
        self.healthStore.execute(query)
    }
    
    func saveWater(amount: Double){
        if couldSaveWater(){
            let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amount)
            let now = Date.now
            let sample = HKQuantitySample(type: waterType, quantity: quantity, start: now, end: now)
            
            healthStore.save(sample) { success, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.fetchData(meals: nil)
                }
            }
        } else {
            
        }
    }
    
    func couldSaveWater() -> Bool {
        return healthStore
            .authorizationStatus(for: HKQuantityType(HKQuantityTypeIdentifier.dietaryWater)) == .sharingAuthorized
    }
    
    func accessHealthData(){
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType,stepsType,caloriesType,exerciseType]) { _, error in
            if let error = error {
                self.canAccessHealthStore = false
                print(error.localizedDescription)
            } else{
                self.canAccessHealthStore = true
            }
        }
    }
    
    func saveMeal(context: NSManagedObjectContext) {
        PersistenceController.save(context: context)
    }
    func deleteMeal(meal: Meal, at context: NSManagedObjectContext){
        context.delete(meal)
        saveMeal(context: context)
    }
}

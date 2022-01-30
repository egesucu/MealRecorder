//
//  HealthStore.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import SwiftUI
import HealthKit
import CoreData

class HealthStore : ObservableObject{
    
    @Published var items: [DashItem] = []
    var healthStore : HKHealthStore?
    var query: HKStatisticsQuery?
    var meals : FetchedResults<Meal>?
    
    @Published var waterValue : HKQuantity?
    @Published var stepsValue : HKQuantity?
    @Published var caloriesValue : HKQuantity?
    @Published var exerciseValue : HKQuantity?
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.startOfDay(for: .now).addingTimeInterval(86_400)
    
    init(){
        if HKHealthStore.isHealthDataAvailable(){
            healthStore = HKHealthStore()
        }
    }
    
    func setupStore() {
        let typesToRead : Set = [
            HKQuantityType(.dietaryWater),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.stepCount)
        ]
        let typesToShare : Set = [
            HKQuantityType(.dietaryWater)
        ]
        healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: { success, error in
            if let error = error {
                print(error)
            } else if success {
                self.collectWater {
                    self.waterValue = $0
                    self.reloadItems()
                }
                self.collectSteps{
                    self.stepsValue = $0
                    self.reloadItems()
                }
                self.collectCalories{
                    self.caloriesValue = $0
                    self.reloadItems()
                }
                self.collectExerciseMinutes{
                    self.exerciseValue = $0
                    self.reloadItems()
                }
                
            }
        })
    }
    
    func loadData(){
        setupStore()
    }
    
    func reloadItems(){
        DispatchQueue.main.async {
            self.items.removeAll()
            if let exerciseValue = self.exerciseValue {
                let result = exerciseValue.doubleValue(for: .minute()).formatted(.number.precision(.fractionLength(0))) + " minutes"
                self.items.append(DashItem(title: "Exercise", detail: result, type: .exercise, color: .green))
            } else {
                self.items.append(DashItem(title: "Exercise", detail: "N/A", type: .exercise, color: .green))
            }
            if let waterValue = self.waterValue {
                let result = waterValue.doubleValue(for: .literUnit(with: .milli)).formatted(.number.precision(.fractionLength(0))) + " ml"
                self.items.append(DashItem(title: "Water", detail: result, type: .water, color: .blue))
            } else {
                self.items.append(DashItem(title: "Water", detail: "0 ml",type: .water,color: .blue))
            }
            if let stepsValue = self.stepsValue {
                let result = stepsValue.doubleValue(for: .count()).formatted(.number.precision(.fractionLength(0)))
                self.items.append(DashItem(title: "Steps", detail: result, type: .steps, color: .orange))
            } else {
                self.items.append(DashItem(title: "Steps", detail: "N/A", type: .steps, color: .orange))
            }
            if let caloriesValue = self.caloriesValue {
                let result = caloriesValue.doubleValue(for: .kilocalorie()).formatted(.number.precision(.fractionLength(0))) + " kcal"
                self.items.append(DashItem(title: "Calories", detail: result, type: .calorie, color: .red))
            } else {
                self.items.append(DashItem(title: "Calories", detail: "N/A", type: .calorie, color: .red))
            }
            self.items.append(DashItem(title: "Meal", detail: self.getMealCount(from: self.meals), type: .meals, color: .yellow))
        }
    }
    
    func getMealCount(from results: FetchedResults<Meal>?) -> String{
        if let results = results {
            switch results.count{
            case 0:
                return "No meal."
            case 1:
                return "1 meal"
            case let x where x > 1:
                return "\(x) meals"
            default:
                return "N/A"
            }
        } else {
            return "N/A"
        }
    }
    
    func collectWater(completion: @escaping (HKQuantity?) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: HKQuantityType(.dietaryWater), quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
                print("Water Error")
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                DispatchQueue.main.async {
                    completion(amount)
                }
            }
        }
        self.healthStore?.execute(query)
    }
    
    func collectSteps(completion: @escaping (HKQuantity?) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: HKQuantityType(.stepCount), quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
                print("Steps Error")
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                DispatchQueue.main.async {
                    completion(amount)
                }
            }
        }
        self.healthStore?.execute(query)
    }
    
    func collectCalories(completion: @escaping (HKQuantity?) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: HKQuantityType(.activeEnergyBurned), quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
                print("Calories Error")
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                DispatchQueue.main.async {
                    completion(amount)
                }
            }
        }
        self.healthStore?.execute(query)
    }
    
    func collectExerciseMinutes(completion: @escaping (HKQuantity?) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow, options: [.strictStartDate])
        let query = HKStatisticsQuery(quantityType: HKQuantityType(.appleExerciseTime), quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, statistics, error in
            if let error = error {
                print(error)
                print("Exercise Error")
            } else {
                guard let statistics = statistics else { return }
                let amount = statistics.sumQuantity()
                DispatchQueue.main.async {
                    completion(amount)
                }
            }
        }
        self.healthStore?.execute(query)
    }
    
    func saveWater(amount: Double){
        if couldSaveWater(){
            let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amount)
            let now = Date.now
            let sample = HKQuantitySample(type: HKQuantityType(.dietaryWater), quantity: quantity, start: now, end: now)
            healthStore?.save(sample) { success, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.reloadItems()
                }
            }
        } else {}
    }
    
    func couldSaveWater() -> Bool {
        return healthStore?
            .authorizationStatus(for: HKQuantityType(HKQuantityTypeIdentifier.dietaryWater)) == .sharingAuthorized
    }
    
    func saveMeal(context: NSManagedObjectContext) {
        PersistenceController.save(context: context)
    }
    func deleteMeal(meal: Meal, at context: NSManagedObjectContext){
        context.delete(meal)
        saveMeal(context: context)
    }
}

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
    final let activityType = HKQuantityType(HKQuantityTypeIdentifier.appleExerciseTime)
    var canAccessHealthStore = false
    
    init(){
#if DEBUG
        exerciseMinutes = "30 minutes"
        waterAmount = "2.200 ml"
        steps = "12.934"
        mealDetail = "5 meals"
        calorieAmount = "859 kcal"
#endif
        reloadItems()
        accessHealthData()
        if canAccessHealthStore{
            fetchData(meals: nil)
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
    
    func getMealCount(meals: FetchedResults<Meal>){
        switch meals.count{
        case 0:
            mealDetail = "No meal recorded."
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
            getMealCount(meals: meals)
        }
        getWaterAmount()
        getExerciseData()
        getCalorieData()
        getSteps()
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func getWaterAmount(){
        self.waterAmount = collectTodaysData(quantityType: waterType)
    }
    
    func getExerciseData(){
        self.exerciseMinutes = collectTodaysData(quantityType: activityType)
    }
    
    func getCalorieData(){
        self.calorieAmount = collectTodaysData(quantityType: caloriesType)
    }
    func getSteps(){
        self.steps = collectTodaysData(quantityType: stepsType)
    }
    
    func collectTodaysData(quantityType: HKQuantityType) -> String{
        
        var collectedAmount = ""
        
        if canAccessHealthStore{
            let begin = Calendar.current.startOfDay(for: Date.now)
            let predicate = HKQuery.predicateForSamples(withStart: begin, end: nil, options: [.strictStartDate])
            
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { _, statistics, error in
                if let error = error{
                    print(error.localizedDescription)
                } else if let stats = statistics {
                    let amount = stats.sumQuantity()
                    if let amount = amount {
                        var value = 0.0
                        switch quantityType {
                        case self.waterType: value = amount.doubleValue(for: .literUnit(with: .milli))
                        case self.stepsType: value = amount.doubleValue(for: .count())
                        case self.caloriesType: value = amount.doubleValue(for: .kilocalorie())
                        case self.activityType: value = amount.doubleValue(for: .minute())
                        default:
                            break
                        }
                        collectedAmount = "\(Int(value))"
                    }
                }
            }
            healthStore.execute(query)
        } else {
            accessHealthData()
            if !canAccessHealthStore{
                print("Your data can't be loaded because of permission.")
            }
        }
        return collectedAmount
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
    
    func couldAccessHealthStore() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func accessHealthData(){
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType,stepsType,caloriesType,activityType]) { _, error in
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

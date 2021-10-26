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
    
    init(){
#if targetEnvironment(simulator)
        exerciseMinutes = "30 minutes"
        waterAmount = "2.200 ml"
        steps = "12.934"
        mealDetail = "5 meals"
        calorieAmount = "859 kcal"
#endif
        reloadItems()
        accessHealthData()
        if canAccessHealthStore{
            fetchData()
        }

    }
    
    func fetchData(){
            getWaterAmount()
            getExerciseData()
            getCalorieData()
            getSteps()
    }
//    FIXME: Won't load on initial load, loads after 
    
    func reloadItems(){
        items.removeAll()
        items = [DashItem(title: "Exercise", detail: "\(String(describing: exerciseMinutes))", type: .exercise, color: .green),
                 DashItem(title: "Water", detail: "\(String(describing: waterAmount))", type: .water, color: .blue),
                 DashItem(title: "Steps", detail: "\(String(describing: steps).replacingOccurrences(of: "count", with: ""))", type: .steps, color: .orange),
                 DashItem(title: "Meal", detail: mealDetail, type: .meals, color: .yellow),
                 DashItem(title: "Calories", detail: "\(String(describing: calorieAmount))", type: .calorie, color: .red)]
        
    }
    

    func getMealCount(meals: FetchedResults<Meal>){
        switch meals.count{

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
        self.steps = collectTodaysData(quantityType: stepsType
    
    func getWaterAmount(){
        collectTodaysData(quantityType: waterType)
    }
    
    func getExerciseData(){
        collectTodaysData(quantityType: exerciseType)
    }
    
    func getCalorieData(){
        collectTodaysData(quantityType: caloriesType)
    }
    func getSteps(){
        collectTodaysData(quantityType: stepsType)

    }
    
    func collectTodaysData(quantityType: HKQuantityType){
        
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        

        if canAccessHealthStore{
            let begin = Calendar.current.startOfDay(for: Date.now)
            let predicate = HKQuery.predicateForSamples(withStart: begin, end: nil, options: [.strictStartDate])
            
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { _, statistics, error in

        guard let startDate = calendar.date(from: components) else {
            return
        }
        
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            return
        }
        
        let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        if canAccessHealthStore {
            
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: today, options: .cumulativeSum) { _, statistics, error in
                if let error = error{
                    print(error.localizedDescription)
                } else if let stats = statistics {
                    let amount = stats.sumQuantity()
                    if let amount = amount {
                        switch quantityType {
                        case self.waterType:
                            DispatchQueue.main.async {
                                self.waterAmount = amount
                            }
                        case self.stepsType:
                            DispatchQueue.main.async {
                                self.steps = amount
                            }
                        case self.caloriesType:
                            DispatchQueue.main.async {
                                self.calorieAmount = amount
                            }
                        case self.exerciseType:
                            DispatchQueue.main.async {
                                self.exerciseMinutes = amount
                            }
                        default:
                            break
                        }
                        print("amount:",amount)
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
        
        self.reloadItems()
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

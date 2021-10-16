//
//  ActivityManager.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import Foundation
import HealthKit

class ActivityManager : ObservableObject{
    
    @Published var steps = "No Steps"
    @Published var waterAmount = "No Water taken."
    @Published var exerciseMinutes = "No exercise recorded yet."
    @Published var calorieAmount = "No calories has burned."
    let healthStore = HKHealthStore()
    
    final let waterType = HKQuantityType(HKQuantityTypeIdentifier.dietaryWater)
    final let stepsType = HKQuantityType(HKQuantityTypeIdentifier.stepCount)
    final let caloriesType = HKQuantityType(HKQuantityTypeIdentifier.activeEnergyBurned)
    final let activityType = HKQuantityType(HKQuantityTypeIdentifier.appleExerciseTime)
    var canAccessHealthStore = false
    
    static let shared = ActivityManager()
    
    init(){
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
            let calendar = NSCalendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day], from: now)

            guard let startDate = calendar.date(from: components) else {
                fatalError("*** Unable to create the start date ***")
            }
             
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
                fatalError("*** Unable to create the end date ***")
            }
            
            let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: today, options: []) { _, statistics, error in
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
                    self.fetchData()
                }
            }
        } else {
            //We can't save water.
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
}

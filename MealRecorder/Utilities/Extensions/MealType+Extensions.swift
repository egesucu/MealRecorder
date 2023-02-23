//
//  MealType+Extensions.swift
//  MealRecorder
//
//  Created by Ege Sucu on 19.02.2023.
//

import Foundation

enum MealType: Int, CaseIterable {
    case morning, lunch, snack, evening
}

extension Meal {

    var mealType: MealType {
        get {
            return MealType(rawValue: Int(type)) ?? .snack
        }
        set {
            type = Int64(newValue.rawValue)
        }
    }
}

extension MealType {
    func text() -> String {
        switch self {
        case .morning:
            return "Morning"
        case .evening:
            return "Evening"
        case .snack:
            return "Snack"
        case .lunch:
            return "Lunch"
        }

    }
}

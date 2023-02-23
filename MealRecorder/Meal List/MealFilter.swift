//
//  MealFilter.swift
//  MealRecorder
//
//  Created by Ege Sucu on 19.02.2023.
//

import Foundation

enum MealFilter: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case thisWeek = "Weekly"
    case thisMonth = "Monthly"
}

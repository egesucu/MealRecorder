//
//  DateUtility.swift
//  MealRecorder
//
//  Created by Ege Sucu on 8.10.2022.
//

import Foundation

struct DateUtility {

    static let todayMorning = Calendar.current.startOfDay(for: .now)
    static let tomorrowMorning = Calendar.current.date(byAdding: .day, value: 1, to: todayMorning) ?? .now
    static let thisWeek = (Calendar.current
        .date(byAdding: .weekday, value: -1, to: todayMorning) ?? Date.now)...Date.now
    static let thisMonth = (Calendar.current.date(byAdding: .month, value: -1, to: todayMorning) ?? .now)...Date.now

}

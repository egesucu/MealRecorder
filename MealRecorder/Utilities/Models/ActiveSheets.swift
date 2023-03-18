//
//  ActiveSheets.swift
//  MealRecorder
//
//  Created by Ege Sucu on 23.02.2023.
//

import Foundation

enum ActiveSheets: Identifiable {
    case location
    case camera

    var id: Int {
        hashValue
    }
}

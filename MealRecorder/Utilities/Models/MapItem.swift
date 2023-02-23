//
//  MapItem.swift
//  MealRecorder
//
//  Created by Ege Sucu on 23.02.2023.
//

import MapKit

struct MapItem: Identifiable, Hashable {
    let id = UUID().uuidString
    let item: MKMapItem
}

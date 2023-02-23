//
//  MealItemListView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 6.01.2023.
//

import SwiftUI

struct MealItemListView: View {

    @Binding var meals: [String]

    var body: some View {
        List {
            ForEach(meals, id: \.self) { item in
                Text(item)
                    .lineLimit(2)
                    .minimumScaleFactor(0.4)
            }
            .onDelete(perform: deleteMeal)
        }
    }

    func deleteMeal(at offsets: IndexSet) {
        meals.remove(atOffsets: offsets)
    }
}

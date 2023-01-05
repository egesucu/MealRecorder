//
//  LocationView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 6.01.2023.
//

import SwiftUI

struct LocationView: View {
    @Binding var shouldShowLocationSheet: Bool
    @Binding var location: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Button {
                shouldShowLocationSheet.toggle()
            } label: {
                Image(systemName: "mappin.circle.fill")
            }
            TextField("Meal Location",text: $location, prompt: Text("Meal Location"))
        }
        DatePicker("Date", selection: $date)
    }
}

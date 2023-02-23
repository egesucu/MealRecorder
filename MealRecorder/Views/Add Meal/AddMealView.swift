//
//  AddMealView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI
import AlertKit
import PhotosUI

struct AddMealView: View {

    @StateObject var addMealViewModel = AddMealViewModel()
    @StateObject var customAlertManager = CustomAlertManager()
    @ObservedObject var mealViewModel: MealListViewModel

    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context

    var body: some View {
        NavigationStack {
            Form {
                Picker("Meal Type", selection: $addMealViewModel.mealType) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.text())
                            .tag(type)
                    }
                }
                if !addMealViewModel.meals.isEmpty {
                    Section {
                        MealItemListView(meals: $addMealViewModel.meals)
                    } header: {
                        Text("Meals")
                    }
                }
                Section {
                    Button {
                        customAlertManager.show()
                    } label: {
                        Label("Add Meal", systemImage: customAlertManager.isPresented ?
                              "fork.knife.circle.fill" : "fork.knife.circle")
                    }
                }
                Section {
                    HStack {
                        Text("Meal Location")
                        Button {
                            addMealViewModel.activeSheet = .location
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                        }
                        if let location = addMealViewModel.selectedLocation,
                           let name = location.item.name {
                            Text(name)
                        } else {
                            Spacer()
                        }
                    }
                    DatePicker("Date", selection: $addMealViewModel.date)
                } header: {
                    Text("Details")
                }
            }
            .navigationTitle(Text("Add Meal"))
            .toolbar(content: bottomToolbar)
        }
        .sheet(item: $addMealViewModel.activeSheet, content: { item in
            if item == .location {
                SearchLocationView(addMealViewModel: addMealViewModel)
            }
        })
        .customAlert(manager: customAlertManager, content: alertContent, buttons: alertButtons())
    }

    @ToolbarContentBuilder
    func bottomToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .bold()
                    .foregroundColor(Color(uiColor: .systemRed))
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: saveMeal) {
                Text("Add")
                    .bold()
                    .foregroundColor(addMealViewModel.meals.isEmpty ? .gray : Color(uiColor: .systemGreen))
            }
            .disabled(addMealViewModel.meals.isEmpty)
        }
    }
    func alertContent() -> some View {
        VStack {
            Text("What did you eat?")
                .bold()
            TextField("Burger", text: $addMealViewModel.customAlertText)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled(true)
        }
    }
    func alertButtons() -> [CustomAlertButton] {
        [.cancel(content: {
            Text("Cancel")
        }),
        .regular(content: {
            Text("Add")
        }, action: addMealViewModel.addMeal)
        ]
    }

}

extension AddMealView {
    func saveMeal() {
        addMealViewModel.saveMeal(model: mealViewModel, context: context) {
            dismiss()
        }
    }
}

struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddMealView(mealViewModel: MealListViewModel())
        }
    }
}

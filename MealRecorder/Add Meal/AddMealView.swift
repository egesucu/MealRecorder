//
//  AddMealView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI
import AlertKit
import PhotosUI

enum CameraSourceType: Hashable {
    case camera, library
}

enum ActiveSheets: Identifiable {
    case photo, location

    var id: Int {
        hashValue
    }
}

struct AddMealView: View {

    @StateObject var addMealViewModel = AddMealViewModel()
    @StateObject var customAlertManager = CustomAlertManager()

    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context

    var mealDataManager: MealDataManager

    var body: some View {

        NavigationStack {
            Form {
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
                        Button {
                            addMealViewModel.activeSheet = .location
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                        }
                        TextField("Meal Location", text: $addMealViewModel.location, prompt: Text("Meal Location"))
                    }
                    DatePicker("Date", selection: $addMealViewModel.date)
                } header: {
                    Text("Details")
                }

                Section {
                    Button {
                        addMealViewModel.activeSheet = .photo
                    } label: {
                        Text("Add a photo")
                    }
                }

                Section {
                    PhotosPicker(selection: $addMealViewModel.selectedImage,
                                 matching: .images, photoLibrary: .shared()) {
                        Text("Select an image")
                    }
                }

                if let selectedImageData = addMealViewModel.selectedImageData,
                let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(.all)
                }
            }
            .navigationTitle(Text("Add Meal"))
            .toolbar {
                bottomToolbar()
            }
        }
        .onChange(of: addMealViewModel.selectedImage) { image in
            Task {
                if let data = try? await image?.loadTransferable(type: Data.self) {
                    addMealViewModel.selectedImageData = data
                }
            }
        }
        .sheet(item: $addMealViewModel.activeSheet, content: { item in
            switch item {
            case .location:
                SearchLocationView(addMealViewModel: addMealViewModel)
            case .photo:
                ImagePickerView(selectedImageData: $addMealViewModel.selectedImageData)
                    .ignoresSafeArea()
            }
        })
        .customAlert(manager: customAlertManager, content: {
            VStack {
                Text("What did you eat?")
                    .bold()
                TextField("Burger", text: $addMealViewModel.customAlertText)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
            }
        }, buttons: [
            .regular(content: {
                Text("Cancel")
                    .bold()
            }, action: {

            }),
            .regular(content: {
                Text("Add")
            }, action: {
                addMealViewModel.meals.append(addMealViewModel.customAlertText)
                addMealViewModel.customAlertText = ""
            })
        ])

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
            Button {
                self.saveMeal()
            } label: {
                Text("Add")
                    .bold()
                    .foregroundColor(addMealViewModel.meals.isEmpty ? .gray : Color(uiColor: .systemGreen))
            }
            .disabled(addMealViewModel.meals.isEmpty)
        }
    }

}

extension AddMealView {
    func saveMeal() {
        mealDataManager
            .addMeal(items: addMealViewModel.meals, date: addMealViewModel.date,
                     selectedLocation: addMealViewModel.selectedLocation,
                     selectedImageData: addMealViewModel.selectedImageData,
                     context: context)
            dismiss()
    }
}

struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddMealView(mealDataManager: .shared)
        }
    }
}

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
                    DatePicker("Date", selection: $addMealViewModel.date)
                    Toggle("Add Image?", isOn: $addMealViewModel.shouldAddImage)

                    if addMealViewModel.shouldAddImage {
                        Picker("Source Type", selection: $addMealViewModel.imageSourceType) {
                            Text("Library")
                                .tag(ImagesourceType.library)
                            Text("Camera")
                                .tag(ImagesourceType.camera)
                        }
                        .pickerStyle(.segmented)

                        switch addMealViewModel.imageSourceType {
                        case .library:
                            PhotosPicker("Select Image", selection: $addMealViewModel.photosPickerItem, matching: .images, photoLibrary: .shared())
                                .onChange(of: addMealViewModel.photosPickerItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            addMealViewModel.selectedImageData = data
                                            if let uiImage = UIImage(data: data) {
                                                addMealViewModel.selectedImage = Image(uiImage: uiImage)
                                            }
                                        }
                                    }
                                }
                        case .camera:
                            Button {
                                addMealViewModel.activeSheet = .camera
                            } label: {
                                Text("Take a photo")
                            }
                        }

                        if let photo = addMealViewModel.imageFromPhoto {
                            photo
                                .resizable()
                                .scaledToFit()
                        } else if let image = addMealViewModel.selectedImage {
                            image
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    Toggle("Add Location?", isOn: $addMealViewModel.shouldAddLocation)

                    if addMealViewModel.shouldAddLocation {
                        if let location = addMealViewModel.selectedLocation,
                           let name = location.item.name {
                            HStack {
                                Text("Location")
                                    .bold()
                                Spacer()
                                Text(name)
                            }
                        }
                    }
                } header: {
                    Text("Details")
                }
                if addMealViewModel.shouldAddLocation {
                    HStack {
                        Spacer()
                        Button {
                            addMealViewModel.activeSheet = .location
                        } label: {
                            Label("Add Location", systemImage: "mappin.circle.fill")
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(Text("Add Meal"))
            .toolbar(content: bottomToolbar)
        }
        .sheet(item: $addMealViewModel.activeSheet, content: { item in
            switch item {
            case .location:
                SearchLocationView(addMealViewModel: addMealViewModel)
            case .camera:
                CameraView(imageFromPhoto: $addMealViewModel.imageFromPhoto,
                           takenPhotoData: $addMealViewModel.takenPhotoData,
                           errorText: $addMealViewModel.errorText)
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

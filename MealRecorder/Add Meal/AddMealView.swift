//
//  AddMealView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI
import AlertKit
import PhotosUI

enum CameraSourceType: Hashable{
    case camera,library
}

struct AddMealView: View {
    
    @State private var location = ""
    @State private var date = Date()
    @State private var photoNeed = false
    @State private var shouldShowCamera = false
    @State private var sourceSelection : CameraSourceType = .camera
    @State private var selectedPhoto : UIImage?
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data? = nil
    @State private var selectedLocation: MapItem? = .init(item: .init())
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @StateObject var customAlertManager = CustomAlertManager()
    @State private var meals: [String] = []
    @State private var customAlertText: String = ""
    @State private var shouldShowLocationSheet = false
    
    var mealDataManager: MealDataManager

    var body: some View{
        
        NavigationView {
            Form{
                if !meals.isEmpty{
                    Section {
                        MealItemListView(meals: $meals)
                    } header: {
                        Text("Meals")
                    }
                }
                
                Section {
                    Button {
                        customAlertManager.show()
                    } label: {
                        Label("Add Meal", systemImage: customAlertManager.isPresented ? "fork.knife.circle.fill" : "fork.knife.circle")
                    }

                }
                Section {
                    LocationView(shouldShowLocationSheet: $shouldShowLocationSheet, location: $location, date: $date)
                } header: {
                    Text("Details")
                }
                Section {
                    SourceSelectionView(photoNeed: $photoNeed,
                                        sourceSelection: $sourceSelection,
                                        selectedImageData: $selectedImageData,
                                        selectedImage: $selectedImage,
                                        selectedPhoto: $selectedPhoto,
                                        shouldShowCamera: $shouldShowCamera)
                } header: {
                    Text("Photo")
                }
            }
            .onChange(of: selectedImage) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .sheet(isPresented: $shouldShowLocationSheet, onDismiss: {
                if let selectedLocation{
                    location = selectedLocation.item.placemark.name ?? ""
                }
            }, content: {
                SearchLocationView(selectedLocation: $selectedLocation)
            })
            .sheet(isPresented: self.$shouldShowCamera) {
                ImagePickerView(selectedImage: $selectedPhoto, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .customAlert(manager: customAlertManager, content: {
                VStack {
                    Text("What did you eat?")
                        .bold()
                    TextField("Burger", text: $customAlertText)
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
                    meals.append(customAlertText)
                    customAlertText = ""
                })
            ])
            .toolbar(content: {
                
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button{
                            presentationMode.wrappedValue.dismiss()
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
                                .foregroundColor(meals.isEmpty ? .gray : Color(uiColor: .systemGreen))
                        }
                        .disabled(meals.isEmpty)
                    }
            })
        .navigationTitle(Text("Add Meal"))
        }
    }
}

extension AddMealView{
    func saveMeal(){
        mealDataManager
            .addMeal(items: meals, date: date,
                     selectedLocation: selectedLocation,
                     location: location,
                     selectedImageData: selectedImageData,
                     selectedPhoto: selectedPhoto,
                     context: context)
        presentationMode.wrappedValue.dismiss()
    }
}


struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
        AddMealView(mealDataManager: .shared)
    }
}

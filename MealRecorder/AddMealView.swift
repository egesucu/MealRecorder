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
    


    
    var body: some View{
        
        NavigationView {
            Form{
                if !meals.isEmpty{
                    Section {
                        List {
                            ForEach(meals, id: \.self) { item in
                                Text(item)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.4)
                            }.onDelete(perform: deleteMeal)
                        }
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
                    HStack {
                        Button {
                            shouldShowLocationSheet.toggle()
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                        }

                        TextField("Meal Location",text: $location, prompt: Text("Meal Location"))
                    }
                    DatePicker("Date", selection: $date)
                } header: {
                    Text("Details")
                }

                
                Section {
                    Toggle("Image?", isOn: $photoNeed)
                    if photoNeed{
                        Picker("Select Source", selection: $sourceSelection) {
                            Text("Camera")
                                .tag(CameraSourceType.camera)
                            Text("Photo Library")
                                .tag(CameraSourceType.library)
                        }
                        showPhotoSelection()
                    }
                    

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
                    Text("Send")
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
                            Text("Cancel").foregroundColor(Color(uiColor: .systemRed))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.saveMeal()
                        } label: {
                            Text("Add")
                                .foregroundColor(meals.isEmpty ? .gray : Color(uiColor: .systemGreen))
                        }
                        .disabled(meals.isEmpty)

                    }
                
            })
        .navigationTitle(Text("Add Meal"))
        }
    }
    
    func showSearchLocationSheet(){
        shouldShowLocationSheet.toggle()
    }
    
    @ViewBuilder
    func showPhotoSelection() -> some View{
        switch sourceSelection {
        case .camera:
            if let selectedPhoto {
                HStack{
                    Image(uiImage: selectedPhoto)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 100)
                        .cornerRadius(10)
                    Button {
                        self.selectedPhoto = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }

                }
                
            }
            Button {
                shouldShowCamera.toggle()
            } label: {
                Text("Take a photo")
            }
        case .library:
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                HStack{
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 100)
                        .cornerRadius(10)
                    Button {
                        self.selectedImageData = nil
                        self.selectedImage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }

                }
            }
            PhotosPicker(selection: $selectedImage) {
                Text("Select a photo")
            }
            
        }
    }
    
    func deleteMeal(at offsets: IndexSet){
        meals.remove(atOffsets: offsets)
    }
    
    func saveMeal(){
        let meal = Meal(context: context)
        meal.id = UUID()
        meal.items = meals
        meal.date = date
        if let selectedLocation{
            let location = Location(context: context)
            location.name = selectedLocation.item.placemark.name ?? ""
            location.latitude = selectedLocation.item.placemark.coordinate.latitude
            location.longitude = selectedLocation.item.placemark.coordinate.longitude
            meal.selectedLocation = location
            
        } else if !location.isEmpty{
            meal.location = location
        }
        if let selectedImageData{
            meal.image = selectedImageData
        } else if let selectedPhoto{
            meal.image = selectedPhoto.jpegData(compressionQuality: 0.8)
        }
        PersistenceController.save(context: context)
        presentationMode.wrappedValue.dismiss()
       
    }
}


struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
            AddMealView()
    }
}

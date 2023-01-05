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
                    Toggle("Image?", isOn: $photoNeed)
                    if photoNeed{
                        Picker("Select Source", selection: $sourceSelection) {
                            Text("Camera")
                                .tag(CameraSourceType.camera)
                            Text("Photo Library")
                                .tag(CameraSourceType.library)
                        }
                        imageView()
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
    
    
}

//MARK: - ViewBuilder
extension AddMealView{
    @ViewBuilder
    func imageView() -> some View{
        switch sourceSelection {
        case .camera:
            CameraView(selectedPhoto: $selectedPhoto, shouldShowCamera: $shouldShowCamera)
        case .library:
            ImageView(selectedImageData: $selectedImageData, selectedImage: $selectedImage)
        }
    }
}

//MARK: - ImageView
struct ImageView: View {
    
    @Binding var selectedImageData: Data?
    @Binding var selectedImage: PhotosPickerItem?
    
    var body: some View {
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

//MARK: - CameraView
struct CameraView: View {
    
    @Binding var selectedPhoto: UIImage?
    @Binding var shouldShowCamera: Bool
    
    var body: some View{
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
    }
}

//MARK: - LocationView
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

//MARK: - MealItemListView
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
    
    func deleteMeal(at offsets: IndexSet){
        meals.remove(atOffsets: offsets)
    }
}

//MARK: - Actions
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

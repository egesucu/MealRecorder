//
//  AddMealViewModel.swift
//  MealRecorder
//
//  Created by Ege Sucu on 11.02.2023.
//

import SwiftUI
import PhotosUI


class AddMealViewModel: ObservableObject{
    
    @Published var location = ""
    @Published var date = Date()
    @Published var photoNeed = false
    @Published var selectedImage: PhotosPickerItem?
    @Published var selectedImageData: Data? = nil
    @Published var selectedLocation: MapItem? = .init(item: .init())
    @Published var meals: [String] = []
    @Published var customAlertText: String = ""
    @Published var activeSheet : ActiveSheets?
    
    func updateLocation(location: MapItem) {
        self.selectedLocation = location
    }
    
    func updateLocation(location: String) {
        self.location = location
    }
}

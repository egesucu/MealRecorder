//
//  AddMealViewModel.swift
//  MealRecorder
//
//  Created by Ege Sucu on 11.02.2023.
//

import SwiftUI
import PhotosUI

class AddMealViewModel: ObservableObject {

    @Published var location = ""
    @Published var date: Date = .now
    @Published var photoNeed = false
    @Published var selectedImage: PhotosPickerItem?
    @Published var selectedImageData: Data?
    @Published var selectedLocation: MapItem?
    @Published var meals: [String] = []
    @Published var customAlertText = ""
    @Published var activeSheet: ActiveSheets?

    func updateLocation(location: MapItem) {
        self.selectedLocation = location
    }

    func updateLocation(location: String) {
        self.location = location
    }
}

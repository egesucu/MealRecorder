//
//  AddMealViewModel.swift
//  MealRecorder
//
//  Created by Ege Sucu on 11.02.2023.
//

import SwiftUI
import CoreData
import PhotosUI

class AddMealViewModel: ObservableObject {

    @Published var location = ""
    @Published var date: Date = .now
    @Published var selectedLocation: MapItem?
    @Published var meals: [String] = []
    @Published var customAlertText = ""
    @Published var activeSheet: ActiveSheets?
    @Published var mealType: MealType = .snack
    @Published var shouldAddLocation = false
    @Published var shouldAddImage = false
    @Published var imageSourceType: ImagesourceType = .library
    @Published var photosPickerItem: PhotosPickerItem?
    @Published var selectedImageData: Data?
    @Published var selectedImage: Image?
    @Published var imageFromPhoto: Image?
    @Published var takenPhotoData: Data?
    @Published var errorText: String?

    func updateLocation(location: MapItem) {
        self.selectedLocation = location
    }

    func saveMeal(model: MealListViewModel,
                  context: NSManagedObjectContext,
                  action: () -> Void) {
        model.addMeal(items: meals, date: date,
                     selectedLocation: selectedLocation,
                     context: context,
                     type: mealType)
            action()
    }

    func addMeal() {
        meals.append(customAlertText)
        customAlertText = ""
    }
}

enum ImagesourceType: Hashable {
    case library, camera
}

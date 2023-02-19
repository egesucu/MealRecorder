//
//  ImageSourceView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 6.01.2023.
//

import SwiftUI
import PhotosUI

struct ImageSourceView: View {
    @Binding var sourceSelection: CameraSourceType
    @Binding var selectedImageData: Data?
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedPhoto: UIImage?
    @Binding var shouldShowCamera: Bool

    var body: some View {
        switch sourceSelection {
        case .camera:
            CameraView(selectedPhoto: $selectedPhoto, shouldShowCamera: $shouldShowCamera)
        case .library:
            ImageView(selectedImageData: $selectedImageData, selectedImage: $selectedImage)
        }
    }
}

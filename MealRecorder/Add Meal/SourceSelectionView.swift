//
//  SourceSelectionView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 6.01.2023.
//

import SwiftUI
import PhotosUI

struct SourceSelectionView: View {

    @Binding var photoNeed: Bool
    @Binding var sourceSelection: CameraSourceType
    @Binding var selectedImageData: Data?
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedPhoto: UIImage?
    @Binding var shouldShowCamera: Bool

    var body: some View {
        Toggle("Image?", isOn: $photoNeed)
        if photoNeed {
            Picker("Select Source", selection: $sourceSelection) {
                Text("Camera")
                    .tag(CameraSourceType.camera)
                Text("Photo Library")
                    .tag(CameraSourceType.library)
            }
            ImageSourceView(sourceSelection: $sourceSelection,
                            selectedImageData: $selectedImageData,
                            selectedImage: $selectedImage,
                            selectedPhoto: $selectedPhoto,
                            shouldShowCamera: $shouldShowCamera)
        }
    }

}

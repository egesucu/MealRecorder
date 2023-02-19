//
//  ImageView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 6.01.2023.
//

import SwiftUI
import PhotosUI

struct ImageView: View {

    @Binding var selectedImageData: Data?
    @Binding var selectedImage: PhotosPickerItem?

    @State private var imageData: Data?

    var body: some View {
        if let imageData,
           let uiImage = UIImage(data: imageData) {
            HStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 100)
                    .cornerRadius(10)
                Button(role: .destructive) {
                    self.imageData = nil
                } label: {
                    Text("Delete the image")
                }
            }
        }
        PhotosPicker(selection: $selectedImage,
                     matching: .all(of: [.images, .depthEffectPhotos, .panoramas, .screenshots, .bursts]),
                     photoLibrary: .shared()) {
            Text("Select an image")
        }
                     .onChange(of: selectedImage) { image in
                         Task {
                             if let data = try? await image?.loadTransferable(type: Data.self) {
                                 imageData = data
                             }
                         }
                     }
    }
}

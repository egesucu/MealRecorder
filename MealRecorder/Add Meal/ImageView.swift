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

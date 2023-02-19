//
//  CameraView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 6.01.2023.
//

import SwiftUI

struct CameraView: View {

    @Binding var selectedPhoto: UIImage?
    @Binding var shouldShowCamera: Bool

    var body: some View {
        if let selectedPhoto {
            HStack {
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

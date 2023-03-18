//
//  CameraView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 18.03.2023.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIImagePickerController

    @Environment(\.dismiss) var dismiss
    @Binding var imageFromPhoto: Image?
    @Binding var takenPhotoData: Data?
    @Binding var errorText: String?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        (controller.sourceType, controller.allowsEditing) = (.camera, true)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.errorText = "Photo not chosen"
            parent.dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.imageFromPhoto = Image(uiImage: image)
                parent.takenPhotoData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
    }
}

//
//  PhotoLibrary.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/24.
//

import SwiftUI
import PhotosUI

struct PhotoLibrary: UIViewControllerRepresentable {
    var handlePickedImage: (UIImage?) -> Void
    
    static var isAvailable: Bool {
        return true
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // nothing to do
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(handlePickerImage: handlePickedImage)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var handlePickerImage: (UIImage?) -> Void
        
        init(handlePickerImage: @escaping (UIImage?) -> Void) {
            self.handlePickerImage = handlePickerImage
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            let found = results.map{ $0.itemProvider }.loadObjects(ofType: UIImage.self){ [weak self] image in
                self?.handlePickerImage(image)
            }
            if !found{
                handlePickerImage(nil)
            }
        }
    }
}

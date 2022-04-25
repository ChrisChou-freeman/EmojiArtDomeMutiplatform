//
//  Type.swift
//  EmojiArt (iOS)
//
//  Created by ChrisChou on 2022/4/24.
//

import SwiftUI

extension UIImage {
    var imageData: Data? { jpegData(compressionQuality: 1.0) }
}

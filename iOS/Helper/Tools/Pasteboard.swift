//
//  Pasteboard.swift
//  EmojiArt (iOS)
//
//  Created by ChrisChou on 2022/4/24.
//

import SwiftUI


struct Pasteboard {
    static var imageData: Data? {
        UIPasteboard.general.image?.imageData
    }
    static var ImageURL: URL? {
        UIPasteboard.general.url?.imageURL
    }
}

//
//  DocumentModel.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/3/31.
//

import Foundation

struct DocumentModel: Codable {
    var background = Background.blank
    var emojis: [Emoji] = []
    private var uniqueEmojiId = 0
    
    init() {}
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(DocumentModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try DocumentModel(json: data)
    }
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int){
        self.uniqueEmojiId += 1
        self.emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
    
    func json() throws -> Data{
        return try JSONEncoder().encode(self)
    }
    
    struct Emoji: Identifiable, Hashable, Codable {
        let text: String
        var x: Int          // offset from the center
        var y: Int          // offset from the center
        var size: Int
        var id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int){
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
}

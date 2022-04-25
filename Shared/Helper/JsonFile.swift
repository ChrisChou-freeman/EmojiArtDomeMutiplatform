//
//  JsonFile.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/19.
//

import Foundation

func loadJsonToStruct<T: Decodable>(_ fileUrl: URL) throws -> T{
    var data: Data?
    data = try Data(contentsOf: fileUrl)
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data!)
}

func saveStructsToFile<T: Encodable>(_ dataList: [T], to fileUrl: URL) throws {
    let encoder = JSONEncoder()
    let encodeData = try encoder.encode(dataList)
    try encodeData.write(to: fileUrl)
}


//
//  PaletteHandler.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/19.
//

import SwiftUI

struct Palette: Identifiable, Codable, Hashable {
    var id: Int
    var name: String
    var emojis: String
    
    fileprivate init(name: String, emojis: String, id: Int){
        self.name = name
        self.id = id
        self.emojis = emojis
    }
    
}

class PaletteHandler: ObservableObject {
    let name: String
    var isInit = false
    @Published var pallettes: [Palette] = [] {
        didSet{
            if !isInit{
                storeInFile()
            }
        }
    }
    private var userDefaultsKey: String {
        "PaletteStore:" + name
    }
    
    init(named name: String) {
        self.name = name
        restoreFromFile()
        if pallettes.isEmpty{
            isInit = true
            insertPalette(named: "Vehicles", emojis: "🚑🚒🚓🚔🚕🚖🚗🚘🚙🛻🚚🚛🏎🏍🛵🛺")
            insertPalette(named: "Food", emojis: "🍇🍈🍉🍊🍋🍌🍍🥭🍎🍏🍐🍑🍒🍓🫐🥝")
            insertPalette(named: "face", emojis: "😀🙃😉😊😇😃😄😁😆😅🤣😂🙂😕😟🙁")
            isInit = false
        }
    }
    
    private func storeInFile() {
        let thisfunction = "\(String(describing: self)).\(#function)"
        if let url = SaveManager.url{
            do{
                try saveStructsToFile(pallettes, to: url)
            }catch let encodingError where encodingError is EncodingError{
                print("\(thisfunction) couldn't encode json: \(encodingError.localizedDescription)")
            }catch{
                print("\(thisfunction) error = \(error)")
            }
        }
        
    }
    
    private func restoreFromFile() {
        let thisfunction = "\(String(describing: self)).\(#function)"
        do{
            let fileManager = FileManager.default
            if let url = SaveManager.url, fileManager.fileExists(atPath: url.path){
                self.pallettes = try loadJsonToStruct(url)
            }
        }catch let decodingError where decodingError is DecodingError{
            print("\(thisfunction) couldn't decode json from: \(decodingError.localizedDescription)")
        }catch{
            print("\(thisfunction) error = \(error)")
        }
    }
    
    func palette(at index: Int) -> Palette{
        let safeIndex = min(max(index, 0), pallettes.count - 1)
        return pallettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if pallettes.count > 1, pallettes.indices.contains(index){
            pallettes.remove(at: index)
        }
        return index % pallettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0){
        let unique = (pallettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), pallettes.count == 0 ? 0 : pallettes.count-1)
        pallettes.insert(palette, at: safeIndex)
    }
    
    private struct SaveManager{
        static let fileName = "AutoSaved.palette"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(fileName)
        }
        static let coalescingInterval = 5.0
    }
}

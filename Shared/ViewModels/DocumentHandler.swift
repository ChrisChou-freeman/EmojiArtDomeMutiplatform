//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/1.
//

//import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "ChrisChouFreeManDev.emojiart")
}

class DocumentHandler: ObservableObject, ReferenceFileDocument {
    static var readableContentTypes = [UTType.emojiart]
    static var writeableContentTypes = [UTType.emojiart]
    @Published private(set) var emojiArt: DocumentModel {
        didSet {
            if emojiArt.background != oldValue.background{
                fetchBackgroundImageDataIfNeccessary()
            }
        }
    }
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    var emojis: [DocumentModel.Emoji] {self.emojiArt.emojis}
    var background: DocumentModel.Background {self.emojiArt.background}
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try DocumentModel(json: data)
            fetchBackgroundImageDataIfNeccessary()
        }else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    init(){
        emojiArt = DocumentModel()
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    
    // use 2021 new feature async/await reimplement
    private var backgroundImageFetchCancellable: AnyCancellable?
    private func fetchBackgroundImageDataIfNeccessary(){
        self.backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            self.backgroundImageFetchStatus = .fetching
                backgroundImageFetchCancellable?.cancel()
                let session = URLSession.shared
                let publisher = session.dataTaskPublisher(for: url)
                    .map{ (data, urlRep) in UIImage(data: data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                backgroundImageFetchCancellable = publisher
                    .sink{ [weak self] image in
                        self?.backgroundImage = image
                        self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                    }
        case .imageData(let data):
            self.backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
        
    }
    
    func setBackground(_ background: DocumentModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set Backgroud", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?){
        undoablyPerform(operation: "Add\(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: DocumentModel.Emoji, by offset: CGSize, undoManager: UndoManager?){
        if let index = self.emojiArt.emojis.index(matching: emoji){
            undoablyPerform(operation: "Move", with: undoManager) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func moveEmojiWithIDs(with emojiIDs: [Int], by offset: CGSize){
        for emojiID in emojiIDs{
            if let index = self.emojiArt.emojis.firstIndex(where: {$0.id == emojiID}){
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func scaleEmoji(_ emoji: DocumentModel.Emoji, by scale: CGFloat, undoManager: UndoManager?){
        if let index = emojiArt.emojis.index(matching: emoji){
            undoablyPerform(operation: "Scale", with: undoManager) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
            
        }
    }
    
    func scalEmojiWithIDs(with emojiIDs: [Int], by scale: CGFloat){
        for emojiID in emojiIDs{
            if let index = emojiArt.emojis.firstIndex(where: {$0.id == emojiID}){
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    func removeEmojiWithIDs(with emojiIDs: [Int], undoManager: UndoManager?){
        for emojiID in emojiIDs{
            if let removeIndex = emojiArt.emojis.firstIndex(where: {$0.id == emojiID}){
                undoablyPerform(operation: "Delete", with: undoManager){
                    emojiArt.emojis.remove(at: removeIndex)
                }
            }
        }
    }
    
    //  MARK: - UNDO
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldDocument = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self){ myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt = oldDocument
            }
        }
        undoManager?.setActionName(operation)
    }
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
}

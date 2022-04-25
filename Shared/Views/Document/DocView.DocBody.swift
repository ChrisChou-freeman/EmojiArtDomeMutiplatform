//
//  MainView.docBody.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/16.
//

import SwiftUI
import PhotosUI


extension DocView{
    
    private var panOffset: CGSize {
        (self.steadyStatePanOffset + self.gesturePanOffset) * self.zoomScale
    }
    private var zoomScale: CGFloat {
        self.steadyStateZoomScale * self.gestureZoomScale
    }
    
    var documentBody: some View {
        GeometryReader{
            geometry in
            ZStack{
                Color.white
                OptionalImage(uiImage: document.backgroundImage)
                    .scaleEffect(self.zoomScale)
                    .position(self.convertFromEmojiCoordinates((0, 0), in: geometry))
                .gesture(doubleTapToZoom(in: geometry.size))
                .gesture(singleTapToUnselete())
                if self.document.backgroundImageFetchStatus == .fetching{
                    ProgressView()
                        .scaleEffect(2.0)
                }else{
                    ForEach(self.document.emojis) { emoji in
                        let element = Text(emoji.text)
                        Group{
                            if self.selectedElements.contains(emoji.id) {
                                element
                                    .border(.black, width: 2)
                                    .offset(self.selectedOffset)
                                    .scaleEffect(self.selectedZoom)
                            }else{
                                element
                            }
                        }
                        .font(.system(size: self.fontSize(for: emoji)))
                        .scaleEffect(self.zoomScale)
                        .position(self.position(for: emoji, in: geometry))
                        .onTapGesture{
                            if self.selectedElements.contains(emoji.id){
                                self.selectedElements.remove(at: selectedElements.firstIndex(where: {$0 == emoji.id})!)
                            }else{
                                self.selectedElements.append(emoji.id)
                            }
                        }
                    }
                    
                }
            }
            .clipped()
            .onDrop(of: [.utf8PlainText, .url, .image], isTargeted: nil){ providers, location in
                self.drop(providers: providers, at: location, in: geometry)
            }
            .gesture(self.panGesture().simultaneously(with: self.zoomGesture()))
            .alert(item: $alertToShow){ alert in
                alert.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus){ status in
                switch status{
                    case .failed(let url):
                        showBackgroudImageFetchFailedAlert(url)
                    default:
                        break
                }
            }
            .onChange(of: document.backgroundImage){ image in
                if autozoom{
                    zoomToFit(image, in: geometry.size)
                }
            }
            .compactableToolbar {
                AnimatedActionButton(title: "Paste Background", sysemImage: "doc.on.clipboard"){
                    pasteBackground()
                }
                if Camera.isAvailable{
                    Button{
                        backgroundPicker = .camera
                    }label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                }
                if PhotoLibrary.isAvailable{
                    Button{
                        backgroundPicker = .library
                    }label: {
                        Label("Picke Photos", systemImage: "photo")
                    }
                }
                #if os(iOS)
                if let undoManager = undoManager {
                    Button{
                        undoManager.undo()
                    }label: {
                        Label("Undo", systemImage: "arrow.uturn.left")
                    }

                    Button{
                        undoManager.redo()
                    }label: {
                        Label("Redo", systemImage: "arrow.uturn.right")
                    }
                }
                #endif
            }
            .sheet(item: $backgroundPicker){ pickerType in
                switch pickerType{
                    case .camera:
                        Camera(handlePickedImage: {image in handlePickedBackgroundImage(image)})
                    case .library:
                        PhotoLibrary(handlePickedImage: {image in handlePickedBackgroundImage(image)})
                }

            }
        }
    }

    private func handlePickedBackgroundImage(_ image: UIImage?){
        autozoom = true
        if let imageData = image?.imageData{
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        }
        backgroundPicker = nil
    }

    enum BackgroundPickerType: String, Identifiable{
        var id: String { rawValue }
        case camera
        case library
    }


    private func pasteBackground() {
        autozoom = true
        if let imageData = Pasteboard.imageData {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        }else if let url = Pasteboard.ImageURL{
            document.setBackground(.url(url), undoManager: undoManager)
        }else {
            alertToShow = IdentifiableAlert(id: "Paste Backgroud Error", alert: {
                Alert(
                    title: Text("Paste Backgroud"),
                    message: Text("There is no image currently on the pasteboard"),
                    dismissButton: .default(Text("OK"))
                )
            })
        }
    }
    
    private func showBackgroudImageFetchFailedAlert(_ url: URL){
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString, alert: {
            Alert(
                title: Text("Backgroud Image Fetch"),
                message: Text("Couldn't load image from \(url)."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
    
    func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            autozoom = true
            self.document.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        #if os(iOS)
        if !found{
            found = providers.loadObjects(ofType: UIImage.self){ image in
                autozoom = true
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }
        #endif
        if !found{
            found = providers.loadObjects(ofType: String.self){ string in
                if let emoji = string.first, emoji.isEmoji{
                    self.document.addEmoji(
                        String(emoji),
                        at: self.convertToEmojiCoordinates(location, geometry: geometry),
                        size: self.defaultEmojiFontSize / self.zoomScale,
                        undoManager: undoManager
                    )
                }
            }
        }
        return found
    }
    
    func singleTapToUnselete() -> some Gesture{
        TapGesture(count: 1)
            .onEnded{
                self.selectedElements.removeAll()
            }
    }
    
    func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation{
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    func zoomGesture() -> some Gesture {
        if self.selectedElements.count > 0{
            return MagnificationGesture()
                .updating(self.$selectedZoom){ latestGestureScale, selectedZoom, transaction in
                    selectedZoom = latestGestureScale
                }
                .onEnded{gestureScaleAtEnd in
                    document.scalEmojiWithIDs(with: selectedElements, by: gestureScaleAtEnd)
                }
        }else{
            return MagnificationGesture()
                .updating(self.$gestureZoomScale){ latestGestureScale, gestureZoomScale, transaction in
                    gestureZoomScale = latestGestureScale
                }
                .onEnded{gestureScaleAtEnd in
                    self.steadyStateZoomScale *= gestureScaleAtEnd
                }
        }
    }
    
    func panGesture(forSelected: Bool = false) -> some Gesture {
        if self.selectedElements.count > 0{
            return DragGesture()
                .updating(self.$selectedOffset) { latestDragGestureValue, selectedOffset, _ in
                    selectedOffset = latestDragGestureValue.translation / self.zoomScale
                }
                .onEnded {finalDragGestureValue in
                    document.moveEmojiWithIDs(with: selectedElements, by: finalDragGestureValue.translation / self.zoomScale)
                }
        }else{
            return DragGesture()
                .updating(self.$gesturePanOffset) { latestDragGestureValue ,gesturePanOffset, _ in
                    gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
                }
                .onEnded { finalDragGestureValue in
                    self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
                }
        }
        
    }
    
    func fontSize(for emoji: DocumentModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    func position(for emoji: DocumentModel.Emoji, in geometry: GeometryProxy) -> CGPoint{
        self.convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint{
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * self.zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * self.zoomScale + panOffset.height
        )
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - self.panOffset.width - center.x) / self.zoomScale,
            y: (location.y - self.panOffset.height - center.y) / self.zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hzoom = size.width / image.size.width
            let vzoom  = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hzoom, vzoom)
        }
    }
}

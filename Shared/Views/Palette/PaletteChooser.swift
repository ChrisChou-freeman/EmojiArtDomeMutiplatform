//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/19.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var paletteHandler: PaletteHandler
    var EmojiFontSize: CGFloat
    
    @SceneStorage("PaletteChooser.chosenPaletteIndex")
    private var chosenPaletteIndex = 0
    var emojiFont: Font{
        .system(size: EmojiFontSize)
    }
    @State private var editing = false
    @State private var managing = false
    var body: some View {
        HStack{
            paletteControButton
            paletteView(for: paletteHandler.palette(at: chosenPaletteIndex))
        }
        .clipped()
        .padding()
    }
    
    func paletteView(for palette: Palette) -> some View{
        HStack{
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
        .popover(isPresented: $editing){
            PaletteEditor(palette: $paletteHandler.pallettes[chosenPaletteIndex])
                .popoverPadding()
                .makeNavigationDismissable{ editing = false }
        }
        .sheet(isPresented: $managing){
            PaletteList()
        }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", sysemImage: "pencil"){
            editing = true
        }
        AnimatedActionButton(title: "New", sysemImage: "plus"){
            paletteHandler.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
            editing = true
        }
        #if os(iOS)
        AnimatedActionButton(title: "Manager", sysemImage: "slider.vertical.3"){
            managing = true
        }
        #endif
        AnimatedActionButton(title: "Delete", sysemImage: "minus.circle"){
            chosenPaletteIndex = paletteHandler.removePalette(at: chosenPaletteIndex)
        }
        gotoMenu
    }
    
    var gotoMenu: some View{
        Menu{
            ForEach(paletteHandler.pallettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = paletteHandler.pallettes.index(matching: palette){
                        chosenPaletteIndex = index
                    }
                }
            }
        }label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    var paletteControButton: some View{
        Button{
            withAnimation{
                chosenPaletteIndex = (chosenPaletteIndex + 1) % paletteHandler.pallettes.count
            }
        }label: {
            Image(systemName: "paintpalette")
        }
        .paletteControlButtonStyle()
        .font(emojiFont)
        .contextMenu{contextMenu}
    }
    
    var rollTransition: AnyTransition{
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: EmojiFontSize),
            removal: .offset(x: 0, y: -EmojiFontSize)
        )
    }
}

struct ScrollingEmojisView: View{
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(self.emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag{ NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(EmojiFontSize: 40)
    }
}

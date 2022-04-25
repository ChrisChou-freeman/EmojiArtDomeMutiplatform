//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/19.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    @State private var emojisToAdd = ""
    var body: some View {
        Form {
            nameSection
            addEmojisSection
            removeEmojiSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300,  minHeight: 350)
        
    }
    var nameSection: some View {
        Section(header: Text("Name")){
            TextField("", text: $palette.name)
        }
    }
    var addEmojisSection: some View {
        withAnimation{
            Section(header: Text("Add Emojis")){
                TextField("", text: $emojisToAdd)
                    .onChange(of: emojisToAdd){ emojis in
                        addEmojis(emojis)
                    }
            }
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")){
            let emojis = palette.emojis.removingDuplicateCharacters.map{ String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                ForEach(emojis, id: \.self){ emoji in
                    Text(emoji)
                        .font(.system(size: 40.0))
                        .onTapGesture {
                            withAnimation{
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation{
            palette.emojis = (emojis + palette.emojis)
                .filter{ $0.isEmoji }
                .removingDuplicateCharacters
        }
    }
    
    
}

struct PaletteEditor_Previews: PreviewProvider {
    static var pallette = PaletteHandler(named: "Default").palette(at: 0)
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteHandler(named: "Test").palette(at: 0)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}

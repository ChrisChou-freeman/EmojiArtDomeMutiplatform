//
//  PaletteList.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/20.
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var paletteHandler: PaletteHandler
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(paletteHandler.pallettes) { palette in
                    NavigationLink{
                        PaletteEditor(
                            palette: $paletteHandler.pallettes[palette]
                        )
                    }label: {
                        VStack(alignment: .leading){
                            Text(palette.name).font(colorScheme == .dark ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete{ indexSet in
                    paletteHandler.pallettes.remove(atOffsets: indexSet)
                }
                .onMove{ indexSet, newOffset in
                    paletteHandler.pallettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage List")
            .navigationBarTitleDisplayMode(.inline)
            .dismissable{ presentationMode.wrappedValue.dismiss() }
            .toolbar{
                ToolbarItem{ EditButton() }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteList()
            .environmentObject(PaletteHandler(named: "Test"))
    }
}

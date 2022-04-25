//
//  Button.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/19.
//

import SwiftUI

struct AnimatedActionButton: View{
    var title: String?
    var sysemImage: String?
    let action: () -> Void
    
    var body: some View {
        Button{
            withAnimation{
                action()
            }
        } label: {
            if title != nil && sysemImage != nil{
                Label(title!, systemImage: sysemImage!)
            }else if title != nil{
                Text(title!)
            }else if sysemImage != nil {
                Image(systemName: sysemImage!)
            }
        }
    }
}

struct UndoButton: View{
    let undo: String?
    let redo: String?
    @Environment(\.undoManager) var undoManager
    var body: some View {
        let canUndo = undoManager?.canUndo ?? false
        let canRedo = undoManager?.canRedo ?? false
        if canUndo || canRedo {
            Button {
                if canUndo {
                    undoManager?.undo()
                }else{
                    undoManager?.redo()
                }
            } label: {
                if canUndo {
                    Image(systemName: "arrow.uturn.backward.circle")
                }else{
                    Image(systemName: "arrow.uturn.forward.circle")
                }
            }
            .contextMenu{
                if canUndo {
                    Button{
                        undoManager?.undo()
                    }label: {
                        Label(undo ?? "Undo", systemImage: "arrow.uturn.backward")
                    }
                }
                if canRedo{
                    Button {
                        undoManager?.redo()
                    } label: {
                        Label(redo ?? "Redo", systemImage: "arrow.uturn.forward")
                    }
                }
            }
        }
    }
}

extension UndoManager {
    var optionalUndoMenuItemTitle: String? {
        canUndo ? undoMenuItemTitle : nil
    }
    var optionalRedoMenuItemTitle: String? {
        canRedo ? redoMenuItemTitle : nil
    }
}

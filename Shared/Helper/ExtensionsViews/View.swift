//
//  window.swift
//  EmojiArt
//
//  Created by ChrisChou on 2022/4/20.
//

import SwiftUI

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}

struct CompactableIntoContextMenu: ViewModifier {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var compact: Bool { horizontalSizeClass == .compact}
    #else
    var compact: Bool = false
    #endif
    
    func body(content: Content) -> some View {
        if compact {
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .contextMenu{
                content
            }
        }else{
            content
        }
    }
}

extension View {
    func compactableToolbar<Content>(@ViewBuilder content:  () -> Content) -> some View where Content: View {
        self.toolbar {
            content().modifier(CompactableIntoContextMenu())
        }
    }
}

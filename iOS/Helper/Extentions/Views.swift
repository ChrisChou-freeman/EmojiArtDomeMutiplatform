//
//  Extensions.swift
//  EmojiArt (iOS)
//
//  Created by ChrisChou on 2022/4/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func makeNavigationDismissable(_ dismiss: (()-> Void)? ) -> some View{
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss{
            NavigationView{
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissable(dismiss)
            }
            .navigationViewStyle(.stack)
        }else {
            self
        }
    }
    
    @ViewBuilder
    func dismissable(_ dismiss: (()->Void)?) -> some View{
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss{
            self.toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Close"){ dismiss() }
                }
            }
        }else {
            self
        }
    }
    
    func paletteControlButtonStyle() -> some View{
        self
    }
    
    func popoverPadding() -> some View {
        self
    }
}

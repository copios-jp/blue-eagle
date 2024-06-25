//
//  View.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/20.
//

import SwiftUI

extension View {
  func inspectableSheet<Sheet>(
    isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Sheet
  ) -> some View
  where
    Sheet: View
  {
    return self.modifier(
      InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
  }
}

struct InspectableSheet<Sheet>: ViewModifier where Sheet: View {
  let isPresented: Binding<Bool>
  let onDismiss: (() -> Void)?
  let popupBuilder: () -> Sheet

  func body(content: Self.Content) -> some View {
    content.sheet(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
  }
}

extension View {
  func fullScreenCover2<FullScreenCover>(
    isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> FullScreenCover
  ) -> some View where FullScreenCover: View {
    return self.modifier(
      InspectableFullScreenCover(
        isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
  }
}

struct InspectableFullScreenCover<FullScreenCover>: ViewModifier where FullScreenCover: View {

  let isPresented: Binding<Bool>
  let onDismiss: (() -> Void)?
  let popupBuilder: () -> FullScreenCover

  func body(content: Self.Content) -> some View {
    content.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
  }
}

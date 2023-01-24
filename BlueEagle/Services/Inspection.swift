//
//  Inspection.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/20.
//

import SwiftUI
import Combine

internal final class Inspection<V> {
  let notice = PassthroughSubject<UInt, Never>()
  var callbacks = [UInt: (V) -> Void]()
  
  func visit(_ view: V, _ line: UInt) {
    if let callback = callbacks.removeValue(forKey: line) {
      callback(view)
    }
  }
}

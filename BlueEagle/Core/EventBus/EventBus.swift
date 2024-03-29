//
//  EventBus.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/13.
//

import Foundation

protocol EventBus {
  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable])
  func trigger(_ name: NSNotification.Name)
  func registerObservers(_ observer: Any, _ observing: [Selector: NSNotification.Name])
  func removeObserver(_ observer: Any)
}

extension NotificationCenter: EventBus {
  func trigger(_ name: NSNotification.Name) {
    post(name: name, object: self)
  }

  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable]) {
    post(name: name, object: self, userInfo: data)
  }

  func registerObservers(_ observer: Any, _ observing: [Selector: NSNotification.Name]) {
    for (selector, name) in observing {
      addObserver(observer, selector: selector, name: name, object: nil)
    }
  }
}

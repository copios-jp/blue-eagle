//
//  EventBus.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/13.
//

import Foundation

protocol EventBus {
  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: Any])
  func trigger(_ name: NSNotification.Name)
  func registerObservers(_ observer: AnyObject, _ observing: [Selector: NSNotification.Name])
}

extension NotificationCenter: EventBus {
  func trigger(_ name: NSNotification.Name) {
    post(name: name, object: self)
  }

  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: Any]) {
    post(name: name, object: self, userInfo: data)
  }

  func registerObservers(_ observer: AnyObject, _ observing: [Selector: NSNotification.Name]) {
    for (selector, name) in observing {
      addObserver(observer, selector: selector, name: name, object: nil)
    }
  }
}

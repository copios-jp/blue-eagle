//
//  EventBus.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/13.
//

import Foundation

protocol EventBusNotificationCenter {

  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable])

  func trigger(_ name: NSNotification.Name)

  func registerObservers(_ observer: Any, _ observing: [Selector: NSNotification.Name])

  func registerObservers(_ observer: Any, _ observing: [Selector: [NSNotification.Name]])

  func removeObserver(_ observer: Any)
}

extension NotificationCenter: EventBusNotificationCenter {
  func trigger(_ name: NSNotification.Name) {
    DispatchQueue.main.async {
      self.post(name: name, object: self)
    }
  }

  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable]) {
    DispatchQueue.main.async {
      self.post(name: name, object: self, userInfo: data)
    }
  }

  func registerObservers(_ observer: Any, _ observing: [Selector: [NSNotification.Name]]) {
    for (selector, notifications) in observing {
      for (notification) in notifications {
        addObserver(observer, selector: selector, name: notification, object: nil)
      }
    }
  }

  func registerObservers(_ observer: Any, _ observing: [Selector: NSNotification.Name]) {
    for (selector, name) in observing {
      addObserver(observer, selector: selector, name: name, object: nil)
    }
  }
}

/// EventBus extends Foundation NotificationCenter.default with the ``EventBusNotificationCenter`` protocol
/// providing a simpler interface for registering observers and triggering events
let EventBus: EventBusNotificationCenter = NotificationCenter.default

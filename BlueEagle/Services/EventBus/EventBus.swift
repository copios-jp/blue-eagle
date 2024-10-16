import Foundation

protocol EventBusObserver {
  var observing: [Selector: [NSNotification.Name]] { get }
}

protocol EventBusNotificationCenter {

  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable])

  func trigger(_ name: NSNotification.Name)

  func addObserver(_ observer: EventBusObserver)

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

  func addObserver(_ observer: EventBusObserver) {
    for (selector, notifications) in observer.observing {
      for (notification) in notifications {
        addObserver(observer, selector: selector, name: notification, object: nil)
      }
    }
  }
}

/// EventBus extends Foundation NotificationCenter.default with the ``EventBusNotificationCenter`` protocol
/// providing a simpler interface for registering observers and triggering events
let EventBus: EventBusNotificationCenter = NotificationCenter.default

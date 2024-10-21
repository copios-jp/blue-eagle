import Foundation

protocol EventBusObserver {
  var observing: [Selector: [NSNotification.Name]] { get }
}

protocol EventBusNotificationCenter {

  func trigger(_ event: EventBusEvent)

  func addObserver(_ observer: EventBusObserver)

  func removeObserver(_ observer: Any)
}

extension NotificationCenter: EventBusNotificationCenter {
    func trigger(_ event: any EventBusEvent) {
      DispatchQueue.main.async {
        self.post(name: event.name, object: event)
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

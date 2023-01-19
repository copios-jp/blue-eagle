//
//  EventBusMock.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

@testable import BlueEagle
import Foundation
class EventBusMock: EventBus {
  var observing: [Selector: NSNotification.Name]?
  var observer: Any?
  var passThru: Bool = true
  
  struct Call {
    var name: NSNotification.Name
    var userInfo: [AnyHashable: AnyHashable]?
  }
 
  init(_ passThru: Bool = true) {
    self.passThru = passThru
  
  }
  
  var calls: [Call] = []

  func reset() {
    calls = []
    guard let observer = self.observer else {
      return
    }
    
    guard let observing = self.observing else {
      return
    }
    
    for (_, value) in observing {
      NotificationCenter.default.removeObserver(observer, name: value, object: nil)
    }
  }
  
  func hasCall(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable] = [:]) -> Bool {
    let byName: [Call] = calls.filter { $0.name == name }
   
    if !data.isEmpty {
      guard byName.first(where: {
        var match = true
        for (key, value) in data {
          match = match && $0.userInfo?[key] == value
        }
        return match
      }) != nil
      else { return false }
    }
    return byName.count > 0
  }
  
  func trigger(_ name: NSNotification.Name) {
    calls.append(Call(name: name, userInfo: nil))
    if(passThru) {
      NotificationCenter.default.post(name: name, object: self)
    }
  }
  
  func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: AnyHashable]) {
    calls.append(Call(name: name, userInfo: data))
    
    if(passThru) {
      NotificationCenter.default.post(name: name, object: self, userInfo: data)
    }
  }
  
  func registerObservers(_ observer: Any, _ observing: [Selector: NSNotification.Name]) {
    self.observer = observer
    self.observing = observing
    
    if(passThru) {
      for (selector, name) in observing {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
      }
    }
  }
 }

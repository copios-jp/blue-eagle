//
//  File.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//
import Foundation
import SwiftUI

class Training: NSObject, Encodable, ObservableObject {
  let uuid = UUID()
  var restingHR: Int = 70
  var endedAt: Date?
  var trainingStyle: TrainingStyle = GarminTraining()
  var samples: [HRSample] = []
  var calorieCounter: CalorieCounter = .init()

  @Published var currentHR: Int = 0

  @Published var qrcode: QRCode?
  @Published var broadcasting: Bool = false

  override init() {
    super.init()

    NotificationCenter.default.addObserver(self, selector: #selector(heartRateReceived(notification:)), name: NSNotification.Name.HeartRateMonitorValueUpdated, object: nil)
    qrcode = QRCode(uuid.uuidString)
  }

  private var startedAt: Date?

  private enum CodingKeys: String, CodingKey {
    case currentHR
    case trainingZoneDescription
    case trainingZone
    case trainingZoneMax
    case trainingZoneMin
    case percentOfMax
    case averageHR
    case calories
    case at
  }

  public func qr() -> URL {
    let url = URL(string: Endpoints.qrcode + uuid.uuidString)!
    print(url)
    return url
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(currentHR, forKey: .currentHR)
    try container.encode(currentTrainingZone.description, forKey: .trainingZoneDescription)
    try container.encode(currentTrainingZone.position, forKey: .trainingZone)
    try container.encode(currentTrainingZone.minHR, forKey: .trainingZoneMin)
    try container.encode(currentTrainingZone.maxHR, forKey: .trainingZoneMax)
    try container.encode(averageHR, forKey: .averageHR)
    try container.encode(percentOfMax, forKey: .percentOfMax)
    try container.encode(calories, forKey: .calories)
    try container.encode(Date(), forKey: .at)
  }

  public func toJson() -> String {
    guard let json = try? JSONEncoder().encode(self)
    else {
      return "{\"error\": \"Training is unencodable\"}"
    }
    return String(data: json, encoding: .utf8)!
  }

  private func broadcast() throws {
    let data: Data = toJson().data(using: .utf8)!
    let channel: String = uuid.uuidString

    API().broadcast(channel: channel, data: data)
  }

  @objc func heartRateReceived(notification: Notification) {
    let heartRate: Int = notification.userInfo!["sample"] as! Int
    addSample(heartRate)

    if broadcasting {
      do {
        try broadcast()
      } catch {
        print(error)
      }
    }
  }

  var duration: DateComponents {
    guard let from: Date = startedAt else {
      return Calendar.current.dateComponents([.second, .minute, .hour], from: Date(), to: Date())
    }

    let to = endedAt ?? Date()

    return Calendar.current.dateComponents([.second, .minute, .hour], from: from, to: to)
  }

  var averageHR: Int {
    if samples.isEmpty {
      return 0
    }
    return samples.reduce(0) { memo, sample -> Int in memo + sample.rate } / samples.count
  }

  var reserveHR: Int {
    return maxHR - restingHR
  }

  var currentTrainingZone: TrainingZone {
    trainingStyle.currentZone(training: self)
  }

  var averageTrainingZone: TrainingZone {
    trainingStyle.averageZone(training: self)
  }

  var percentOfMax: Double {
    return Double(currentHR) / Double(maxHR)
  }

  var percentOfReserve: Double {
    Double(currentHR - restingHR) / Double(reserveHR)
  }

  var calories: Int {
    return calorieCounter.calories(self)
  }

  var maxHR: Int {
    return Int(211.0 - 0.67 * Double(Preferences.standard.age))
  }

  func start() {
    startedAt = Date()
  }

  func addSample(_ heartRate: Int, _ at: Date = Date()) {
    samples.append(HRSample(rate: heartRate, at: at))
    currentHR = heartRate
  }
}

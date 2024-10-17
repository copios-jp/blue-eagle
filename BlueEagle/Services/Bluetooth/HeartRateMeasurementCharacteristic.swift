import Foundation

// @see HRS_SPEC_V10.pdf in repo docs

extension BluetoothService {
    
/**

HeartRateMeasurementCharacteristic

HeartRateMeasurmentCharacteritic is a utility structure to isolate parsing of heart rate measurement characteristics as recieved from a bluetooth heart rate monitor peripheral
*/

  struct HeartRateMeasurementCharacteristic {
    struct Options: OptionSet {
      let rawValue: UInt8
      static let uInt16Format = Options(rawValue: 1 << 0)
      static let sensorStatus = Options(rawValue: 1 << 1)
      static let sensorContact = Options(rawValue: 1 << 2)
      static let energyExpended = Options(rawValue: 1 << 3)
      static let rrIntervals = Options(rawValue: 1 << 4)
    }

    enum DataFormat {
      case uInt8
      case uInt16
    }

    enum SensorStatus {
      case unsupported
      case good
      case poor
    }

    let uuid: UUID = .init()
    let sensorStatus: SensorStatus
    let rrIntervals: [Int]?
    let energyExpended: Int?
    let sample: Double
    let options: Options

    static private func combine(_ lsb: UInt8, _ msb: UInt8) -> UInt16 {
      UInt16(msb) << 8 + UInt16(lsb)
    }

    init(_ payload: Data) {

      var iterator = [UInt8](payload).makeIterator()

      options = Options(rawValue: iterator.next()!)

      if options.contains(.sensorContact) {
        sensorStatus = options.contains(.sensorStatus) ? .good : .poor
      } else {
        sensorStatus = .unsupported
      }

      sample =
        options.contains(.uInt16Format)
        ? Double(Self.combine(iterator.next()!, iterator.next()!)) : Double(iterator.next()!)

      energyExpended =
        options.contains(.energyExpended)
        ? Int(Self.combine(iterator.next()!, iterator.next()!)) : nil

      guard options.contains(.rrIntervals) else {
        rrIntervals = nil
        return
      }

      var intervals: [Int] = []
      while let left = iterator.next() {
        intervals.append(Int(Self.combine(left, iterator.next()!)))
      }

      rrIntervals = intervals
    }
  }
}

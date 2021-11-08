//
//  ObserverQRCode.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/07.
//

import Foundation
import UIKit

func createObserverQRCode(text: String) -> Data? {
    let data = text.data(using: .ascii, allowLossyConversion: false)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    guard let ciiimage = filter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledCIImage = ciiimage.transformed(by: transform)
    
    let uiimage = UIImage(ciImage: scaledCIImage)
    return uiimage.pngData()!
    
}

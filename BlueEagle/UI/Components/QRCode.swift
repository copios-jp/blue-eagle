//
//  QRCode.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/07.
//

import SwiftUI

class QRCode: ObservableObject {
    var uuid: String
    
    @Published var image: UIImage?
    
    init(_ uuid: String) {
        self.uuid = uuid
        load()
                
    }
    
    func load() {
        API().qrcode(uuid) { data in
            self.image = UIImage(data: data)
        }
    }
}

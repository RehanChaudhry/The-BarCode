//
//  UIImageViewAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 08/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import CoreImage

extension UIImageView {
    func generateQRCode(orderId: String) {
        
        let qrString = orderId
        
        let qrData = qrString.data(using: .utf8)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        guard let qrImage = qrFilter.outputImage else { return }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
           
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return }
           
        self.image = UIImage(cgImage: cgImage)
    }
}

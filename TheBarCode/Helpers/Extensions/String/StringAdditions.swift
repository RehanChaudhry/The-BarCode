//
//  StringAdditions.swift
//  Manga
//
//  Created by Muhammad Zeeshan on 05/07/2017.
//  Copyright © 2017 Muhammad Zeeshan. All rights reserved.
//

import UIKit
import Foundation
import DTCoreText

extension String {
    
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPostCode() -> Bool {
        if Utility.shared.regionalInfo.country == INCountryCode {
            let postcodeFormat = "^[1-9][0-9]{5}$"
            let postcodePredicate = NSPredicate(format:"SELF MATCHES %@", postcodeFormat)
            return postcodePredicate.evaluate(with: self)
        } else {
            let postcodeFormat = "^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}$"
            let postcodePredicate = NSPredicate(format:"SELF MATCHES %@", postcodeFormat)
            return postcodePredicate.evaluate(with: self)
        }
    }
    
    func trimWhiteSpaces() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func getFormattedEventName() -> String {
        let underscoreString = self.replacingOccurrences(of: " ", with: "_")
        return underscoreString.lowercased()
    }
    
    func matchesRegex(regex: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = self as NSString
            let match = regex.firstMatch(in: self, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
}

extension String {
    func html2Attributed(isTitle: Bool) -> NSAttributedString? {
        guard let data = data(using: String.Encoding.unicode, allowLossyConversion: false) else {
            return nil
        }
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html,
                       DTDefaultTextColor : UIColor.white] as [AnyHashable : Any]
        guard let attributedString = NSMutableAttributedString(htmlData: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        if let lastCharacter = attributedString.string.last, lastCharacter == "\n" {
            attributedString.deleteCharacters(in: NSRange(location: attributedString.length-1, length: 1))
        }
        
        let range = NSRange(location: 0, length: attributedString.length)
        if attributedString.length > 0 {
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: range)
            
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.lineSpacing = 3.0
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paraStyle, range: range)
        }
        
        let enumerationOption = NSAttributedString.EnumerationOptions(rawValue: 0)
        attributedString.enumerateAttribute(NSAttributedStringKey.font, in: range, options: enumerationOption) { (value, range, stop) in
            if let font = value as? UIFont {
                let appFont: UIFont!
                let fontDescriptor = font.fontDescriptor
                
                if isTitle {
                    appFont = UIFont.appBoldFontOf(size: 16.0)
                } else if fontDescriptor.symbolicTraits.contains(.traitBold) {
                    if fontDescriptor.symbolicTraits.contains(.traitItalic) {
                        appFont = UIFont.appBoldItalicFontOf(size: fontDescriptor.pointSize <= 12.0 ? 16.0 : fontDescriptor.pointSize)
                    } else {
                        appFont = UIFont.appBoldFontOf(size: fontDescriptor.pointSize <= 12.0 ? 16.0 : fontDescriptor.pointSize)
                    }
                } else if fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    appFont = UIFont.appItalicFontOf(size: fontDescriptor.pointSize <= 12.0 ? 16.0 : fontDescriptor.pointSize)
                } else {
                    appFont = UIFont.appRegularFontOf(size: fontDescriptor.pointSize <= 12.0 ? 16.0 : fontDescriptor.pointSize)
                }
                
                attributedString.removeAttribute(NSAttributedStringKey.font, range: range)
                attributedString.addAttribute(NSAttributedStringKey.font, value: appFont, range: range)
            }
        }
        
        return attributedString
    }
    
    func removeHTMLTag() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
     }
}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

//
//  AttrString.swift
//  CLX
//
//  Created by MrQi on 2024/5/14.
//

import UIKit

struct AttrString {
    let attributedString: NSAttributedString
}

extension AttrString: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        attributedString = NSAttributedString(string: stringLiteral)
    }
}

extension AttrString: CustomStringConvertible {
    var description: String {
        return String(describing: attributedString)
    }
}

extension AttrString: ExpressibleByStringInterpolation {
    init(stringInterpolation: StringInterpolation) {
        attributedString = NSAttributedString(attributedString: stringInterpolation.mutableAttributedString)
    }
    
    struct StringInterpolation: StringInterpolationProtocol {
        var mutableAttributedString: NSMutableAttributedString
        
        init(literalCapacity: Int, interpolationCount: Int) {
            mutableAttributedString = NSMutableAttributedString()
        }
        
        func appendLiteral(_ literal: StringLiteralType) {
            let astr = NSAttributedString(string: literal)
            mutableAttributedString.append(astr)
        }
        
        func appendInterpolation(_ string: StringLiteralType, attributes: [NSAttributedString.Key: Any]) {
            let astr = NSAttributedString(string: string, attributes: attributes)
            mutableAttributedString.append(astr)
        }
    }
}

extension AttrString {
    struct Style {
        let attributes: [NSAttributedString.Key: Any]
        static func font(_ font: UIFont) -> Style {
            return Style(attributes: [.font: font])
        }
        
        static func color(_ color: UIColor) -> Style {
            return Style(attributes: [.foregroundColor: color])
        }
        
        static func bgColor(_ color: UIColor) -> Style {
            return Style(attributes: [.backgroundColor: color])
        }
        
        static func link(_ link: String) -> Style {
            return Style(attributes: [.link: link])
        }
        
        static func link(_ link: URL) -> Style {
            return Style(attributes: [.link: link])
        }
        
        static func underline(_ color: UIColor, _ style: NSUnderlineStyle) -> Style {
            return Style(attributes: [.underlineColor: color, .underlineStyle: style])
        }
        
        static func alignment(_ alignment: NSTextAlignment) -> Style {
            let ps = NSMutableParagraphStyle()
            ps.alignment = alignment
            return Style(attributes: [.paragraphStyle: ps])
        }
    }
}

extension AttrString.StringInterpolation {
    func appendInterpolation(_ string: StringLiteralType, _ style: AttrString.Style...) {
        var attrs: [NSAttributedString.Key: Any] = [:]
            style.forEach { attrs.merge($0.attributes, uniquingKeysWith: {$1}) }
            let astr = NSAttributedString(string: string, attributes: attrs)
        mutableAttributedString.append(astr)
    }
    
    func appendInterpolation(image: UIImage, scale: CGFloat = 1.0) {
        let attachment = NSTextAttachment()
        let size = CGSize(
              width: image.size.width * scale,
              height: image.size.height * scale
            )
        attachment.image = UIImage(data: image.pngData()!, scale: scale)
        attachment.bounds = CGRect(origin: .zero, size: size)
        mutableAttributedString.append(NSAttributedString(attachment: attachment))
    }
    
    func appendInterpolation(wrap string: AttrString, _ style: AttrString.Style...) {
        var attrs: [NSAttributedString.Key: Any] = [:]
            style.forEach { attrs.merge($0.attributes, uniquingKeysWith: {$1}) }
            let mas = NSMutableAttributedString(attributedString: string.attributedString)
            let fullRange = NSRange(mas.string.startIndex..<mas.string.endIndex, in: mas.string)
            mas.addAttributes(attrs, range: fullRange)
        mutableAttributedString.append(mas)
    }
}

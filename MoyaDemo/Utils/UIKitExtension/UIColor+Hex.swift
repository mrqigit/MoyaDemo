//
//  UIColor+Hex.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/6.
//

import UIKit

extension UIColor {
    /// 使用十六进制字符串创建UIColor
    /// - Parameters:
    ///   - hexString: 十六进制颜色字符串，支持格式: #RGB, #RGBA, #RRGGBB, #RRGGBBAA, RGB, RGBA, RRGGBB, RRGGBBAA
    ///   - alpha: 可选透明度，默认1.0（如果hexString包含透明度，则此参数会被忽略）
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        // 处理字符串，移除可能的#号
        var cleanedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedString = cleanedString.replacingOccurrences(of: "#", with: "")
        
        // 定义变量存储RGB和Alpha值
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alphaValue: CGFloat = alpha
        
        // 根据字符串长度判断格式
        let length = cleanedString.count
        
        // 支持的格式：3, 4, 6, 8位
        guard length == 3 || length == 4 || length == 6 || length == 8 else {
            fatalError("无效的十六进制颜色字符串格式，请使用RGB, RGBA, RRGGBB或RRGGBBAA格式")
        }
        
        // 转换为UInt64
        guard let hexNumber = UInt64(cleanedString, radix: 16) else {
            fatalError("无效的十六进制颜色值")
        }
        
        // 解析不同格式的颜色值
        switch length {
        case 3: // RGB (每个分量1位，扩展为2位)
            red = CGFloat((hexNumber >> 8) & 0x0F) / 15.0
            green = CGFloat((hexNumber >> 4) & 0x0F) / 15.0
            blue = CGFloat(hexNumber & 0x0F) / 15.0
            
        case 4: // RGBA (每个分量1位，扩展为2位)
            red = CGFloat((hexNumber >> 12) & 0x0F) / 15.0
            green = CGFloat((hexNumber >> 8) & 0x0F) / 15.0
            blue = CGFloat((hexNumber >> 4) & 0x0F) / 15.0
            alphaValue = CGFloat(hexNumber & 0x0F) / 15.0
            
        case 6: // RRGGBB (每个分量2位)
            red = CGFloat((hexNumber >> 16) & 0xFF) / 255.0
            green = CGFloat((hexNumber >> 8) & 0xFF) / 255.0
            blue = CGFloat(hexNumber & 0xFF) / 255.0
            
        case 8: // RRGGBBAA (每个分量2位)
            red = CGFloat((hexNumber >> 24) & 0xFF) / 255.0
            green = CGFloat((hexNumber >> 16) & 0xFF) / 255.0
            blue = CGFloat((hexNumber >> 8) & 0xFF) / 255.0
            alphaValue = CGFloat(hexNumber & 0xFF) / 255.0
            
        default:
            fatalError("无效的十六进制颜色字符串长度")
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alphaValue)
    }
    
    /// 使用十六进制数值创建UIColor
    /// - Parameters:
    ///   - hex: 十六进制数值，如0xFFFFFF
    ///   - alpha: 透明度，默认1.0
    convenience init(hex: UInt64, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

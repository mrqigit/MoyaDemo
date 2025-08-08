//
//  UITextField+MaxLength.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/8.
//

import UIKit

extension UITextField {
    
    // 存储关联对象Key
    private struct AssociatedKeys {
        static var delegate: UInt8 = 0
    }
    
    var maxLength: Int? {
        set {
            hookDelegate.maxLength = newValue
        }
        get {
            return hookDelegate.maxLength
        }
    }
    
    var accept: String? {
        set {
            hookDelegate.accept = newValue
        }
        get {
            return hookDelegate.accept
        }
    }
    
    private var hookDelegate: TextFieldDelegateProxy {
        if let _hookDelegate = objc_getAssociatedObject(self, &AssociatedKeys.delegate) as? TextFieldDelegateProxy {
            return _hookDelegate
        } else {
            let _hookDelegate = TextFieldDelegateProxy()
            objc_setAssociatedObject(self, &AssociatedKeys.delegate, _hookDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.delegate = _hookDelegate
            return _hookDelegate
        }
    }
}

extension String {
    func range(from range: NSRange) -> any RangeExpression<String.Index> {
        if range.location >= count {
            return endIndex...
        }
        if range.location + range.length >= count {
            return index(startIndex, offsetBy: range.location)...endIndex
        }
        return index(startIndex, offsetBy: range.location)...index(
            startIndex,
            offsetBy: range.location + range.length
        )
    }
}

private class TextFieldDelegateProxy: NSObject, UITextFieldDelegate {
    
    var maxLength: Int?
    var accept: String?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !lengthLimitingTextInputFormatter(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return false
        }
        if !acceptTextInputFormatter(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return false
        }
        return true
    }
    
    func lengthLimitingTextInputFormatter(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let length = maxLength else { return true }
        if string.isEmpty {
            return true
        }
        
        if string.count >= length {
            return false
        }
        
        guard let currText = textField.text else { return true }
        return currText
            .replacingCharacters(
                in: currText.range(from: range),
                with: string
            ).count > length
    }
    
    func acceptTextInputFormatter(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let _accept = accept else { return true }
        if string.isEmpty {
            return true
        }
        do {
            let regx = try NSRegularExpression(pattern: _accept)
            if regx.firstMatch(in: string, options: [], range: NSRange(string.startIndex..., in: string)) == nil {
                return false
            }
        } catch {
            return true
        }
        return true
    }
}

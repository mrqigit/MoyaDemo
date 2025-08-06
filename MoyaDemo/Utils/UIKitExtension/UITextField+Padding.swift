//
//  UITextField+Padding.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/6.
//

import UIKit
import ObjectiveC

// 动态子类的前缀
private let dynamicSubclassPrefix = "DynamicPaddingTextField_"

// 存储内边距的关联对象Key
private var paddingKey: UInt8 = 0
// 存储原始方法实现的关联对象Key
private var originalTextRectKey: UInt8 = 0

enum PaddingEdge {
    case none
    case left(space: CGFloat = 0)
    case right(space: CGFloat = 0)
    case top(space: CGFloat = 0)
    case bottom(space: CGFloat = 0)
    case horizontal(space: CGFloat = 0)
    case vertical(space: CGFloat = 0)
    case symmetric(horizontal: CGFloat = 0, vertical: CGFloat = 0)
    case all(space: CGFloat = 0)
    
    var edge: UIEdgeInsets {
        switch self {
        case .none:
            return .zero
        case .left(let space):
            return .init(top: 0, left: space, bottom: 0, right: 0)
        case .right(let space):
            return .init(top: 0, left: 0, bottom: 0, right: space)
        case .top(let space):
            return .init(top: space, left: 0, bottom: 0, right: 0)
        case .bottom(let space):
            return .init(top: 0, left: 0, bottom: space, right: 0)
        case .horizontal(let space):
            return .init(top: 0, left: space, bottom: 0, right: space)
        case .vertical(let space):
            return .init(top: space, left: 0, bottom: space, right: 0)
        case .all(let space):
            return .init(top: space, left: space, bottom: space, right: space)
        case .symmetric(horizontal: let horizontal, vertical: let vertical):
            return .init(
                top: vertical,
                left: horizontal,
                bottom: vertical,
                right: horizontal
            )
        }
    }
}

extension UITextField {
    /// 为当前UITextField实例添加内边距，通过动态子类实现
    /// - Parameter padding: 内边距
    func addDynamicPadding(padding: PaddingEdge) {
        // 1. 为当前实例创建唯一的动态子类
        let dynamicSubclass: AnyClass = createDynamicSubclass()
        
        // 2. 修改当前实例的isa指针指向动态子类
        object_setClass(self, dynamicSubclass)
        
        // 3. 存储内边距
        objc_setAssociatedObject(
            self,
            &paddingKey,
            padding,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
    
    /// 创建动态子类
    private func createDynamicSubclass() -> AnyClass {
        // 生成唯一的类名
        let className = "\(dynamicSubclassPrefix)\(Unmanaged.passUnretained(self).toOpaque())"
        let classPtr: AnyClass? = objc_allocateClassPair(
            UITextField.self,
            className,
            0
        )
        
        guard let newClass = classPtr else {
            fatalError("无法创建动态子类")
        }
        
        // 2. 替换需要重写的方法
        replaceMethod(in: newClass,
                      originalSelector: #selector(textRect(forBounds:)),
                      swizzledSelector: #selector(dynamic_textRect(forBounds:)))
        
        replaceMethod(
in: newClass,
                      originalSelector: #selector(editingRect(forBounds:)),
swizzledSelector: #selector(
    dynamic_editingRect(forBounds:)
)
        )
        
        replaceMethod(
in: newClass,
                      originalSelector: #selector(placeholderRect(forBounds:)),
swizzledSelector: #selector(
    dynamic_placeholderRect(forBounds:)
)
        )
        
        // 3. 注册动态类
        objc_registerClassPair(newClass)
        
        return newClass
    }
    
    /// 替换方法实现
    private func replaceMethod(
        in cls: AnyClass,
        originalSelector: Selector,
        swizzledSelector: Selector
    ) {
        guard let originalMethod = class_getInstanceMethod(
            UITextField.self,
            originalSelector
        ),
              let swizzledMethod = class_getInstanceMethod(type(of: self), swizzledSelector) else {
            return
        }
            
        // 保存原始方法实现，用于后续调用
        let originalImpl = method_getImplementation(originalMethod)
        objc_setAssociatedObject(
            self,
            &originalTextRectKey,
            originalImpl,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
            
        // 替换方法
        class_replaceMethod(
            cls,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )
    }
}

// MARK: - 动态子类的方法实现
extension UITextField {
    /// 动态子类的文本区域计算
    @objc private func dynamic_textRect(forBounds bounds: CGRect) -> CGRect {
        // 1. 获取原始方法实现并调用
        if let originalImpl = objc_getAssociatedObject(self, &originalTextRectKey) as? IMP {
            // 构造函数指针类型
            typealias FuncType = @convention(c) (
                AnyObject,
                Selector,
                CGRect
            ) -> CGRect
            let originalFunc = unsafeBitCast(originalImpl, to: FuncType.self)
            // 调用原始实现
            let originalRect = originalFunc(
                self,
                #selector(textRect(forBounds:)),
                bounds
            )
                
            // 2. 应用内边距
            if let padding = objc_getAssociatedObject(self, &paddingKey) as? PaddingEdge {
                return originalRect.inset(by: padding.edge)
            }
            return originalRect
        }
            
        //  fallback：如果获取原始方法失败，返回默认值
        return bounds
    }
    
    /// 动态子类的编辑状态文本区域计算
    @objc private func dynamic_editingRect(forBounds bounds: CGRect) -> CGRect {
        // 实现方式与dynamic_textRect相同
        if let originalImpl = objc_getAssociatedObject(self, &originalTextRectKey) as? IMP {
            typealias FuncType = @convention(c) (
                AnyObject,
                Selector,
                CGRect
            ) -> CGRect
            let originalFunc = unsafeBitCast(originalImpl, to: FuncType.self)
            let originalRect = originalFunc(
                self,
                #selector(editingRect(forBounds:)),
                bounds
            )
                
            if let padding = objc_getAssociatedObject(self, &paddingKey) as? PaddingEdge {
                return originalRect.inset(by: padding.edge)
            }
            return originalRect
        }
        return bounds
    }
    
    /// 动态子类的占位符区域计算
    @objc private func dynamic_placeholderRect(forBounds bounds: CGRect) -> CGRect {
        // 实现方式与dynamic_textRect相同
        if let originalImpl = objc_getAssociatedObject(self, &originalTextRectKey) as? IMP {
            typealias FuncType = @convention(c) (
                AnyObject,
                Selector,
                CGRect
            ) -> CGRect
            let originalFunc = unsafeBitCast(originalImpl, to: FuncType.self)
            let originalRect = originalFunc(
                self,
                #selector(editingRect(forBounds:)),
                bounds
            )
            
            if let padding = objc_getAssociatedObject(self, &paddingKey) as? PaddingEdge {
                return originalRect.inset(by: padding.edge)
            }
            return originalRect
        }
        return bounds
    }
}


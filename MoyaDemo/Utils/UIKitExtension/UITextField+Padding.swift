//
//  UITextField+Padding.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/6.
//

import UIKit
import ObjectiveC

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
        
        // 通用bunds修改方法
        let newFunc: @convention(block) (AnyObject, CGRect) -> CGRect = { (
            selfInstance,
            bound
        ) in
            return bound.inset(by: padding.edge)
        }
        
        // 定义KVO观察方法的实现
        let kvoImpl: @convention(block) (AnyObject, String?, Any?, [NSKeyValueChangeKey: Any]?, UnsafeMutableRawPointer?) -> Void = {
            (observer, keyPath, object, change, context) in
            super.observeValue(forKeyPath: keyPath, of: context, change: change, context: context)
        }
        
        // 1. 为当前实例创建唯一的动态子类并添加方法
        let dynamicSubclass: AnyClass = dynamicCreateSubClass(
            className: "\(type(of: self))",
            instanceMethods: [
                MethodInfo(
                    selector: #selector(borderRect(forBounds:)),
                    imp: imp_implementationWithBlock(newFunc)
                ),
                MethodInfo(
                    selector: #selector(textRect(forBounds:)),
                    imp: imp_implementationWithBlock(newFunc)
                ),
                MethodInfo(
                    selector: #selector(placeholderRect(forBounds:)),
                    imp: imp_implementationWithBlock(newFunc)
                ),
                MethodInfo(
                    selector: #selector(editingRect(forBounds:)),
                    imp: imp_implementationWithBlock(newFunc)
                ),
                MethodInfo(
                    selector: #selector(
                        UIView.observeValue(forKeyPath:of:change:context:)
                    ),
                    imp: imp_implementationWithBlock(kvoImpl)
                )
            ]
        )
        
        // 2. 修改当前实例的isa指针指向动态子类
        object_setClass(self, dynamicSubclass)
    }
}

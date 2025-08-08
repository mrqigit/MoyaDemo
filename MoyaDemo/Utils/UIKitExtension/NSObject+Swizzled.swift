//
//  NSObject+Swizzled.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/7.
//

import UIKit

/// 类前缀
private let _dynamicNSObjectSubClassPrefixStr = "DynamicNSObjectSubClass_"

/// 方法添加模型
public struct MethodInfo {
    var selector: Selector
    var imp: IMP
}

extension NSObject {
    
    /// 判断实例方法是否存在
    public func hasInstanceMethod(targetClass: AnyClass, with selector: Selector) -> Bool {
        return class_getInstanceMethod(targetClass, selector) != nil
    }
    
    /// 判断类方法是否存在
    public func hasClassMethod(targetClass: AnyClass, with selector: Selector) -> Bool {
        return class_getClassMethod(targetClass, selector) != nil
    }
    
    /// 判断实例方法是否被替换
    public func isInstanceMethodSwizzled(targetClass: AnyClass, with selector: Selector) -> Bool {
        guard let originalMethod = class_getInstanceMethod(targetClass, selector), let swizzledMethod = class_getInstanceMethod(targetClass, selector) else { return false }
        let originalImp = method_getImplementation(originalMethod)
        let swizzledImp = method_getImplementation(swizzledMethod)
        return originalImp != swizzledImp
    }
    
    /// 判断类方法是否被替换
    public func isClassMethodSwizzled(targetClass: AnyClass, with selector: Selector) -> Bool {
        guard let originalMethod = class_getClassMethod(targetClass, selector), let swizzledMethod = class_getClassMethod(targetClass, selector) else {
            return false
        }
        
        let originalImp = method_getImplementation(originalMethod)
        let swizzledImp = method_getImplementation(swizzledMethod)
        return originalImp != swizzledImp
    }
    
    /// 创建动态子类并添加方法
    public func dynamicCreateSubClass(className: String, classMethods: [MethodInfo] = [], instanceMethods: [MethodInfo] = []) -> AnyClass {
        let subClassName = "\(_dynamicNSObjectSubClassPrefixStr)\(className)"
        // 检查类是否存在
        if let subClass = NSClassFromString(subClassName) {
            return subClass
        }
        
        // 注册子类
        let newSubClass: AnyClass? = objc_allocateClassPair(type(of: self), subClassName, 0)
        
        if newSubClass == nil {
            fatalError("创建子类失败")
        }
        
        if classMethods.count > 0 {
            let _ = classMethods.map { dynamicAddClassMethod(targetClass: newSubClass!, methodInfo: $0) }
        }
        
        if instanceMethods.count > 0 {
            let _ = instanceMethods.map { dynamicAddInstanceMethod(targetClass: newSubClass!, methodInfo: $0) }
        }
        
        objc_registerClassPair(newSubClass!)
        
        return newSubClass!
    }
    
    /// 动态添加实例方法
    public func dynamicAddInstanceMethod(targetClass: AnyClass, methodInfo: MethodInfo) -> Bool {
        
        // 获取方法
        guard let newMethod = class_getInstanceMethod(targetClass, methodInfo.selector) else {
            return false
        }
        
        return class_addMethod(targetClass, methodInfo.selector, methodInfo.imp, method_getTypeEncoding(newMethod))
    }
    
    public func dynamicAddClassMethod(targetClass: AnyClass, methodInfo: MethodInfo) -> Bool {
        // 获取方法
        guard let newMethod = class_getClassMethod(targetClass, methodInfo.selector) else {
            return false
        }
        
        return class_addMethod(targetClass, methodInfo.selector, methodInfo.imp, method_getTypeEncoding(newMethod))
    }
}

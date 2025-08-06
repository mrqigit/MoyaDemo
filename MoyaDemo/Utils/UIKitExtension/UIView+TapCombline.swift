//
//  UIView+TapCombline.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/6.
//

import UIKit
import Combine

extension UIView {
    /// 创建点击事件的Publisher
    func tapPublisher() -> AnyPublisher<Void, Never> {
        let publisher = PassthroughSubject<Void, Never>()
        
        // 创建手势识别器
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapHandler(_:)))
        
        // 存储publisher和手势的关联
        let wrapper = TapGestureWrapper(subject: publisher, gesture: tapGesture)
        objc_setAssociatedObject(self,
                               &tapGestureKey,
                               wrapper,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // 添加手势并启用用户交互
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        return publisher.eraseToAnyPublisher()
    }
    
    @objc private func tapHandler(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        if let wrapper = objc_getAssociatedObject(self, &tapGestureKey) as? TapGestureWrapper {
            wrapper.subject.send()
        }
    }
}

// 用于存储关联对象的类
private class TapGestureWrapper {
    let subject: PassthroughSubject<Void, Never>
    let gesture: UITapGestureRecognizer
    
    init(subject: PassthroughSubject<Void, Never>, gesture: UITapGestureRecognizer) {
        self.subject = subject
        self.gesture = gesture
    }
}

// 关联对象的key
private var tapGestureKey: UInt8 = 0

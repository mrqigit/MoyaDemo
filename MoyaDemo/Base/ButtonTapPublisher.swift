//
//  ButtonTapPublisher.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import Combine

class ButtonTapPublisher: Publisher {
    
    typealias Output = UIButton
    typealias Failure = Never
    
    private let button: UIButton
    private let event: UIControl.Event
    
    init(button: UIButton, event: UIControl.Event) {
        self.button = button
        self.event = event
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, UIButton == S.Input {
        let subscription = ButtonTapSubscription(subscriber: subscriber, button: button, event: event)
        subscriber.receive(subscription: subscription)
    }
}

class ButtonTapSubscription<S: Subscriber>: Subscription where S.Input == UIButton, S.Failure == Never {
    private var subscriber: S?
    private weak var button: UIButton?
    private let event: UIControl.Event
    
    init(subscriber: S, button: UIButton, event: UIControl.Event) {
        self.subscriber = subscriber
        self.button = button
        self.event = event
        
        button.addTarget(self, action: #selector(handleTap), for: event)
    }
    
    @objc private func handleTap(_ sender: UIButton) {
        _ = subscriber?.receive(sender)
    }
    
    func request(_ demand: Subscribers.Demand) {
        
    }
    
    func cancel() {
        subscriber = nil
        button?.removeTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
}

extension UIButton {
    func tapPublisher(for event: UIControl.Event = .touchUpInside) -> ButtonTapPublisher {
        return ButtonTapPublisher(button: self, event: event)
    }
}

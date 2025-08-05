//
//  BaseViewModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit
import Combine

class BaseViewModel: ObservableObject {
    
    @Published var state: ViewState = .idle
    @Published var alertMessage: String?
    
    // 用于管理所有订阅，自动取消防止内容泄漏
    var cancellables = Set<AnyCancellable>()
    
    // 处理错误的通用方法
    func handleError(_ error: Error) {
        state = .error(error)
        alertMessage = error.localizedDescription
    }
    
    // 简化订阅存储
    func store(_ cancellable: AnyCancellable) {
        cancellable.store(in: &cancellables)
    }
    
    // 延迟发布的工具方法
    func delayPublish<T, E: Error>(_ publisher: AnyPublisher<T, E>, after delay: TimeInterval) -> AnyPublisher<T, E> {
        return Future<T, E> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                publisher.sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: { value in
                    promise(.success(value))
                }
                .store(in: &self.cancellables)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

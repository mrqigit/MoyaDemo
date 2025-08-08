//
//  LoginViewModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import Combine

class LoginViewModel: BaseViewModel {
    
    // 导航事件
    var navigationEvent = PassthroughSubject<LoginNavigationEvent, Never>()
    
    // 登录服务
    private let loginService: LoginServiceProtocol
    
    init(service: LoginServiceProtocol = LoginService()) {
        self.loginService = service
        super.init()
    }
    
    func registerAction() {
        navigationEvent.send(.register)
    }
}

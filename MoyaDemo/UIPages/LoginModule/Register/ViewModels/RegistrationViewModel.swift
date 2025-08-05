//
//  RegistrationViewModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit
import Combine

class RegistrationViewModel: BaseViewModel {
    
    // 表单内容
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPass: String = ""
    
    // 视图状态
    @Published var isRegisterButtonEnabled: Bool = false
    @Published var registationResponse: RegistrationResponse?
    
    // 导航事件
    let navigationEvent = PassthroughSubject<RegistrationNavigationEvent, Never>()
    
    // 服务
    private let validationService = RegistrationValidationService()
    private let registrationService: RegistrationServiceProtocol
    private var validationCancellable: AnyCancellable?
    
    // 初始化
    init(
        registrationService: RegistrationServiceProtocol = RegistrationService()
    ) {
        self.registrationService = registrationService
        super.init()
        setupFormValidation()
    }
    
    // 设置表单验证
    private func setupFormValidation() {
        // 监听所有字段变化，实时验证表单
        validationCancellable = Publishers
            .CombineLatest4($userName, $email, $password, $confirmPass)
        // 防抖
            .debounce(for: 0.3, scheduler: RunLoop.main)
        // 校验表单
            .map{ [weak self] (username, email, password, confirmPass) in
                guard let self = self else { return false }
                
                let form = RegistrationForm(
                    userName: username,
                    email: email,
                    password: password,
                    confirmPass: confirmPass
                )
                
                do {
                    try self.validationService.validateForm(form)
                    return true
                } catch {
                    handleError(error)
                    return false
                }
            }
            .assign(to: \.isRegisterButtonEnabled, on: self)
    }
    
    // 执行注册
    func preformRegistration() {
        let form = RegistrationForm(
            userName: userName,
            email: email,
            password: password,
            confirmPass: confirmPass
        )
        
        // 客户端验证
        do {
            try validationService.validateForm(form)
            
            state = .loading
            
            // 发起注册请求
            delayPublish(registrationService.registerUser(with: form), after: 2)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    
                    switch completion {
                    case .failure(let error):
                        self.handleError(error)
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.registationResponse = response
                    self.state = .success
                    
                    // 注册成功后发送导航事件
                    if response.success {
                        self.navigationEvent.send(.registrationCompleted)
                    }
                }
                .store(in: &cancellables)
        } catch {
            handleError(error)
        }
    }
    
    // 取消注册
    func cancelRegistration() {
        navigationEvent.send(.cancel)
    }
}

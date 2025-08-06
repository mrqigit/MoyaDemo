//
//  ForgotViewModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import Combine


class ForgotViewModel: BaseViewModel {
    // 依赖注入 - 便于测试
    private let authService: ForgetServiceProtocol
    
    // 当前步骤
    private let _currentStep = CurrentValueSubject<ResetPasswordStep, Never>(
        .enterEmail
    )
    var currentStep: AnyPublisher<ResetPasswordStep, Never> {
        _currentStep.eraseToAnyPublisher()
    }
    
    // 输入数据
    @Published var email: String = ""
    @Published var verificationCode: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    
    private(set) var isEmailValid: AnyPublisher<Bool, Never>?
    private(set) var isVerificationCodeValid: AnyPublisher<Bool, Never>?
    private(set) var isPasswordValid: AnyPublisher<Bool, Never>?
    
    // 成功信号
    private let _resetSuccess = PassthroughSubject<Void, Never>()
    var resetSuccess: AnyPublisher<Void, Never> {
        _resetSuccess.eraseToAnyPublisher()
    }
    
    let navigationEvent = PassthroughSubject<ForgetNavigationEvent, Never>()
    
    // 初始化
    init(authService: ForgetServiceProtocol = ForgetService()) {
        self.authService = authService
        super.init()
        setupValidations()
    }
    
    // 验证逻辑
    private func setupValidations() {
        isEmailValid = $email.map({ email in
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", pattern)
                .evaluate(with: email)
        }).eraseToAnyPublisher()
        
        isVerificationCodeValid = $verificationCode
            .map { $0.count == 6}
            .eraseToAnyPublisher()
        
        let passStrength = $newPassword.map { password in
            // 密码至少8位，包含字母和数字
            let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
            return NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
                .evaluate(with: password)
        }
        
        let confirmPass = $confirmPassword.map { password in
            // 密码至少8位，包含字母和数字
            let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
            return NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
                .evaluate(with: password)
        }
        
        let match = Publishers.CombineLatest($newPassword, $confirmPassword).map { $0 == $1 }.eraseToAnyPublisher()
        
        isPasswordValid = Publishers
            .CombineLatest3(passStrength, confirmPass, match)
            .map { $0 && $1 && $2 }
            .eraseToAnyPublisher()
    }
    
    // 发送验证码
    func sendVerificationCode() {
        alertMessage = nil
        state = .loading
        
        authService.sendVerificationCode(for: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.alertMessage = error.errorDescription
                    self?.state = .error(error)
                }
            } receiveValue: { [weak self] _ in
                self?._currentStep.send(.enterVerificationCode)
                self?.state = .success
            }.store(in: &cancellables)
    }
    
    // 验证验证码
    func verifyCode() {
        alertMessage = nil
        state = .loading
        
        authService.verifyCode(code: verificationCode, for: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.alertMessage = error.errorDescription
                    self?.state = .error(error)
                }
            } receiveValue: { [weak self] _ in
                self?._currentStep.send(.setNewPassword)
                self?.state = .success
            }.store(in: &cancellables)
    }
    
    // 重置密码
    func resetPassword() {
        alertMessage = nil
        state = .loading
        
        let request = ResetPasswordRequest(
            email: email,
            verificationCode: verificationCode,
            newPassword: newPassword
        )
        
        authService
            .resetPassword(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.alertMessage = error.errorDescription
                    self?.state = .error(error)
                }
            } receiveValue: { [weak self] _ in
                self?._resetSuccess.send()
                self?.state = .success
            }.store(in: &cancellables)
    }
    
    // 返回上一步
    func goBack() {
        switch _currentStep.value {
        case .enterVerificationCode:
            _currentStep.send(.enterEmail)
        case .setNewPassword:
            _currentStep.send(.enterVerificationCode)
        case .enterEmail:
            break // 已经是第一步，不做处理
        }
    }
    
    func nextTap() {
        switch _currentStep.value {
        case .enterEmail:
            sendVerificationCode()
        case .enterVerificationCode:
            verifyCode()
        case .setNewPassword:
            resetPassword()
        }
    }
    
    // 错误信息转换
    private func errorMessage(for error: ForgetError) -> String {
        return error.errorDescription ?? "未知错误"
    }
}


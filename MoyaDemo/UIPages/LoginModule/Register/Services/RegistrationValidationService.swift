//
//  RegistrationValidationService.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit
import Combine

// 注册服务协议
protocol RegistrationServiceProtocol {
    func registerUser(with form: RegistrationForm) -> AnyPublisher<RegistrationResponse, Error>
}

// 注册服务实现
class RegistrationService: RegistrationServiceProtocol {
    func registerUser(with form: RegistrationForm) -> AnyPublisher<RegistrationResponse, any Error> {
        return Future<RegistrationResponse, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                let success = Bool.random()
                
                if success {
                    promise(.success(RegistrationResponse(success: true, message: "注册成功，欢迎加入!", userId: UUID().uuidString)))
                } else {
                    promise(.failure(RegistrationError.registrationFaild("用户名已存在")))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// 注册验证服务
class RegistrationValidationService {
    func validateForm(_ form: RegistrationForm) throws {
        if form.userName.isEmpty {
            throw RegistrationError.emptyUserName
        }
        
        if !isValidEmail(form.email) {
            throw RegistrationError.invalidEmail
        }
        
        if form.password.count < 6 {
            throw RegistrationError.passwordTooShort
        }
        
        if form.password != form.confirmPass {
            throw RegistrationError.passwordDontMatch
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

//
//  ForgetService.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import Foundation
import Combine

protocol ForgetServiceProtocol {
    func sendVerificationCode(for email: String) -> AnyPublisher<Bool, ForgetError>
    func verifyCode(code: String, for email: String) -> AnyPublisher<Bool, ForgetError>
    func resetPassword(request: ResetPasswordRequest) -> AnyPublisher<Bool, ForgetError>
}

class ForgetService: ForgetServiceProtocol {
    func sendVerificationCode(for email: String) -> AnyPublisher<Bool, ForgetError> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if email.contains("@") && email.contains(".") {
                    promise(.success(true))
                } else {
                    promise(.failure(.invalidEmail))
                }
            }
        }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func verifyCode(code: String, for email: String) -> AnyPublisher<Bool, ForgetError> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if code.count == 6 {
                    promise(.success(true))
                } else {
                    promise(.failure(.invalidVerificationCode))
                }
            }
        }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func resetPassword(request: ResetPasswordRequest) -> AnyPublisher<Bool, ForgetError> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if request.newPassword.count >= 6 {
                    promise(.success(true))
                } else {
                    promise(.failure(.passwordTooShort))
                }
            }
        }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}

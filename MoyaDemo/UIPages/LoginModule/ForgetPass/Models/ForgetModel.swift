//
//  ForgetModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import Foundation

/// 密码重置流程
enum ResetPasswordStep {
    case enterEmail
    case enterVerificationCode
    case setNewPassword
}

/// 密码重置请求参数
struct ResetPasswordRequest {
    let email: String
    let verificationCode: String
    let newPassword: String
}

/// 错误类型
enum ForgetError: Error, LocalizedError {
    
    case invalidEmail
    case invalidVerificationCode
    case passwordTooShort
    case passwordsNotMatching
    case networkError
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "请输入有效的邮箱地址"
        case .invalidVerificationCode:
            return "验证码无效或已过期"
        case .passwordTooShort:
            return "密码长度不能少于6位"
        case .passwordsNotMatching:
            return "两次输入的密码不一致"
        case .networkError:
            return "网络连接错误，请检查网络"
        case .serverError(let message):
            return message
        }
    }
    
    var localizedDescription: String? { errorDescription }
}

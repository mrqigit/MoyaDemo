//
//  RegistrationModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit

// 注册表单数据模型
struct RegistrationForm {
    var userName: String
    var email: String
    var password: String
    var confirmPass: String
}

// 服务器返回的注册响应模型
class RegistrationResponse: BaseModel {
    let userId: String?
    
    init(success: Bool, message: String?, userId: String?) {
        self.userId = userId
        super.init(success: success,message:message)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: RegistrationCodingKeys.self
        )
        userId = try container.decode(String.self, forKey: .userId)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: RegistrationCodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try super.encode(to: encoder)
    }
}

enum RegistrationCodingKeys: String, CodingKeysProtocol {
    case userId
}

// 注册错误类型
enum RegistrationError: Error, LocalizedError {
    case emptyUserName
    case invalidEmail
    case passwordTooShort
    case passwordDontMatch
    case registrationFaild(String)
    
    var localizedDescription: String? { errorDescription }
    
    var errorDescription: String? {
        switch self {
        case .emptyUserName:
            return "用户名不能为空"
        case .invalidEmail:
            return "请输入有效的邮箱地址"
        case .passwordTooShort:
            return "密码长度不能少于6位"
        case .passwordDontMatch:
            return "两次密码不一致"
        case .registrationFaild(let message):
            return "注册失败: \(message)"
        }
    }
}

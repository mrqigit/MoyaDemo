//
//  BaseModel.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit

class BaseModel: Identifiable, Codable, Equatable {
    
    let id: UUID
    let success: Bool
    let message: String?
    
    init(success: Bool, message: String?) {
        self.id = UUID()
        self.success = success
        self.message = message
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseCodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decode(String.self, forKey: .message)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: BaseCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(success, forKey: .success)
        try container.encode(message, forKey: .message)
    }
    
    static func == (lhs: BaseModel, rhs: BaseModel) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol CodingKeysProtocol: CodingKey {}

enum BaseCodingKeys: String, CodingKeysProtocol {
    case id, success, message
}

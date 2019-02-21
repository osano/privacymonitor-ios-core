//
//  ServiceError.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/9/19.
//  Copyright © 2019 Osano. All rights reserved.
//

import Foundation

struct ServiceError: Decodable {

    let status: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case status
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try container.decode(String.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)
    }
}

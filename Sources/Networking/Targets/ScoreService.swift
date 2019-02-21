//
//  ScoreService.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/9/19.
//  Copyright © 2019 Osano. All rights reserved.
//

import Foundation
import Moya

enum ScoreService {

    case getScore(query: String, previousScore: Int?)
}

extension ScoreService: TargetType {

    var baseURL: URL {
        return URL(string: Configs.Network.baseDomain)!
    }

    var path: String {
        return "score"
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case let .getScore(query, previousScore):
            var parameters = [String: String]()

            if let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                parameters["q"] = query
            }

            if let previousScore = previousScore {
                parameters["p"] = String(previousScore)
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

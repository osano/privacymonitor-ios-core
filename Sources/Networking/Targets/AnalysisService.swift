//
//  AnalysisService.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/28/19.
//

import Foundation
import Moya

enum AnalysisService {

    case requestScoreAnalysis(domain: String)
}

extension AnalysisService: TargetType {

    var baseURL: URL {
        return URL(string: Configs.Network.baseDomain)!
    }

    var path: String {
        return "analysis"
    }

    var method: Moya.Method {
        return .post
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case let .requestScoreAnalysis(domain):
            return .requestParameters(parameters: ["domain": domain], encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

//
//  NetworkManager.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/9/19.
//  Copyright © 2019 Osano. All rights reserved.
//

import Foundation
import Moya
import Result

public enum NetworkError: Error {
    case unknownError
    case invalidRequest
    case notFound
    case timeOut
    case serverError
    case decodingError
}

struct NetworkAdapter {

    static let provider = MoyaProvider<ScoreService>()
    static let analysisProvider = MoyaProvider<AnalysisService>()

    static func fetchScore(query: String, previousScore: Int? = nil, completion: @escaping (Result<Domain, NetworkError>) -> Void) {
        provider.request(.getScore(query: query, previousScore: previousScore)) { result in
            switch result {
            case let .success(response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    var domain = try JSONDecoder().decode(Domain.self, from: response.data)
                    domain.rootDomain = query
                    completion(.success(domain))
                }
                catch {
                    if let moyaError = error as? MoyaError,
                        let response = moyaError.response {
                        completion(.failure(errorFromStatusCode(response.statusCode)))
                    }
                    else {
                        completion(.failure(.decodingError))
                    }
                }
            case .failure(_):
                completion(.failure(.unknownError))
            }
        }
    }

    static func requestScoreAnalysis(domain: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        analysisProvider.request(.requestScoreAnalysis(domain: domain)) { result in
            switch result {
            case let .success(response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    completion(.success(true))
                }
                catch {
                    if let moyaError = error as? MoyaError,
                        let response = moyaError.response {
                        completion(.failure(errorFromStatusCode(response.statusCode)))
                    }
                    else {
                        completion(.failure(.decodingError))
                    }
                }
            case .failure(_):
                completion(.failure(.unknownError))
            }
        }
    }

    static func errorFromStatusCode(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400:
            return .invalidRequest
        case 404:
            return .notFound
        case 500...599:
            return .serverError
        default:
            return .unknownError
        }
    }

}

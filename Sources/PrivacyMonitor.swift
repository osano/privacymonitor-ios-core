//
//  PrivacyMonitor.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/13/19.
//

import CleanroomLogger
import Foundation
import Result

public enum PrivacyMonitorError: Error {
    case invalidURL
    case domainDoesNotExist
    case databaseError
    case underlyingNetworkError(NetworkError)
}

public struct PrivacyMonitor {

    private let databaseManager: DatabaseManager

    public init(databaseManager: DatabaseManager = .init()) {
        Log.enable()
        self.databaseManager = databaseManager
    }

    public func requestDomainScore(withURL url: URL, visitedDate: Date = .init(), completion: @escaping (Result<Domain, PrivacyMonitorError>) -> Void) {
        guard let rootDomain = url.rootDomain else {
            completion(.failure(.invalidURL))
            return
        }

        // Check if domain exists locally
        if let domain = databaseManager.retrieve(with: rootDomain) {
            // Request domain info from API.
            NetworkAdapter.fetchScore(query: rootDomain, previousScore: domain.score) { result in
                switch result {
                case let .success(domain):
                    // Domain found, update score in the local database.
                    if self.databaseManager.update(rootDomain: rootDomain,
                                                   score: domain.score,
                                                   previousScore: domain.previousScore,
                                                   lastVisitedDate: visitedDate),
                        let domain = self.databaseManager.retrieve(with: rootDomain) {
                        completion(.success(domain))
                    }
                    else {
                        Log.error?.message("Error updating \(domain) in local storage")
                        completion(.failure(.databaseError))
                    }

                case let .failure(error):
                    // Domain not found or network error
                    switch error {
                    case .notFound:
                        completion(.failure(.domainDoesNotExist))
                    default:
                        completion(.failure(.underlyingNetworkError(error)))
                    }
                }
            }
        }
        else {
            // Domain not available from local storage, fetch from API and store.
            NetworkAdapter.fetchScore(query: rootDomain) { result in
                switch result {
                case let .success(domain):
                    // Domain found, store it in the local database.
                    if self.databaseManager.storeDomain(domain),
                        let domain = self.databaseManager.retrieve(with: rootDomain) {
                        completion(.success(domain))
                    }
                    else {
                        Log.error?.message("Error storing \(domain) in local storage")
                        completion(.failure(.databaseError))
                    }

                case let .failure(error):
                    // Domain not found or network error
                    switch error {
                    case .notFound:
                        completion(.failure(.domainDoesNotExist))
                    default:
                        completion(.failure(.underlyingNetworkError(error)))
                    }
                }
            }
        }
    }

    public func registerDomainVisit(withURL url: URL, visitedDate: Date = .init(), completion: @escaping (Result<Domain, PrivacyMonitorError>) -> Void) {
        guard let rootDomain = url.rootDomain else {
            completion(.failure(.invalidURL))
            return
        }

        // Check if domain exists locally
        if let domain = databaseManager.retrieve(with: rootDomain) {

            // Domain available from local storage, check last visited date (>29 days) or score 0
            if let lastVisited = domain.lastVisited,
                let daysFromNow = visitedDate.daysFromDate(lastVisited),
                daysFromNow > 29 || domain.score == 0 {

                // Request domain info from API.
                NetworkAdapter.fetchScore(query: rootDomain, previousScore: domain.score) { result in
                    switch result {
                    case let .success(domain):
                        // Domain found, update score in the local database.
                        if self.databaseManager.update(rootDomain: rootDomain,
                                                       score: domain.score,
                                                       previousScore: domain.previousScore,
                                                       lastVisitedDate: visitedDate),
                            let domain = self.databaseManager.retrieve(with: rootDomain) {
                            completion(.success(domain))
                        }
                        else {
                            Log.error?.message("Error updating \(domain) in local storage")
                            completion(.failure(.databaseError))
                        }

                    case let .failure(error):
                        // Domain not found or network error
                        switch error {
                        case .notFound:
                            completion(.failure(.domainDoesNotExist))
                        default:
                            completion(.failure(.underlyingNetworkError(error)))
                        }
                    }
                }
            }
            else {
                // Domain recently visited, let's update its last visited date.
                if !databaseManager.update(rootDomain: rootDomain, lastVisitedDate: visitedDate) {
                    Log.error?.message("Error updating \(domain) in local storage")
                }
            }
        }
        else {
            // Domain not available from local storage, fetch from API and store.
            NetworkAdapter.fetchScore(query: rootDomain) { result in
                switch result {
                case let .success(domain):
                    // Domain found, store it in the local database.
                    if self.databaseManager.storeDomain(domain),
                        let domain = self.databaseManager.retrieve(with: rootDomain) {
                        completion(.success(domain))
                    }
                    else {
                        Log.error?.message("Error storing \(domain) in local storage")
                        completion(.failure(.databaseError))
                    }

                case let .failure(error):
                    // Domain not found or network error
                    switch error {
                    case .notFound:
                        completion(.failure(.domainDoesNotExist))
                    default:
                        completion(.failure(.underlyingNetworkError(error)))
                    }
                }
            }
        }
    }

    public func requestScoreAnalysis(withURL url: URL, completion: @escaping (Result<Bool, PrivacyMonitorError>) -> Void) {
        guard let rootDomain = url.rootDomain else {
            completion(.failure(.invalidURL))
            return
        }

        NetworkAdapter.requestScoreAnalysis(domain: rootDomain) { result in
            switch result {
            case let .success(success):
                completion(.success(success))
            case let .failure(error):
                Log.error?.message("Error requesting score analysis for domain: \(rootDomain)")
                completion(.failure(.underlyingNetworkError(error)))
            }
        }
    }
}

//
//  Domain.swift
//  PrivacyMonitor
//
//  Created by Christian Roman on 1/9/19.
//  Copyright © 2019 Osano. All rights reserved.
//

import Foundation

public struct Domain: Decodable {
    public var rootDomain: String?
    public var score: Int = 0
    public var previousScore: Int = 0
    public var lastVisited: Date?

    public var name: String?
    public var domains: [String]?

    enum CodingKeys: String, CodingKey {
        case name
        case domains
        case score
        case previousScore
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try? container.decode(String.self, forKey: .name)
        domains = try? container.decode([String].self, forKey: .domains)
        score = try container.decode(Int.self, forKey: .score)
        previousScore = try container.decodeIfPresent(Int.self, forKey: .previousScore) ?? 0
    }

    init(rootDomain: String, score: Int = 0, previousScore: Int = 0, lastVisited: Date? = nil) {
        self.rootDomain = rootDomain
        self.score = score
        self.previousScore = previousScore
        self.lastVisited = lastVisited
    }
}

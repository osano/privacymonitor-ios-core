//
//  URL+RootDomain.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/10/19.
//  Copyright © 2019 Osano. All rights reserved.
//

import Foundation

public extension URL {

    var rootDomain: String? {
        guard let host = host else { return nil }
        return host.rootDomain
    }
}

//
//  DatabaseTests.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/14/19.
//

import XCTest
import SQLite
@testable import PrivacyMonitorFramework

class DatabaseTests: XCTestCase {

    fileprivate let dbManager = DatabaseManager(location: .inMemory)
    fileprivate let domain = Domain(rootDomain: "youtube.com", score: 722)

    func testStoreRetrieveDomain() {
        XCTAssertTrue(dbManager.storeDomain(domain))

        let retrievedDomain = dbManager.retrieve(with: "youtube.com")

        XCTAssertEqual(retrievedDomain?.rootDomain, "youtube.com")
        XCTAssertEqual(retrievedDomain?.score, 722)
    }

    func testStoreRetrieveDomainWithDate() {
        let domain = Domain(rootDomain: "google.com", score: 100, lastVisited: Date(timeIntervalSince1970: 5000))

        XCTAssertTrue(dbManager.storeDomain(domain))

        let retrievedDomain = dbManager.retrieve(with: "google.com")

        XCTAssertEqual(retrievedDomain?.rootDomain, "google.com")
        XCTAssertEqual(retrievedDomain?.score, 100)
        XCTAssertEqual(retrievedDomain?.lastVisited, Date(timeIntervalSince1970: 5000))
    }

    func testDuplicateDomain() {
        let duplicate = Domain(rootDomain: "youtube.com", score: 722)
        let duplicateDifferent = Domain(rootDomain: "youtube.com", score: 999)

        XCTAssertTrue(dbManager.storeDomain(domain))
        XCTAssertFalse(dbManager.storeDomain(duplicate))
        XCTAssertFalse(dbManager.storeDomain(duplicateDifferent))
    }

    func testUpdateDomainScore() {
        XCTAssertTrue(dbManager.storeDomain(domain))

        XCTAssertTrue(dbManager.update(rootDomain: "youtube.com", score: 999))

        let retrievedDomain = dbManager.retrieve(with: "youtube.com")
        XCTAssertEqual(retrievedDomain?.score, 999)
    }

    func testDeleteDomain() {
        XCTAssertTrue(dbManager.storeDomain(domain))

        XCTAssertTrue(dbManager.delete(rootDomain: "youtube.com"))

        let retrievedDomain = dbManager.retrieve(with: "youtube.com")
        XCTAssertNil(retrievedDomain)
    }

    func testDeleteAll() {
        let domains = [Domain(rootDomain: "youtube.com", score: 299),
                       Domain(rootDomain: "youtu.be", score: 299),
                       Domain(rootDomain: "amazon.com", score: 350),
                       Domain(rootDomain: "amazon.co.uk", score: 351),
                       Domain(rootDomain: "google.com", score: 999)]

        for domain in domains {
            XCTAssertTrue(dbManager.storeDomain(domain))
        }

        XCTAssertEqual(dbManager.deleteAll(), domains.count)
    }
}

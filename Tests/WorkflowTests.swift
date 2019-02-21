//
//  WorkflowTests.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/14/19.
//

import XCTest
@testable import PrivacyMonitorFramework

class WorkflowTests: XCTestCase {

    fileprivate let dbManager = DatabaseManager(location: .inMemory)
    fileprivate var privacyMonitor: PrivacyMonitor?

    override func setUp() {
        super.setUp()

        privacyMonitor = PrivacyMonitor(databaseManager: dbManager)
    }

    func testManuallyURLVisit() {
        guard let url = URL(string: "https://youtube.com"),
            let privacyMonitor = privacyMonitor else {
                XCTFail()
                return
        }

        let expect = expectation(description: "Expect initial load and a patch to happen")

        privacyMonitor.requestDomainScore(withURL: url) { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.rootDomain, "youtube.com")
                XCTAssertEqual(domain.name, "YouTube")
                XCTAssertEqual(domain.score, 722)
                XCTAssertEqual(domain.previousScore, 755)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testBasicWorkflow() {
        guard let url = URL(string: "https://www.youtube.com") else {
            XCTFail()
            return
        }

        let expect = expectation(description: "Expect initial load and a patch to happen")

        privacyMonitor?.registerDomainVisit(withURL: url) { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.rootDomain, "youtube.com")
                XCTAssertEqual(domain.name, "YouTube")
                XCTAssertEqual(domain.score, 722)
                XCTAssertEqual(domain.previousScore, 755)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testWorkflowFromExistingDomain() {
        guard let url = URL(string: "https://www.youtube.com") else {
            XCTFail()
            return
        }

        var domain = Domain(rootDomain: "youtube.com", score: 500)
        domain.lastVisited = Date(timeIntervalSince1970: 5000)

        XCTAssertTrue(dbManager.storeDomain(domain))

        let expect = expectation(description: "Expect initial load and a patch to happen")
        expect.isInverted = true

        privacyMonitor?.registerDomainVisit(withURL: url, visitedDate: Date(timeIntervalSince1970: 5010)) { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.rootDomain, "youtube.com")
                XCTAssertEqual(domain.score, 500)
                XCTAssertEqual(domain.previousScore, 0)
                XCTAssertEqual(domain.lastVisited, Date(timeIntervalSince1970: 5010))

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testWorkflowFromExistingDomainMonthLater() {
        guard let url = URL(string: "https://www.youtube.com") else {
            XCTFail()
            return
        }

        let lastVisited = Date(timeIntervalSince1970: 5000)

        var domain = Domain(rootDomain: "youtube.com", score: 500)
        domain.lastVisited = lastVisited

        let monthLater = Calendar.current.date(byAdding: .month, value: 1, to: lastVisited)!

        XCTAssertTrue(dbManager.storeDomain(domain))

        let expect = expectation(description: "Expect initial load and a patch to happen")

        privacyMonitor?.registerDomainVisit(withURL: url, visitedDate: monthLater) { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.rootDomain, "youtube.com")
                XCTAssertEqual(domain.score, 722)
                XCTAssertEqual(domain.previousScore, 755)
                XCTAssertEqual(domain.lastVisited, monthLater)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testWorkflowFromExistingDomainMonthLaterNoDateParameter() {
        guard let url = URL(string: "https://www.youtube.com") else {
            XCTFail()
            return
        }

        let lastVisited = Calendar.current.date(byAdding: .month, value: -2, to: Date())!

        var domain = Domain(rootDomain: "youtube.com", score: 500)
        domain.lastVisited = lastVisited

        XCTAssertTrue(dbManager.storeDomain(domain))

        let expect = expectation(description: "Expect initial load and a patch to happen")

        privacyMonitor?.registerDomainVisit(withURL: url) { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.rootDomain, "youtube.com")
                XCTAssertEqual(domain.score, 722)
                XCTAssertEqual(domain.previousScore, 755)

                guard let domainLastVisited = domain.lastVisited else {
                    XCTFail()
                    return
                }

                XCTAssertGreaterThan(domainLastVisited, lastVisited)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }
}

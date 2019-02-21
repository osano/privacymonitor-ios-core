//
//  NetworkingTests.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/14/19.
//

import XCTest
@testable import PrivacyMonitorFramework

class NetworkingTests: XCTestCase {

    func testDomainParsing() {
        let expect = expectation(description: "Expect initial load and a patch to happen")

        NetworkAdapter.fetchScore(query: "youtube.com") { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.name, "YouTube")
                XCTAssertEqual(domain.domains, ["youtube.com", "youtu.be"])
                XCTAssertEqual(domain.previousScore, 755)
                XCTAssertEqual(domain.score, 722)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testDomainParsingWithPreviousScore() {
        let expect = expectation(description: "Expect initial load and a patch to happen")

        NetworkAdapter.fetchScore(query: "youtube.com", previousScore: 999) { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.name, "YouTube")
                XCTAssertEqual(domain.domains, ["youtube.com", "youtu.be"])
                XCTAssertEqual(domain.previousScore, 755)
                XCTAssertEqual(domain.score, 722)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testDomainParsingWithNoPreviousScore() {
        let expect = expectation(description: "Expect initial load and a patch to happen")

        NetworkAdapter.fetchScore(query: "webex.com") { result in
            switch result {
            case let .success(domain):
                XCTAssertNotNil(domain)
                XCTAssertEqual(domain.name, "Cisco Webex Teams")
                XCTAssertEqual(domain.score, 722)
                XCTAssertEqual(domain.previousScore, 0)

            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testDomainNotFound() {
        let expect = expectation(description: "Expect initial load and a patch to happen")

        NetworkAdapter.fetchScore(query: "facebook.com") { result in
            switch result {
            case .success(_):
                XCTFail()

            case let .failure(error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error, NetworkError.notFound)
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testInvalidRequest() {
        let expect = expectation(description: "Expect initial load and a patch to happen")

        NetworkAdapter.fetchScore(query: "") { result in
            switch result {
            case .success(_):
                XCTFail()

            case let .failure(error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error, NetworkError.invalidRequest)
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testRequestScoreAnalysis() {
        let expect = expectation(description: "Expect initial load and a patch to happen")

        NetworkAdapter.requestScoreAnalysis(domain: "microsoft.com") { result in
            switch result {
            case let .success(success):
                XCTAssertTrue(success)
            case .failure(_):
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 20.0, handler: nil)
    }

}

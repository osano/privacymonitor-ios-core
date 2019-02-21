//
//  RootDomainTests.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/14/19.
//

import XCTest
@testable import PrivacyMonitorFramework

class RootDomainTests: XCTestCase {

    func testRootDomainExtraction() {
        XCTAssertEqual("some.subdomain.google.co.uk".rootDomain, "google.co.uk")
        XCTAssertEqual("x.y.z.a.b.blog.osano.com".rootDomain, "osano.com")
        XCTAssertEqual("www.google.co.uk".rootDomain, "google.co.uk")
        XCTAssertEqual("google.co.uk".rootDomain, "google.co.uk")
        XCTAssertEqual("www.google.com".rootDomain, "google.com")
        XCTAssertEqual("amazon.co.uk".rootDomain, "amazon.co.uk")
        XCTAssertEqual("www.amazon.co.uk".rootDomain, "amazon.co.uk")
        XCTAssertEqual("www.youtube.com".rootDomain, "youtube.com")
        XCTAssertEqual("m.youtube.com".rootDomain, "youtube.com")
        XCTAssertEqual("youtube.com".rootDomain, "youtube.com")
        XCTAssertEqual("www.joomla.subdomain.php.net".rootDomain, "php.net")
        XCTAssertEqual("foo.bar.com".rootDomain, "bar.com")
        XCTAssertEqual("foo.ca".rootDomain, "foo.ca")
        XCTAssertEqual("foo.bar.ca".rootDomain, "bar.ca")
        XCTAssertEqual("foo.blogspot.com".rootDomain, "blogspot.com")
        XCTAssertEqual("foo.blogspot.co.uk".rootDomain, "blogspot.co.uk")
        XCTAssertEqual("foo.uk.com".rootDomain, "foo.uk.com")
        XCTAssertEqual("state.CA.us".rootDomain, "state.ca.us")
        XCTAssertEqual("www.state.pa.us".rootDomain, "state.pa.us")
        XCTAssertEqual("pvt.k12.ca.us".rootDomain, "k12.ca.us")
        XCTAssertEqual("www4.yahoo.co.uk".rootDomain, "yahoo.co.uk")
        XCTAssertEqual("home.netscape.com".rootDomain, "netscape.com")
        XCTAssertEqual("web.MIT.edu".rootDomain, "mit.edu")
        XCTAssertEqual("foo.eDu.au".rootDomain, "edu.au")
        XCTAssertEqual("utenti.blah.IT".rootDomain, "blah.it")
        XCTAssertEqual("dominio.com.co".rootDomain, "dominio.com.co")
        XCTAssertEqual("www.microsoft.com".rootDomain, "microsoft.com")
        XCTAssertEqual("msdn.microsoft.com".rootDomain, "microsoft.com")
    }

    func testRootDomainExtractionFromURL() {
        let url = URL(string: "https://www.youtube.com")

        XCTAssertEqual(url?.rootDomain, "youtube.com")
    }
}

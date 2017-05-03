import Foundation
import XCTest
import APIKit
import RxSwift
import RxBlocking
@testable import LicensePlistCore

class CarthageCollectorTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testCollect() {
        let carthage = Carthage(name: "NativePopup", owner: "mono0926")
        let license = try! CarthageLicense.collect(carthage).toBlocking().single()!
        XCTAssertEqual(license.library, carthage)
        XCTAssertTrue(license.body.hasPrefix("MIT License"))
        XCTAssertEqual(license.githubResponse.downloadUrl, URL(string: "https://raw.githubusercontent.com/mono0926/NativePopup/master/LICENSE"))
        XCTAssertEqual(license.githubResponse.kind.spdxId, "MIT")
    }

    func testCollect_forked() {
        let carthage = Carthage(name: "ios_sdk", owner: "gram30")
        let license = try! CarthageLicense.collect(carthage).toBlocking().single()!
        var forked = carthage
        forked.owner = "adjust"
        XCTAssertEqual(license.library, forked)
        XCTAssertTrue(license.body.hasPrefix("Copyright (c)"))
        XCTAssertEqual(license.githubResponse.downloadUrl, URL(string: "https://raw.githubusercontent.com/adjust/ios_sdk/master/MIT-LICENSE"))
        XCTAssertEqual(license.githubResponse.kind.spdxId, "MIT")
    }
    func testCollect_invalid() {
        let carthage = Carthage(name: "abcde", owner: "invalid")
        let license = try? CarthageLicense.collect(carthage).toBlocking().first()
        XCTAssertTrue(license == nil)
    }
}

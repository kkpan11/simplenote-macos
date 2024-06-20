import XCTest
@testable import Simplenote


// MARK: - MagicLinkAuthenticatorTests
//
final class MagicLinkAuthenticatorTests: XCTestCase {

    private var loginRemote: MockLoginRemote!
    private var simperiumAuth: MockSimperiumAuthenticator!
    private var magicLinkAuth: MagicLinkAuthenticator!
    
    override func setUp() async throws {
        loginRemote = MockLoginRemote()
        simperiumAuth = MockSimperiumAuthenticator()
        magicLinkAuth = MagicLinkAuthenticator(authenticator: simperiumAuth, loginRemote: loginRemote)
    }
    
    func testMagicLinkURLReturnsTrueWhenSomeValidLinkIsReceived() throws {
        XCTAssertTrue(magicLinkAuth.handle(url: MagicLinkTestConstants.sampleValidURL))
    }

    func testMagicLinkURLReturnsFalseWhenSomeValidInvalidLinkIsReceived() throws {
        XCTAssertFalse(magicLinkAuth.handle(url: MagicLinkTestConstants.sampleInvalidURL))
    }
    
    func testMagicLinkURLResultsInLoginConfirmationRequest() throws {
        let expectation = expectation(description: "LoginConfirmationRequest")
        loginRemote.onLoginConfirmationRequest = { (authKey, authCode) in
            XCTAssertEqual(authCode, MagicLinkTestConstants.expectedCode)
            XCTAssertEqual(authKey, MagicLinkTestConstants.expectedKey)
            
            return LoginConfirmationResponse(username: MagicLinkTestConstants.expectedUsername, syncToken: MagicLinkTestConstants.expectedSyncToken)
        }
        
        simperiumAuth.onAuthenticationRequest = { (username, token) in
            expectation.fulfill()
        }
        
        XCTAssertTrue(magicLinkAuth.handle(url: MagicLinkTestConstants.sampleValidURL))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMagicLinkURLWithValidConfirmationResponseResultsInSimperiumAuthenticationRequest() throws {
        let expectation = expectation(description: "LoginConfirmationRequest")
        loginRemote.onLoginConfirmationRequest = { authKey, authCode in
            LoginConfirmationResponse(username: MagicLinkTestConstants.expectedUsername, syncToken: MagicLinkTestConstants.expectedSyncToken)
        }

        let expectation = expectation(description: "LoginAuthenticationRequest")
        simperiumAuth.onAuthenticationRequest = { (username, token) in
            XCTAssertEqual(username, MagicLinkTestConstants.expectedUsername)
            XCTAssertEqual(token, MagicLinkTestConstants.expectedSyncToken)
            expectation.fulfill()
        }
        
        XCTAssertTrue(magicLinkAuth.handle(url: MagicLinkTestConstants.sampleValidURL))
        waitForExpectations(timeout: 1, handler: nil)
    }
}


// MARK: - MagicLinkTestConstants
//
private enum MagicLinkTestConstants {
    static let expectedUsername = "yosemite@automattic.com"
    static let expectedSyncToken = "12345678"
    static let expectedKey = "1234"
    static let expectedCode = "5678"
    static let sampleValidURL = URL(string: "simplenotemac://login?auth_key=\(expectedKey)&auth_code=\(expectedCode)")!
    static let sampleInvalidURL = URL(string: "simplenotemac://login?auth_key=&auth_code=")!
}

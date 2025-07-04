//
//  contextTests.swift
//  contextTests
//
//  Created on 7/4/25.
//

import XCTest
@testable import context

final class contextTests: XCTestCase {
    
    func testAppExists() {
        // This is a minimal test to ensure the test target compiles
        XCTAssertNotNil(contextApp.self, "App should exist")
    }
} 
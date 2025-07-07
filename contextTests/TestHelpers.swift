//
//  TestHelpers.swift
//  contextTests
//
//  Created on 7/4/25.
//

import XCTest
@testable import context

// MARK: - Test Helper Extensions

extension XCTestCase {
    /// Wait for a condition to become true with customizable polling
    func wait(for condition: @autoclosure @escaping () -> Bool,
              timeout: TimeInterval = 5,
              pollingInterval: TimeInterval = 0.1,
              description: String = "Condition") {
        let expectation = XCTestExpectation(description: description)

        let timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { timer in
            if condition() {
                expectation.fulfill()
                timer.invalidate()
            }
        }

        wait(for: [expectation], timeout: timeout)
        timer.invalidate()
    }

    /// Execute async test with timeout
    func asyncTest(timeout: TimeInterval = 5,
                   block: @escaping () async throws -> Void) {
        let expectation = XCTestExpectation(description: "Async test")

        _Concurrency.Task {
            do {
                try await block()
                expectation.fulfill()
            } catch {
                XCTFail("Async test failed: \(error)")
            }
        }

        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - Panel Testing Helpers

extension XCTestCase {

    /// Test panel toggle behavior with validation
    @MainActor
    func testPanelToggle(
        appState: AppStateManager,
        initialState: Bool,
        expectedFinalState: Bool,
        description: String = "Panel toggle"
    ) {
        // Set initial state
        appState.updateUI(["showProjects": initialState])
        XCTAssertEqual(appState.state.ui.showProjects, initialState,
                       "\(description): Initial state should be \(initialState)")

        // Perform toggle
        appState.updateUI(["showProjects": expectedFinalState])
        XCTAssertEqual(appState.state.ui.showProjects, expectedFinalState,
                       "\(description): Final state should be \(expectedFinalState)")
    }

    /// Test panel resize with constraints validation
    @MainActor
    func testPanelResize(
        appState: AppStateManager,
        fromSize: Double,
        toSize: Double,
        expectedSize: Double,
        description: String = "Panel resize"
    ) {
        // Set initial size
        appState.updateUI(["projectsPanelSize": fromSize])
        XCTAssertEqual(appState.state.ui.projectsPanelSize, fromSize,
                       "\(description): Initial size should be \(fromSize)")

        // Perform resize
        appState.updateUI(["projectsPanelSize": toSize])
        XCTAssertEqual(appState.state.ui.projectsPanelSize, expectedSize,
                       "\(description): Final size should be \(expectedSize)")
    }

    /// Validate panel size constraints
    func validatePanelSizeConstraints(
        _ size: Double,
        minSize: Double = 20.0,
        maxSize: Double = 50.0
    ) -> Bool {
        return size >= minSize && size <= maxSize
    }
}

// MARK: - Test Data Structures

struct PanelSizeTestCase {
    let input: Double
    let expected: Double
    let description: String
}

// MARK: - Mock Data Helpers

struct TestDataHelper {

    /// Create a test AppStateManager with controlled initial state
    @MainActor
    static func createTestAppState(
        showProjects: Bool = false,
        projectsPanelSize: Double = 30.0,
        showChart: Bool = true,
        showChat: Bool = true
    ) -> AppStateManager {
        let appState = AppStateManager()

        // Override default UI state
        appState.updateUI([
            "showProjects": showProjects,
            "projectsPanelSize": projectsPanelSize,
            "showChart": showChart,
            "showChat": showChat
        ])

        return appState
    }

    /// Create test UI state configurations
    static func createTestUIStates() -> [(name: String, state: [String: Any])] {
        return [
            defaultUIState(),
            projectsHiddenUIState(),
            projectsVisibleUIState(),
            smallPanelUIState(),
            largePanelUIState(),
            minimalUIState()
        ]
    }

    private static func defaultUIState() -> (name: String, state: [String: Any]) {
        return (
            name: "Default",
            state: [
                "showProjects": false,
                "projectsPanelSize": 30.0,
                "showChart": true,
                "showChat": true
            ]
        )
    }

    private static func projectsHiddenUIState() -> (name: String, state: [String: Any]) {
        return (
            name: "Projects Hidden",
            state: [
                "showProjects": false,
                "projectsPanelSize": 30.0,
                "showChart": true,
                "showChat": true
            ]
        )
    }

    private static func projectsVisibleUIState() -> (name: String, state: [String: Any]) {
        return (
            name: "Projects Visible",
            state: [
                "showProjects": true,
                "projectsPanelSize": 30.0,
                "showChart": true,
                "showChat": true
            ]
        )
    }

    private static func smallPanelUIState() -> (name: String, state: [String: Any]) {
        return (
            name: "Small Panel",
            state: [
                "showProjects": true,
                "projectsPanelSize": 20.0,
                "showChart": true,
                "showChat": true
            ]
        )
    }

    private static func largePanelUIState() -> (name: String, state: [String: Any]) {
        return (
            name: "Large Panel",
            state: [
                "showProjects": true,
                "projectsPanelSize": 45.0,
                "showChart": true,
                "showChat": true
            ]
        )
    }

    private static func minimalUIState() -> (name: String, state: [String: Any]) {
        return (
            name: "Minimal UI",
            state: [
                "showProjects": false,
                "projectsPanelSize": 30.0,
                "showChart": false,
                "showChat": false
            ]
        )
    }

    /// Panel size test cases with expected behaviors
    static func createPanelSizeTestCases() -> [PanelSizeTestCase] {
        return [
            PanelSizeTestCase(
                input: 15.0, 
                expected: 15.0, 
                description: "Below minimum size (should be accepted by updateUI)"
            ),
            PanelSizeTestCase(input: 20.0, expected: 20.0, description: "Minimum size"),
            PanelSizeTestCase(input: 25.0, expected: 25.0, description: "Small size"),
            PanelSizeTestCase(input: 30.0, expected: 30.0, description: "Default size"),
            PanelSizeTestCase(input: 35.0, expected: 35.0, description: "Medium size"),
            PanelSizeTestCase(input: 40.0, expected: 40.0, description: "Large size"),
            PanelSizeTestCase(input: 50.0, expected: 50.0, description: "Maximum size"),
            PanelSizeTestCase(
                input: 60.0, 
                expected: 60.0, 
                description: "Above maximum size (should be accepted by updateUI)"
            ),
            PanelSizeTestCase(input: 0.0, expected: 0.0, description: "Zero size"),
            PanelSizeTestCase(
                input: -5.0, 
                expected: -5.0, 
                description: "Negative size (should be accepted by updateUI)"
            )
        ]
    }
}

// MARK: - Performance Testing Helpers

extension XCTestCase {

    /// Measure panel toggle performance
    @MainActor
    func measurePanelTogglePerformance(appState: AppStateManager, iterations: Int = 100) {
        measure {
            for i in 0..<iterations {
                let shouldShow = i % 2 == 0
                appState.updateUI(["showProjects": shouldShow])
            }
        }
    }

    /// Measure panel resize performance
    @MainActor
    func measurePanelResizePerformance(appState: AppStateManager, iterations: Int = 100) {
        measure {
            for i in 0..<iterations {
                let size = 20.0 + Double(i % 30) // Vary size between 20-50
                appState.updateUI(["projectsPanelSize": size])
            }
        }
    }
}

// MARK: - UI State Validation Helpers

struct UIStateValidator {

    /// Validate that UI state is in a consistent state
    static func validateUIStateConsistency(_ uiState: UIState) -> [String] {
        var issues: [String] = []

        // Panel size should be reasonable
        if uiState.projectsPanelSize < 0 {
            issues.append("Panel size is negative: \(uiState.projectsPanelSize)")
        }

        if uiState.projectsPanelSize > 100 {
            issues.append("Panel size is unreasonably large: \(uiState.projectsPanelSize)")
        }

        // If projects panel is hidden, size is still maintained
        if !uiState.showProjects && uiState.projectsPanelSize == 0 {
            issues.append("Hidden panel has zero size (size should be preserved)")
        }

        return issues
    }

    /// Validate panel width calculation
    static func validatePanelWidthCalculation(panelSize: Double) -> CGFloat {
        return CGFloat(panelSize * 10)
    }

    /// Check if panel size is within reasonable UI constraints
    static func isPanelSizeReasonable(_ size: Double) -> Bool {
        // Based on typical screen sizes and UI guidelines
        let minReasonableSize = 15.0  // 150px minimum
        let maxReasonableSize = 60.0  // 600px maximum
        return size >= minReasonableSize && size <= maxReasonableSize
    }
}

// MARK: - Test Assertion Helpers

extension XCTestCase {

    /// Assert panel state with detailed error message
    @MainActor
    func assertPanelState(
        _ appState: AppStateManager,
        isVisible: Bool,
        size: Double,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            appState.state.ui.showProjects,
            isVisible,
            "Panel visibility should be \(isVisible)",
            file: file,
            line: line
        )

        XCTAssertEqual(
            appState.state.ui.projectsPanelSize,
            size,
            "Panel size should be \(size)",
            file: file,
            line: line
        )
    }

    /// Assert that panel size is within expected range
    func assertPanelSizeInRange(
        _ actualSize: Double,
        min: Double,
        max: Double,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(
            actualSize,
            min,
            "Panel size \(actualSize) should be >= \(min)",
            file: file,
            line: line
        )

        XCTAssertLessThanOrEqual(
            actualSize,
            max,
            "Panel size \(actualSize) should be <= \(max)",
            file: file,
            line: line
        )
    }
}

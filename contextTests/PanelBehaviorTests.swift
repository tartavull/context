//
//  PanelBehaviorTests.swift
//  contextTests
//
//  Created on 7/4/25.
//

import XCTest
@testable import context

@MainActor
final class PanelBehaviorTests: XCTestCase {
    
    var appState: AppStateManager!
    
    override func setUp() {
        super.setUp()
        appState = TestDataHelper.createTestAppState()
    }
    
    override func tearDown() {
        appState = nil
        super.tearDown()
    }
    
    // MARK: - Data-Driven Panel Tests
    
    func testPanelToggleScenarios() {
        let scenarios = [
            (initial: true, target: false, description: "Hide visible panel"),
            (initial: false, target: true, description: "Show hidden panel"),
            (initial: true, target: true, description: "Keep panel visible"),
            (initial: false, target: false, description: "Keep panel hidden")
        ]
        
        for scenario in scenarios {
            testPanelToggle(
                appState: appState,
                initialState: scenario.initial,
                expectedFinalState: scenario.target,
                description: scenario.description
            )
        }
    }
    
    func testPanelResizeScenarios() {
        let testCases = TestDataHelper.createPanelSizeTestCases()
        
        for testCase in testCases {
            testPanelResize(
                appState: appState,
                fromSize: 30.0,  // Start from default
                toSize: testCase.input,
                expectedSize: testCase.expected,
                description: testCase.description
            )
        }
    }
    
    func testUIStateConfigurations() {
        let configurations = TestDataHelper.createTestUIStates()
        
        for config in configurations {
            appState.updateUI(config.state)
            
            // Validate the configuration was applied
            if let showProjects = config.state["showProjects"] as? Bool {
                XCTAssertEqual(appState.state.ui.showProjects, showProjects,
                             "\(config.name): showProjects should be \(showProjects)")
            }
            
            if let panelSize = config.state["projectsPanelSize"] as? Double {
                XCTAssertEqual(appState.state.ui.projectsPanelSize, panelSize,
                             "\(config.name): panel size should be \(panelSize)")
            }
            
            // Validate UI state consistency
            let issues = UIStateValidator.validateUIStateConsistency(appState.state.ui)
            XCTAssertTrue(issues.isEmpty, 
                         "\(config.name): UI state has issues: \(issues.joined(separator: ", "))")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testPanelSizeConstraintValidation() {
        let constraintTestCases: [(size: Double, shouldBeReasonable: Bool)] = [
            (10.0, false),   // Too small
            (15.0, true),    // Minimum reasonable
            (30.0, true),    // Default
            (60.0, true),    // Maximum reasonable
            (100.0, false),  // Too large
            (-5.0, false),   // Invalid negative
            (0.0, false)     // Invalid zero
        ]
        
        for testCase in constraintTestCases {
            let isReasonable = UIStateValidator.isPanelSizeReasonable(testCase.size)
            XCTAssertEqual(isReasonable, testCase.shouldBeReasonable,
                         "Size \(testCase.size) reasonable check failed")
        }
    }
    
    func testPanelWidthCalculation() {
        let sizeToWidthTests: [(panelSize: Double, expectedWidth: CGFloat)] = [
            (20.0, 200.0),
            (25.5, 255.0),
            (30.0, 300.0),
            (42.5, 425.0),
            (50.0, 500.0)
        ]
        
        for test in sizeToWidthTests {
            let calculatedWidth = UIStateValidator.validatePanelWidthCalculation(panelSize: test.panelSize)
            XCTAssertEqual(calculatedWidth, test.expectedWidth,
                         "Panel size \(test.panelSize) should calculate to width \(test.expectedWidth)")
        }
    }
    
    // MARK: - State Consistency Tests
    
    func testPanelStateConsistency() {
        // Test various state combinations for consistency
        let stateTests = [
            (showProjects: true, panelSize: 30.0, expectIssues: false),
            (showProjects: false, panelSize: 30.0, expectIssues: false),
            (showProjects: true, panelSize: -5.0, expectIssues: true),
            (showProjects: false, panelSize: 0.0, expectIssues: true),
            (showProjects: true, panelSize: 150.0, expectIssues: true)
        ]
        
        for test in stateTests {
            appState.updateUI([
                "showProjects": test.showProjects,
                "projectsPanelSize": test.panelSize
            ])
            
            let issues = UIStateValidator.validateUIStateConsistency(appState.state.ui)
            
            if test.expectIssues {
                XCTAssertFalse(issues.isEmpty,
                             "Expected issues for state: showProjects=\(test.showProjects), size=\(test.panelSize)")
            } else {
                XCTAssertTrue(issues.isEmpty,
                            "Unexpected issues for valid state: \(issues.joined(separator: ", "))")
            }
        }
    }
    
    // MARK: - Complex Interaction Tests
    
    func testPanelToggleWithSizePreservation() {
        let customSize = 42.0
        
        // Set custom size
        appState.updateUI(["projectsPanelSize": customSize])
        assertPanelState(appState, isVisible: false, size: customSize)
        
        // Hide panel
        appState.updateUI(["showProjects": false])
        XCTAssertFalse(appState.state.ui.showProjects, "Panel should be hidden")
        XCTAssertEqual(appState.state.ui.projectsPanelSize, customSize,
                      "Panel size should be preserved when hidden")
        
        // Show panel again
        appState.updateUI(["showProjects": true])
        assertPanelState(appState, isVisible: true, size: customSize)
    }
    

    
    func testRapidToggleStability() {
        let initialSize = appState.state.ui.projectsPanelSize
        
        // Perform rapid toggles
        for i in 0..<10 {
            let shouldShow = i % 2 == 0
            appState.updateUI(["showProjects": shouldShow])
            
            // Size should remain stable
            XCTAssertEqual(appState.state.ui.projectsPanelSize, initialSize,
                         "Panel size should remain stable during toggle \(i)")
        }
        
        // Final state should be hidden (10 toggles, starting from visible)
        XCTAssertFalse(appState.state.ui.showProjects, "Panel should be hidden after even number of toggles")
    }
    
    // MARK: - Performance Tests
    
    func testPanelTogglePerformance() {
        measurePanelTogglePerformance(appState: appState, iterations: 50)
    }
    
    func testPanelResizePerformance() {
        measurePanelResizePerformance(appState: appState, iterations: 50)
    }
    
    // MARK: - Boundary Tests
    
    func testPanelSizeBoundaries() {
        let boundaryTests: [(size: Double, description: String)] = [
            (Double.leastNormalMagnitude, "Smallest positive double"),
            (1.0, "Unit size"),
            (19.9, "Just below typical minimum"),
            (20.0, "Typical minimum"),
            (20.1, "Just above typical minimum"),
            (49.9, "Just below typical maximum"),
            (50.0, "Typical maximum"),
            (50.1, "Just above typical maximum"),
            (Double.greatestFiniteMagnitude, "Largest finite double")
        ]
        
        for test in boundaryTests {
            appState.updateUI(["projectsPanelSize": test.size])
            XCTAssertEqual(appState.state.ui.projectsPanelSize, test.size,
                         "\(test.description): Size should be accepted as \(test.size)")
        }
    }
    
    // MARK: - Helper Method Tests
    

    
    // MARK: - Integration Tests
    
    func testPanelIntegrationWithOtherUIElements() {
        // Test that panel changes don't affect other UI elements
        let initialChartState = appState.state.ui.showChart
        let initialChatState = appState.state.ui.showChat
        
        // Change panel state
        appState.updateUI(["showProjects": false])
        appState.updateUI(["projectsPanelSize": 45.0])
        appState.updateUI(["showProjects": true])
        
        // Other UI elements should be unchanged
        XCTAssertEqual(appState.state.ui.showChart, initialChartState,
                      "Chart state should not be affected by panel changes")
        XCTAssertEqual(appState.state.ui.showChat, initialChatState,
                      "Chat state should not be affected by panel changes")
    }
} 

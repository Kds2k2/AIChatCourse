//
//  AIChatCourseUITests.swift
//  AIChatCourseUITests
//
//  Created by Dmitro Kryzhanovsky on 24.02.2026.
//

import XCTest

@MainActor
final class AIChatCourseUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"] // LaunchArgumentOptions.signIn.rawValue
        app.launch()
        
        // Welcome View
        app.buttons["StartButton"].tap()
        
        // Onb.Intro View
        app.buttons["ContinueButton"].tap()
        
        // Onb.Color View
        let colorCircles = app.otherElements.matching(identifier: "ColorCircle")
        let randomIndex = Int.random(in: 0..<colorCircles.count)
        let colorCircle = colorCircles.element(boundBy: randomIndex)
        colorCircle.tap()
        app.buttons["ContinueButton"].tap()
        
        // Onb.Completed View
        app.buttons["FinishButton"].tap()
        
        // Explore View
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists)
    }
}

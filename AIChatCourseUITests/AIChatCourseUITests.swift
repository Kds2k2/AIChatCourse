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
    
    func testOnboardingFlowWithCommunity() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", LaunchArgumentOptions.onboardingCommunity.rawValue]
        app.launch()
        
        // Welcome View
        app.buttons["StartButton"].tap()
        
        // Onb.Intro View
        app.buttons["ContinueButton"].tap()
        
        // Onb.Community View
        app.buttons["OnboardingCommunityContinueButton"].tap()
        
        // Onb.Color View
        let colorCircles = app.otherElements.matching(identifier: "ColorCircle")
        let randomIndex = Int.random(in: 0..<colorCircles.count)
        let colorCircle = colorCircles.element(boundBy: randomIndex)
        colorCircle.tap()
        
        let continueAfterColor = app.buttons["ContinueButton"]
        XCTAssertTrue(continueAfterColor.waitForExistence(timeout: 2))
        continueAfterColor.tap()
        
        // Completed View
        let finishButton = app.buttons["FinishButton"]
        XCTAssertTrue(finishButton.waitForExistence(timeout: 2))
        finishButton.tap()
        
        // Explore View
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists)
    }
    
    func testTabBarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", LaunchArgumentOptions.signIn.rawValue]
        app.launch()
        
        // Tab Bar
        let tabBar = app.tabBars["Tab Bar"]
        
        // Explore View
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists)
        
        // Hero Cell
        app.collectionViews.scrollViews.otherElements.buttons.firstMatch.tap()
        
        // Chat View
        let chatTextFieldExists = app.textFields["ChatTextField"].exists
        XCTAssertTrue(chatTextFieldExists)
        
        // Back Button
        app.navigationBars.buttons.firstMatch.tap()
        let exploreExists1 = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists1)
        
        // ChatTab + Click
        tabBar.buttons["Chats"].tap()
        let chatsExists = app.navigationBars["Chats"].exists
        XCTAssertTrue(chatsExists)
        
        app.collectionViews.scrollViews.otherElements.buttons.firstMatch.tap()
        let chatTextFieldExists1 = app.textFields["ChatTextField"].exists
        XCTAssertTrue(chatTextFieldExists1)
        
        // Back Button
        app.navigationBars.buttons.firstMatch.tap()
        let chatsExists1 = app.navigationBars["Chats"].exists
        XCTAssertTrue(chatsExists1)
        
        // ProfileTab + Click
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists)
        
        app.collectionViews.buttons.element(boundBy: 1).tap()
        let chatTextFieldExists2 = app.textFields["ChatTextField"].exists
        XCTAssertTrue(chatTextFieldExists2)
        
        // Back Button
        app.navigationBars.buttons.firstMatch.tap()
        let profileExists1 = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists1)
        
        tabBar.buttons["Explore"].tap()
        let exploreExistsAgain = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExistsAgain)
    }
    
    func testSignOutFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", LaunchArgumentOptions.signIn.rawValue]
        app.launch()
        
        // Tab Bar
        let tabBar = app.tabBars["Tab Bar"]
        
        // Explore View
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists)
        
        // ProfileTab
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists)
        
        app.navigationBars["Profile"].buttons["Settings"].tap()
        app.collectionViews.buttons["Sign out"].tap()
        
        let startButtonExists = app.buttons["StartButton"].waitForExistence(timeout: 2)
        XCTAssertTrue(startButtonExists)
    }
    
    func testCreateAvatar() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", LaunchArgumentOptions.signIn.rawValue, LaunchArgumentOptions.screenCreateAvatar.rawValue]
        app.launch()
        
        let exploreExists = app.navigationBars["Create Avatar"].exists
        XCTAssertTrue(exploreExists)
    }
}

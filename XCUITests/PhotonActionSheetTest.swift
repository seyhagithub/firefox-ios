/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class PhotonActionSheetTest: BaseTestCase {
    func testPinToTop() {
        navigator.openURL("http://example.com")
        waitUntilPageLoad()
        // Open Page Action Menu Sheet and Pin the site
        navigator.performAction(Action.PinToTopSitesPAM)

        // Navigate to topsites to verify that the site has been pinned
        navigator.goto(NewTabScreen)

        // Verify that the site is pinned to top
        let cell = app.cells["TopSite"].firstMatch
        XCTAssertEqual(cell.label, "example")

        // Remove pin
        cell.press(forDuration: 2)
        app.cells["action_unpin"].tap()

        // Check that it has been unpinned
        cell.press(forDuration: 2)
        waitforExistence(app.cells["action_pin"])
    }

    func testShareOptionIsShown() {
        navigator.browserPerformAction(.shareOption)

        // Wait to see the Share options sheet
        waitforExistence(app.buttons["Copy"])
    }

    func testShareOptionIsShownFromShortCut() {
        navigator.goto(BrowserTab)
        waitUntilPageLoad()
        app.buttons["TabLocationView.pageOptionsButton"].press(forDuration: 1)
        // Wait to see the Share options sheet
        waitforExistence(app.buttons["Copy"])
    }

    func testSendToDeviceFromPageOptionsMenu() {
        // User not logged in
        navigator.browserPerformAction(.sendToDeviceOption)
        waitforExistence(app.images["emptySync"])
        XCTAssertTrue(app.staticTexts["You are not signed in to your Firefox Account."].exists)
    }

    // Test disabled due to new implementation Bug 1449708 - new share sheet
    func testSendToDeviceFromShareOption() {
        // Open and Wait to see the Share options sheet
        navigator.browserPerformAction(.shareOption)
        waitforExistence(app.buttons["More"])
        waitforNoExistence(app.buttons["Send Tab"])
        app.collectionViews.cells/*@START_MENU_TOKEN@*/.collectionViews.containing(.button, identifier:"Copy")/*[[".collectionViews.containing(.button, identifier:\"Create PDF\")",".collectionViews.containing(.button, identifier:\"Print\")",".collectionViews.containing(.button, identifier:\"Copy\")"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["More"].tap()

        // Enable Send Tab
        let sendTabButton = app.tables.cells.switches["Send Tab"]
        sendTabButton.tap()
        app.navigationBars["Activities"].buttons["Done"].tap()

        // Send Tab option appears on the Share options sheet
        waitforExistence(app.buttons["Send Tab"])
        app.buttons["Send Tab"].tap()

        // User not logged in
        waitforExistence(app.images["emptySync"])
        XCTAssertTrue(app.staticTexts["You are not signed in to your Firefox Account."].exists)
    }

    func testSharePageWithShareSheetOptions() {
        navigator.openURL("example.com")
        navigator.goto(PageOptionsMenu)
        app.tables["Context Menu"].staticTexts["Share Page With…"].tap()
        waitforExistence(app.buttons["Copy"])
        let moreElement = app.collectionViews.element(boundBy: 0).buttons.element(boundBy: app.collectionViews.element(boundBy: 0).buttons.count-5)
        moreElement.tap()
        app.switches["Fennec"].tap()
        app.buttons["Done"].tap()
        waitforExistence(app.buttons["Copy"])
        let fennecElement = app.collectionViews.element(boundBy: 0).buttons.element(boundBy: app.collectionViews.element(boundBy: 0).buttons.count-6)
        fennecElement.tap()
        waitforExistence(app.navigationBars["ShareTo.ShareView"])
        XCTAssertTrue(app.staticTexts["Open in Firefox"].exists)
        XCTAssertTrue(app.staticTexts["Load in Background"].exists)
        XCTAssertTrue(app.staticTexts["Bookmark This Page"].exists)
        XCTAssertTrue(app.staticTexts["Add to Reading List"].exists)
        XCTAssertTrue(app.staticTexts["Send to Device"].exists)
    }
}

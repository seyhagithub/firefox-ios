import XCTest

let testFileName = "Small.zip"
let testFileSize = "178 bytes"
let testFileName2 = "Data1KB.dat"
let testURL = "http://demo.borland.com/testsite/download_testpage.php"

class DownloadFilesTests: BaseTestCase {

    override func tearDown() {
        // The downloaded file has to be removed between tests
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        waitforExistence(app.tables["DownloadsTable"])
        if (app.tables.cells.staticTexts[testFileName].exists) {
            app.tables.cells.staticTexts[testFileName].swipeLeft()
            app.tables.cells.buttons["Delete"].tap()

        }
        if (app.tables.cells.staticTexts[testFileName2].exists) {
            app.tables.cells.staticTexts[testFileName2].swipeLeft()
            app.tables.cells.buttons["Delete"].tap()

        }
    }

    func testDownloadFilesAppMenuFirstTime() {
        navigator.goto(HomePanel_Downloads)
        XCTAssertTrue(app.tables["DownloadsTable"].exists)
        // Check that there is not any items and the default text shown is correct
        checkTheNumberOfDownloadedItems(items: 0)
        XCTAssertTrue(app.staticTexts["Downloaded files will show up here."].exists)
    }

    func testDownloadFileContextMenu() {
        navigator.openURL(testURL)
        waitUntilPageLoad()
        // Verify that the context menu prior to download a file is correct
        app.webViews.staticTexts[testFileName].tap()
        app.webViews.buttons["Download"].tap()
        waitforExistence(app.tables["Context Menu"])
        XCTAssertTrue(app.tables["Context Menu"].staticTexts[testFileName].exists)
        XCTAssertTrue(app.tables["Context Menu"].cells["download"].exists)
        app.buttons["Cancel"].tap()
    }

    func testDownloadOptionFromBrowserTabMenu() {
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        XCTAssertTrue(app.tables["DownloadsTable"].exists)
    }

    func testDownloadAfile() {
        downloadFile(fileName: testFileName)
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)

        waitforExistence(app.tables["DownloadsTable"])
        // There should be one item downloaded. It's name and size should be shown
        checkTheNumberOfDownloadedItems(items: 1)
        XCTAssertTrue(app.tables.cells.staticTexts[testFileName].exists)
        XCTAssertTrue(app.tables.cells.staticTexts[testFileSize].exists)
    }

    func testDeleteDownloadedFile() {
        downloadFile(fileName: testFileName)
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        waitforExistence(app.tables["DownloadsTable"])
        app.tables.cells.staticTexts[testFileName].swipeLeft()

        XCTAssertTrue(app.tables.cells.buttons["Share"].exists)
        XCTAssertTrue(app.tables.cells.buttons["Delete"].exists)

        app.tables.cells.buttons["Delete"].tap()
        waitforNoExistence(app.tables.cells.staticTexts[testFileName])

        // After removing the number of items should be 0
        checkTheNumberOfDownloadedItems(items: 0)
    }

    func testShareDownloadedFile() {
        downloadFile(fileName: testFileName)
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        app.tables.cells.staticTexts[testFileName].swipeLeft()

        XCTAssertTrue(app.tables.cells.buttons["Share"].exists)
        XCTAssertTrue(app.tables.cells.buttons["Delete"].exists)

        app.tables.cells.buttons["Share"].tap()
        waitforExistence(app.otherElements["ActivityListView"])
        app.buttons["Cancel"].tap()
    }

    private func downloadFile(fileName: String) {
        navigator.openURL(testURL)
        waitUntilPageLoad()

        app.webViews.staticTexts[fileName].tap()
        app.webViews.buttons["Download"].tap()
        waitforExistence(app.tables["Context Menu"])
        app.tables["Context Menu"].cells["download"].tap()
    }

    func testLongPressOnDownloadedFile() {
        downloadFile(fileName: testFileName)
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)

        waitforExistence(app.tables["DownloadsTable"])
        app.tables.cells.staticTexts[testFileName].press(forDuration: 2)
        waitforExistence(app.otherElements["ActivityListView"])
        app.buttons["Cancel"].tap()
    }

    func testDownloadMoreThanOneFile() {
        downloadFile(fileName: testFileName)
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        checkTheNumberOfDownloadedItems(items: 1)

        downloadFile(fileName: testFileName2)

        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        checkTheNumberOfDownloadedItems(items: 2)
    }

    func testRemoveUserDataRemovesDownloadedFiles() {
        // The option to remove downloaded files from clear private data is off by default
        navigator.goto(ClearPrivateDataSettings)
        XCTAssertTrue(app.cells.switches["Downloaded Files"].isEnabled, "The switch is not set correclty by default")

        // Change the value of the setting to on (make an action for this)
        downloadFile(fileName: testFileName)

        // Check there is one item
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)

        waitforExistence(app.tables["DownloadsTable"])
        checkTheNumberOfDownloadedItems(items: 1)

        // Remove private data once the switch to remove downloaded files is enabled
        navigator.goto(ClearPrivateDataSettings)
        app.cells.switches["Downloaded Files"].tap()
        navigator.performAction(Action.AcceptClearPrivateData)

        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        // Check there is still one item
        checkTheNumberOfDownloadedItems(items: 0)
    }

    private func checkTheNumberOfDownloadedItems(items: Int) {
        waitforExistence(app.tables["DownloadsTable"])
        let list = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(list, items, "The number of items in the downloads table is not correct")
    }

    func testToastButtonToGoToDownloads() {
        downloadFile(fileName: testFileName)
        waitforExistence(app.buttons["Downloads"])
        app.buttons["Downloads"].tap()
        waitforExistence(app.tables["DownloadsTable"])
        checkTheNumberOfDownloadedItems(items: 1)
    }
}

import XCTest


class DownloadFilesTests: BaseTestCase {

    func testDownloadFilesAppMenuFirstTime() {
        navigator.goto(HomePanel_Downloads)

        //waitforExistence(app.tables["DownloadsTable"])
        //sleep(2)
        print(app.debugDescription)
        XCTAssertTrue(app.tables["DownloadsTable"].exists)
        //XCTAssertTrue(app.tables["DownloadsTable"].otherElements.images["emptyDownloads"].exists, "The downloads image does not appear")
        let list = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(list, 0, "The number of items in the downloads table is not correct")
        XCTAssertTrue(app.staticTexts["Downloaded files will show up here."].exists)
    }

    func testDownloadFileContextMenu() {
        navigator.openURL("http://demo.borland.com/testsite/download_testpage.php")
        waitUntilPageLoad()

        app.webViews.staticTexts["Small.zip"].tap()
        app.webViews.buttons["Download"].tap()
        waitforExistence(app.tables["Context Menu"])
        XCTAssertTrue(app.tables["Context Menu"].staticTexts["Small.zip"].exists)
        XCTAssertTrue(app.tables["Context Menu"].cells["download"].exists)
    }

    func testDownloadOptionFromBrowserTabMenu() {
        navigator.goto(BrowserTabMenu)
        navigator.goto(HomePanel_Downloads)
        XCTAssertTrue(app.tables["DownloadsTable"].exists)
    }

    func testDownloadAfile() {
        downloadFile()
        navigator.goto(HomePanel_Downloads)

        waitforExistence(app.tables["DownloadsTable"])
        // There should be one item downloaded. It's name and size should be shown
        let list = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(list, 0, "The number of items in the downloads table is not correct")

        XCTAssertTrue(app.tables.cells.staticTexts["Small.zip"].exists)
        XCTAssertTrue(app.tables.cells.staticTexts["178 bytes"].exists)
    }

    func testDeleteDownloadedFile() {
        downloadFile()
        navigator.goto(HomePanel_Downloads)
        sleep(2)

        //waitforExistence(app.tables["DownloadsTable"])
        app.tables.cells.staticTexts["Small (13).zip"].swipeLeft()

        XCTAssertTrue(app.tables.cells.buttons["Share"].exists)
        XCTAssertTrue(app.tables.cells.buttons["Delete"].exists)

        app.tables.cells.buttons["Delete"].tap()
        waitforNoExistence(app.tables.cells.staticTexts["Small.zip"])

        // After removing the number of items should be 0
        let list = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(list, 0, "The number of items in the downloads table is not correct")
    }

    func testShareDownloadedFile() {
        downloadFile()
        navigator.goto(HomePanel_Downloads)

        app.tables.cells.staticTexts["Small.zip"].swipeLeft()

        XCTAssertTrue(app.tables.cells.buttons["Share"].exists)
        XCTAssertTrue(app.tables.cells.buttons["Delete"].exists)

        app.tables.cells.buttons["Share"].tap()
        sleep(2)
        print(app.debugDescription)
        waitforExistence(app.otherElements["ActivityListView"])
    }

    private func downloadFile() {
        navigator.openURL("http://demo.borland.com/testsite/download_testpage.php")
        waitUntilPageLoad()

        app.webViews.staticTexts["Small.zip"].tap()
        app.webViews.buttons["Download"].tap()
        waitforExistence(app.tables["Context Menu"])
        app.tables["Context Menu"].cells["download"].tap()
    }

    func testLongPressOnDownloadedFile() {
        //downloadFile()
        navigator.goto(HomePanel_Downloads)

        //waitforExistence(app.tables["DownloadsTable"])
        app.tables.cells.staticTexts["Small (12).zip"].press(forDuration: 2)
        waitforExistence(app.otherElements["ActivityListView"])
    }

    func testDownloadMoreThanOneFile() {
    }

    func testRemoveUserDataRemovesDownloadedFiles() {
        // The option to remove downloaded from clear private data menu has been added
        // At least on sim after clearing data, the downloaded files are not removed
        // downloadFile()
        // Check there is one item
        navigator.goto(HomePanel_Downloads)
        let list = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(list, 12, "The number of items in the downloads table is not correct")
        navigator.performAction(Action.AcceptClearPrivateData)
        
        navigator.goto(HomePanel_Downloads)
        // Check there is still one item
        let listAfter = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(listAfter, 12, "The number of items in the downloads table is not correct")
    }
}

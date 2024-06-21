//
//  FriendsViewModelTests.swift
//  kokoTests
//
//  Created by 吳昭泉 on 2024/6/21.
//

import XCTest
import Combine
@testable import koko

final class FriendsViewModelTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel = FriendsViewModel()
    
    func testUserInfo() throws {
        let expectation = XCTestExpectation(description: "Fetching")
        viewModel.fetchUserInfo {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(viewModel.userId, "Mike")
    }
    
    func testNoFriends() throws {
        let expectation = XCTestExpectation(description: "Fetching")
        viewModel.fetchFriends(by: .noFriend) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(viewModel.hasFriendsList, false)
        XCTAssertEqual(viewModel.friendsCount, 0)
    }
    
    func testBestFriends() {
        let expectation = XCTestExpectation(description: "Fetching")
        viewModel.fetchFriends(by: .bestFriends) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(viewModel.hasFriendsList, true)
        XCTAssertEqual(viewModel.friendsCount, 8)
    }
    
    func testAllFriends() {
        let expectation = XCTestExpectation(description: "Fetching")
        viewModel.fetchFriends(by: .allFriends) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(viewModel.hasFriendsList, true)
        XCTAssertEqual(viewModel.friendsCount, 5)
    }
}

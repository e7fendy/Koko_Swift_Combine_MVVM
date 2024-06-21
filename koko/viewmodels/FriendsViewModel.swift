//
//  FriendsViewModel.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation
import UIKit
import Combine

final class FriendsViewModel: ObservableObject {
    
    enum FriendsType {
        case noFriend
        case bestFriends
        case allFriends
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Int, FriendsInfoDetails>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, FriendsInfoDetails>
    
    @Published var userName: String?
    @Published var userId: String?
    @Published var invitedFriendListHeight: CGFloat = 0
    @Published var hasFriendsList: Bool?
    
    public var bestFriendsDataSource: DataSource?
    public var invitedFriendsDataSource: DataSource?
    
    private var friendsList: [FriendsInfoDetails]?
    private var cancellables = Set<AnyCancellable>()
    
    var friendsCount: Int {
        get {
            friendsList?.count ?? 0
        }
    }
    
    func fetchUserInfo(_ completion: (() -> ())? = nil) {
        WebManager.shared.getUserInfo()
            .sink { _ in
                completion?()
            } receiveValue: { [weak self] data in
                self?.userName = data.response.first?.name
                self?.userId = data.response.first?.kokoid
            }
            .store(in: &cancellables)
    }
    
    func fetchFriends(by type: FriendsType, completion: @escaping () -> ()) {
        
        if type == .bestFriends {
            
            let pubOne = WebManager.shared.getFriendsInfo(by: "https://dimanyen.github.io/friend1.json")
            let pubTwo = WebManager.shared.getFriendsInfo(by: "https://dimanyen.github.io/friend2.json")
            
            Publishers.Merge(pubOne, pubTwo)
                .sink { [weak self] _ in
                    self?.handleFriendsList()
                    completion()
                } receiveValue: { [weak self] data in
                    if self?.friendsList == nil {
                        self?.friendsList = []
                    }
                    self?.friendsList?.append(contentsOf: data.response ?? [])
                }
                .store(in: &cancellables)
            
        } else {
            
            let url = type == .noFriend ? "https://dimanyen.github.io/friend4.json" : "https://dimanyen.github.io/friend3.json"
            
            WebManager.shared.getFriendsInfo(by: url)
                .sink { [weak self] _ in
                    self?.handleFriendsList()
                    completion()
                } receiveValue: { [weak self] data in
                    if self?.friendsList == nil {
                        self?.friendsList = []
                    }
                    self?.friendsList?.append(contentsOf: data.response ?? [])
                }
                .store(in: &cancellables)
        }
    }
    
    func filterBestFriendsData(by value: String?) {
        self.handleFriendsList(bestFriendsFilter: value)
    }
    
    private func handleFriendsList(bestFriendsFilter: String? = nil) {
        guard let friendsList = self.friendsList else {
            return
        }
        
        // Duplicate check
        var newFriendsList: [FriendsInfoDetails] = []
        friendsList.forEach { each in
            if let added = newFriendsList.first(where: { $0.fid == each.fid }),
               let addedDate = strToDate(added.updateDate ?? ""),
               let eachDate = strToDate(each.updateDate ?? "")
            {
                newFriendsList.removeAll(where: { $0.fid == each.fid })
                let tobeAdded = addedDate > eachDate ? added : each
                newFriendsList.append(tobeAdded)
            } else {
                newFriendsList.append(each)
            }
        }
        
        let invitedFriends = newFriendsList.filter { $0.status == 0 }
        var bestFriends = newFriendsList.filter { $0.status == 1 }
        
        if let bestFriendsFilter, bestFriendsFilter.isEmpty == false {
            bestFriends = bestFriends.filter {
                $0.name?.contains(bestFriendsFilter) ?? true
            }
        }
        
        self.hasFriendsList = !newFriendsList.isEmpty
        self.invitedFriendListHeight = CGFloat(min(invitedFriends.count, 2) * 80)
        
        self.updateDataSource(of: self.invitedFriendsDataSource, data: invitedFriends)
        self.updateDataSource(of: self.bestFriendsDataSource, data: bestFriends)
    }
    
    private func updateDataSource(of dataSource: DataSource?, data: [FriendsInfoDetails]) {
        guard let dataSource else {
            return
        }
        var snapshot = Snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func strToDate(_ str: String?) -> Date? {
        guard let str else {
            return nil
        }
        
        let dateFormatList = ["yyyyMMdd", "yyyy/MM/dd"]
        for dateFormat in dateFormatList {
            let dateFormatterFirst = DateFormatter()
            dateFormatterFirst.locale = Locale(identifier: "en_US_POSIX")
            dateFormatterFirst.dateFormat = dateFormat
            
            if let result = dateFormatterFirst.date(from: str) {
                return result
            }
        }
        
        return nil
    }
}

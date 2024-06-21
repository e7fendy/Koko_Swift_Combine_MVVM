//
//  FriendsInfo.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation

struct FriendsInfoDetails: Codable, Hashable {
    var name: String?
    var status: Int?
    var isTop: String?
    var fid: String?
    var updateDate: String?
}

struct FriendsInfo: Codable {
    var response: [FriendsInfoDetails]?
}

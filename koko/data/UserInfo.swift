//
//  UserInfo.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation

struct UserInfoDetails: Codable {
    var name: String
    var kokoid: String
}

struct UserInfo: Codable {
    var response: [UserInfoDetails]
}

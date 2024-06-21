//
//  InvitedFriendsRowCell.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/21.
//

import Foundation
import UIKit

class InvitedFriendsRowCell: UITableViewCell, FriendsRowCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func didMoveToWindow() {
        setup()
    }
    
    private func setup() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 16
        self.layer.shouldRasterize = true
    }
    
    func configure(_ data: FriendsInfoDetails) {
        self.nameLabel.text = data.name ?? ""
    }
}

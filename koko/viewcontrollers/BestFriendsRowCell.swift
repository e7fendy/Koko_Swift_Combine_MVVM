//
//  BestFriendsRowCell.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/21.
//

import Foundation
import UIKit

class BestFriendsRowCell: UITableViewCell, FriendsRowCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var invitedButton: UIButton!
    
    override func didMoveToWindow() {
        setup()
    }
    
    private func setup() {
        self.transferButton.backgroundColor = .clear
        self.transferButton.layer.cornerRadius = 2
        self.transferButton.layer.borderWidth = 1
        self.transferButton.layer.borderColor = UIColor.systemPink.cgColor
        
        self.invitedButton.backgroundColor = .clear
        self.invitedButton.layer.cornerRadius = 2
        self.invitedButton.layer.borderWidth = 1
        self.invitedButton.layer.borderColor = UIColor.gray.cgColor
    }
    
    func configure(_ data: FriendsInfoDetails) {
        self.nameLabel.text = data.name ?? ""
        self.invitedButton.isHidden = !(data.status == 2)
    }
}

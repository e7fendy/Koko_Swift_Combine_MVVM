//
//  CustomSegmentedControl.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation
import UIKit

class CustomSegmentedControl: UISegmentedControl {
    
    private lazy var bottomUnderlineView: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = UIColor.systemPink
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        return underlineView
    }()
    
    private lazy var leadingDistanceConstraint: NSLayoutConstraint = {
        return bottomUnderlineView.leftAnchor.constraint(equalTo: self.leftAnchor)
    }()
    
    override func didMoveToSuperview() {
        self.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        self.setBackgroundImage(UIImage.init(color: UIColor.clear),
                                for: .normal,
                                barMetrics: .default)
        self.setDividerImage(UIImage.init(color: UIColor.clear),
                             forLeftSegmentState: .normal,
                             rightSegmentState: .normal,
                             barMetrics: .default)
        
        self.addSubview(self.bottomUnderlineView)
        
        NSLayoutConstraint.activate([
            self.bottomUnderlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.bottomUnderlineView.heightAnchor.constraint(equalToConstant: 4),
            self.leadingDistanceConstraint,
            self.bottomUnderlineView.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        DispatchQueue.main.async {
            self.changeSegmentedControlLinePosition()
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        changeSegmentedControlLinePosition()
    }

    private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(self.selectedSegmentIndex)
        let segmentWidth = self.frame.width / CGFloat(self.numberOfSegments)
        let leadingDistance = (segmentWidth * segmentIndex) + ((segmentWidth - 20) / 2)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.leadingDistanceConstraint.constant = leadingDistance
            self?.layoutIfNeeded()
        })
    }
}

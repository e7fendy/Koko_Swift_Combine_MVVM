//
//  FriendsViewController.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation
import UIKit
import Combine

class FriendsViewController: UIViewController {
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var addFriendContainer: UIView!
    @IBOutlet weak var friendListContainer: UIView!
    @IBOutlet weak var chatListContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var invitedFriendsTableView: UITableView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    
    @IBOutlet weak var bodyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var invitedFriendsTableViewHeight: NSLayoutConstraint!
    
    private var refreshControl: UIRefreshControl!
    
    private var friendsType = FriendsViewModel.FriendsType.noFriend
    private let viewModel = FriendsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        // Binding
        self.setupBinding()
        
        // TableView
        self.setupTableView()
        self.setupInvitedFriendsTableView()
        
        // SearchBar
        self.searchBar.delegate = self
        
        // Get user Info
        self.viewModel.fetchUserInfo()
    }
    
    private func setupUI() {
        let attributedString = NSMutableAttributedString(string: "幫助好友更快找到你？")
        attributedString.append(NSAttributedString(string: "設定 KOKO ID", attributes: [
            .foregroundColor: UIColor.systemPink,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]))
        self.hintLabel.attributedText = attributedString
        
        self.segmentedControl.addTarget(self, action: #selector(segmentControlDidChange), for: .valueChanged)
    }
    
    @objc func segmentControlDidChange() {
        if self.viewModel.hasFriendsList == false {
            return
        }
        
        self.friendListContainer.isHidden = !(self.segmentedControl.selectedSegmentIndex == 0)
        self.chatListContainer.isHidden = !(self.segmentedControl.selectedSegmentIndex == 1)
    }
    
    private func setupBinding() {
        self.viewModel.$userName
            .assign(to: \.text, on: self.nameLabel)
            .store(in: &self.cancellables)
        
        self.viewModel.$userId
            .map { value in
                String(format: "Koko ID: %@", value ?? "")
            }
            .assign(to: \.text, on: self.userIdLabel)
            .store(in: &self.cancellables)
        
        self.viewModel.$hasFriendsList
            .sink { value in
                guard let value else {
                    return
                }
                self.addFriendContainer.isHidden = value
                self.friendListContainer.isHidden = !value
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$invitedFriendListHeight
            .assign(to: \.constant, on: self.invitedFriendsTableViewHeight)
            .store(in: &cancellables)
    }
    
    private func setupTableView() {
        self.tableView.rowHeight = 60
        self.tableView.register(UINib(nibName: "BestFriendsRowCell", bundle: nil),
                                forCellReuseIdentifier: "BestFriendsRowCell")
        self.viewModel.bestFriendsDataSource = FriendsViewModel.DataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "BestFriendsRowCell") as! BestFriendsRowCell
            if let data = self.viewModel.bestFriendsDataSource?.itemIdentifier(for: indexPath) {
                cell.configure(data)
            }
            return cell
        }
        self.tableView.dataSource = self.viewModel.bestFriendsDataSource
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    private func setupInvitedFriendsTableView() {
        self.invitedFriendsTableView.rowHeight = 80
        self.invitedFriendsTableView.register(UINib(nibName: "InvitedFriendsRowCell", bundle: nil),
                                              forCellReuseIdentifier: "InvitedFriendsRowCell")
        self.viewModel.invitedFriendsDataSource = FriendsViewModel.DataSource(tableView: self.invitedFriendsTableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "InvitedFriendsRowCell") as! InvitedFriendsRowCell
            if let data = self.viewModel.invitedFriendsDataSource?.itemIdentifier(for: indexPath) {
                cell.configure(data)
            }
            return cell
        }
        self.invitedFriendsTableView.dataSource = self.viewModel.invitedFriendsDataSource
    }
    
    @objc private func reloadData() {
        self.viewModel.fetchFriends(by: self.friendsType) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func actionNoFriendButton(_ sender: Any) {
        self.selectionContainer.isHidden = true
        self.friendsType = .noFriend
        self.reloadData()
    }
    
    @IBAction func actionBestFriendsButton(_ sender: Any) {
        self.selectionContainer.isHidden = true
        self.friendsType = .bestFriends
        self.reloadData()
    }
    
    @IBAction func actionAllFriendsButton(_ sender: Any) {
        self.selectionContainer.isHidden = true
        self.friendsType = .allFriends
        self.reloadData()
    }
}

extension FriendsViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.3) {
            self.headerContainer.alpha = 0
            self.bodyTopConstraint.priority = .defaultLow
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.filterBestFriendsData(by: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.viewModel.filterBestFriendsData(by: nil)
        
        UIView.animate(withDuration: 0.1) {
            self.headerContainer.alpha = 1
            self.bodyTopConstraint.priority = .required
            self.view.layoutIfNeeded()
        }
    }
}

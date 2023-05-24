//
//  SettingsViewController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/05/23.
//

import UIKit

class SettingsViewController: UITableViewController {
    // MARK: - Properties
    var user: User
    private lazy var infoHeader:  UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 110)
        let view =  UserInfoHeader(user: self.user, frame: frame)
        return view
    }()
    // MARK: - LifeCycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .blue
        configureTableView()
        configureNavBr()
    }
    // MARK: - Helpers
    
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        tableView.register(LocationCell.self,
                           forCellReuseIdentifier: LocationCell.reuseIdentifier)
        tableView.tableHeaderView = infoHeader
    }
    
    func configureNavBr() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.backgroundColor = .backgroundColor
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationItem.title = "Settings"
        let image = #imageLiteral(resourceName: "baseline_clear_white_36pt_2x")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDissmisal))
    }
    // MARK: - Selectors
    
    @objc func handleDissmisal() {
        self.dismiss(animated: true)
    }
}

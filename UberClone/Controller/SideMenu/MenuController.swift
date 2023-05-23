//
//  MenuController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/05/23.
//

import UIKit

private enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}

class MenuController: UITableViewController {
    //MARK: - Properties
    private let user: User
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0,
                           width: self.view.frame.width, height: 140)
        
        let view = MenuHeader(user: user, frame: frame)
        return view
    }()
    
    //MARK: - LifeCicle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureTableView()
    }
    //MARK: - Helpers
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.self.description())
        tableView.tableHeaderView = menuHeader
    }

    
    //MARK: - Selectors
    
}

extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MenuOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.self.description(),
                                                 for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = MenuOptions.allCases[indexPath.row].description
        cell.contentConfiguration = content
        return cell
    }
}

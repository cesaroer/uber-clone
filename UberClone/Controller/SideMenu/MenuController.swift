//
//  MenuController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/05/23.
//

import UIKit

class MenuController: UITableViewController {
    //MARK: - Properties
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0,
                           width: self.view.frame.width, height: 140)
        
        let view = MenuHeader(frame: frame)
        return view
    }()
    
    //MARK: - LifeCicle
    
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.self.description(),
                                                 for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = "Menu option"
        cell.contentConfiguration = content
        return cell
    }
}

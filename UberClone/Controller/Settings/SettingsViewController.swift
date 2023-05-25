//
//  SettingsViewController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/05/23.
//

import UIKit

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }

    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}

class SettingsViewController: UITableViewController {
    // MARK: - Properties
    var user: User
    private let locationManager = LocationHandler.shared.locationManager
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
        tableView.tableFooterView = UIView()
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

// MARK: - TABLE VIEW DELEGATES
extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier,
                                                 for: indexPath) as! LocationCell

        cell.type = LocationType(rawValue: indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) ,
              let location = locationManager?.location else { return }
        let vc = AddLocationViewController(type: type, location: location)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
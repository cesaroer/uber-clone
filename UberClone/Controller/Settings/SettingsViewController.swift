//
//  SettingsViewController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/05/23.
//

import UIKit

protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ controller: SettingsViewController, user: User)
}

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
    weak var delegate: SettingsControllerDelegate?
    private let locationManager = LocationHandler.shared.locationManager
    private lazy var infoHeader:  UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 110)
        let view =  UserInfoHeader(user: self.user, frame: frame)
        return view
    }()
    var userInfoUpdated = false

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
    func locationText(fortYype type: LocationType ) -> String {
        switch type {
        case .home: return user.homeLocation ?? type.subtitle
        case .work: return user.workLocation ?? type.subtitle
        }
    }

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
        if self.userInfoUpdated {
            self.delegate?.updateUser(self, user: self.user)
        }
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

        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(fortYype: type)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) ,
              let location = locationManager?.location else { return }
        let vc = AddLocationViewController(type: type, location: location)
        vc.delegate = self

        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - AddLocationControllerDelegate
extension SettingsViewController: AddLocationControllerDelegate {
    func updateLocation(locationString: String, type: LocationType) {
        PassengerService.shared.saveFavoriteLocation(locationName: locationString, type: type) { (err,ref) in
            
            self.userInfoUpdated = err == nil
            
            if self.userInfoUpdated {
                self.delegate?.updateUser(self, user: self.user)
            }

            self.navigationController?.popViewController(animated: true)
            switch type {
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            


            self.tableView.reloadData()
        }
    }
    
}

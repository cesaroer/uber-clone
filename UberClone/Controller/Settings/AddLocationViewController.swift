//
//  AddLocationViewController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/05/23.
//

import UIKit
import MapKit

protocol AddLocationControllerDelegate: AnyObject {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationViewController: UITableViewController {

    // MARK: - Properties
    weak var delegate: AddLocationControllerDelegate?
    private var searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion](){
        didSet {
            tableView.reloadData()
        }
    }
    private var type: LocationType
    private var location: CLLocation
    
    // MARK: - Lifecycle
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }

    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    // MARK: - Helpers
    func configureTableView() {
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.self.description())
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60

        tableView.addShadow()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate =  self
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
    // MARK: - Selectors
}

// MARK: - UISearchBarDelegate and MKLocalSearchCompleterDelegate
extension AddLocationViewController: UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}

// MARK: - TABLEVIEW DELEGATES
extension AddLocationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.self.description(),
                                                 for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = searchResults[indexPath.row].title
        content.secondaryText = searchResults[indexPath.row].subtitle
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        var locationString = title + " " + subtitle
        locationString = locationString.replacingOccurrences(of: ", United States", with: "")
        delegate?.updateLocation(locationString: locationString, type: self.type)
    }
}

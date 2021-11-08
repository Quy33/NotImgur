//
//  DetailTableViewController.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    static let identifier = "DetailTableView"
    private let cellIdentifier = "detailCell"
    
    var id = "KVRunTh"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.dataSource = self
        print(id)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = id
        cell.contentConfiguration = config
        return cell
    }
}

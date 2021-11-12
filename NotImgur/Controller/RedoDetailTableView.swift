//
//  RedoDetailTableView.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 12/11/2021.
//

import UIKit

class RedoDetailTableView: UITableViewController {
    
    static let identifier = "RedoDetailTableView"
    
    var itemGot = (id: "KxiXTUT",isAlbum: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        // Configure the cell...

        return cell
    }

    //MARK: Table View Delegate
    
    //MARK: Misc Functions
    func registerCell() {
        let nib = UINib(nibName: DetailCell.identifier, bundle: nil)
        tableView.register(nib , forCellReuseIdentifier: DetailCell.identifier)
    }
}

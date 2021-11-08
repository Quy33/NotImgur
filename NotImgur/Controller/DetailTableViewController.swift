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
    private let contents = [UIImageView]()
    private var imgurManager = ImgurNetworkManager()
    
    let image = (id: "Y4vvsE8",isAlbum: false)
    let album = (id: "vkpV5WE",isAlbum: true)
    
    //var tuple = (id: "vkpV5WE",is_album: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                try await imgurManager.getDetail(with: image)
                try await imgurManager.getDetail(with: album)
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = album.id
        cell.contentConfiguration = config
        return cell
    }
}

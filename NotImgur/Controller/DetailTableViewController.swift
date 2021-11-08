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
    
    private let image = ImageDetailItem()
    private let album = AlbumDetailItem()
    
    let imageGot = (id: "Y4vvsE8",isAlbum: false)
    let albumGot = (id: "vkpV5WE",isAlbum: true)
    
    //var tuple = (id: "vkpV5WE",is_album: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let model = try await imgurManager.getDetail(with: albumGot)
                //let model = try await imgurManager.getDetail(with: image)
                //item = imgurManager.getDetailItem(model)
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

        config.text = albumGot.id
        cell.contentConfiguration = config
        
        return cell
    }
}

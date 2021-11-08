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
    
    lazy var item: ImgurDetailItem = {
        if image.isAlbum {
            return AlbumDetailItem()
        } else {
            return ImageDetailItem()
        }
    }()
    //var tuple = (id: "vkpV5WE",is_album: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let model = try await imgurManager.getDetail(with: album)
                //let model = try await imgurManager.getDetail(with: image)
                item = imgurManager.getDetailItem(model)
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let album = item as? AlbumDetailItem else {
            return 1
        }
        return album.images.count
        //return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        guard let album = item as? AlbumDetailItem else {
            return cell
        }
        config.text = album.title
        cell.contentConfiguration = config
        
        return cell
    }
}

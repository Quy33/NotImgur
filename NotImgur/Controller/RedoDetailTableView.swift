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
    
    private var imgurManager = ImgurNetworkManager()
//    private var dummy = AlbumDetailItem(title: <#T##String#>, description: <#T##String?#>, images: <#T##[ImageDetailItem]#>)

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        
        Task {
//            let model = try await imgurManager.getDetail(with: itemGot)
//            print(model.data.title)
//            print(model.data.description)
//            print(model.data.images?.count)
//            for item in model.data.images! {
//                print(item.title)
//                print(item.description)
//            }
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        // Configure the cell...
        if indexPath.row == 0 {
            cell.config(image: UIImage(named: "placeholder")!, title: nil, desc: nil)
        } else {
        cell.config(image: UIImage(named: "placeholder")!, title: "Test Title", desc: "Test Description")
        }
        return cell
    }

    //MARK: Table View Delegate
    
    //MARK: Misc Functions
    func registerCell() {
        let nib = UINib(nibName: DetailCell.identifier, bundle: nil)
        tableView.register(nib , forCellReuseIdentifier: DetailCell.identifier)
    }
}

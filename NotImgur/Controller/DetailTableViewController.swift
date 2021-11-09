//
//  DetailTableViewController.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import UIKit
import AVKit
import AVFoundation

class DetailTableViewController: UITableViewController {
    
    static let identifier = "DetailTableView"
    private let cellIdentifier = "detailCell"
    private let contents = [UIImageView]()
    private var imgurManager = ImgurNetworkManager()
    
    private var image = ImageDetailItem()
    private var album = AlbumDetailItem()
    
    var itemGot = (id: "Y4vvsE8",isAlbum: false)
    //var itemGot = (id: "vkpV5WE",isAlbum: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
        
        Task {
            do {
                let model = try await imgurManager.getDetail(with: itemGot)
                
                if itemGot.isAlbum {
//                    album = getAlbumDetail(model)
//                    let urls = album.images.compactMap { $0.url }
//
//                    let images = try await imgurManager.multipleDownload(with: urls)
                    for i in 0..<album.images.count {
//                        album.images[i].image = images[i]
                        print(album.images[i].title)
                        print(album.images[i].description)
                    }
                } else {
//                    image = ImageDetailItem(title: model.data.title, description: model.data.description, link: model.data.link, animated: model.data.animated!, mp4: model.data.mp4)
//                    image.image = try await imgurManager.singleDownload(with: image.url!)
                    print(image.title)
                    print(image.description)
                }
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    func getAlbumDetail(_ model: DetailModel) -> AlbumDetailItem {
        var newAlbum = AlbumDetailItem(title: model.data.title, images: [])
        let item = model.data.images!
        for image in item {
            let newImage = ImageDetailItem(title: image.title, description: image.description, link: image.link, animated: image.animated, mp4: image.mp4)
            newAlbum.images.append(newImage)
        }
        return newAlbum
    }
    func calculateHeight(_ pictureSize: CGSize)->CGFloat{
        let deviceSize = view.frame.size
        let wOffSet = pictureSize.width - deviceSize.width
        let wOffSetPercent = (wOffSet*100)/pictureSize.width
        let hOffSet = (wOffSetPercent*pictureSize.height)/100
        let newHeight = pictureSize.height - hOffSet
        return newHeight
    }
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) {
            vc.player?.play()
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        if itemGot.isAlbum {
            cell.config(image: album.images[indexPath.row].image)
        } else {
            cell.config(image: image.image)
        }
        return cell
    }
//MARK: TableView Delegate Method
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeight(image.image.size)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemGot.isAlbum {
            let item = album.images[indexPath.row]
            if item.animated {
                guard let url = URL(string: item.mp4!) else {
                    return
                }
                playVideo(url: url)
            }
        } else {
            if image.animated {
                guard let url = URL(string: image.mp4!) else { return }
                playVideo(url: url)
            }
            
        }
    }
}

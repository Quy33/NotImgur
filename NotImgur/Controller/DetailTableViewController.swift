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
    private let contents = [UIImageView]()
    private var imgurManager = ImgurNetworkManager()
    
    private var album = AlbumDetailItem()
    private var image = ImageDetailItem(title: "Place Holder", description: "Place Holder")
    private var heights = [CGFloat]()
    
    //var itemGot = (id: "ekIqbY2",isAlbum: true)
    var itemGot = (id: "KxiXTUT",isAlbum: true)
    //var itemGot = (id: "MIvOvIl",isAlbum: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageDetailItem.thumbnailSize = .largeThumbnail
        
        tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
        print(itemGot)
        
        Task {
            do {
                let model = try await imgurManager.getDetail(with: itemGot)

                if itemGot.isAlbum {
                    album = getAlbumDetail(model)
                    let urls = album.images.compactMap { $0.url }
                    print(urls)

                    let images = try await imgurManager.multipleDownload(with: urls)
                    for i in 0..<album.images.count {
                        album.images[i].image = images[i]
                    }
                    heights = images.map { calculateHeight($0.size) + 50 }
                } else {
                    image = ImageDetailItem(title: model.data.title, description: model.data.description, link: model.data.link, animated: model.data.animated!, mp4: model.data.mp4)
                    image.image = try await imgurManager.singleDownload(with: image.url!)
                }
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    private func getAlbumDetail(_ model: DetailModel) -> AlbumDetailItem {
        var newAlbum = AlbumDetailItem(title: model.data.title, description: model.data.description, images: [])
        let items = model.data.images!
        for image in items {
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
    private func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) {
            vc.player?.play()
        }
    }
// MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemGot.isAlbum {
            return album.images.count
        } else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        if itemGot.isAlbum {
            let albumItem = album.images[indexPath.row]
            
            let albumDesc = album.description
            let albumItemDesc = albumItem.description
            let description = albumDesc != nil ? albumDesc : albumItemDesc
            
            var title : String?
            if indexPath.row == 0 {
                title = album.title
            } else { title = album.images[indexPath.row].title }
//            cell.config(image: albumItem.image, title: title, desc: description)
            cell.config(image: albumItem.image, title: title, desc: nil)
        } else {
//            cell.config(image: image.image, title: image.title, desc: image.description)
            cell.config(image: image.image, title: image.title, desc: image.description)
        }
        
        //height.append(cell.frame.height)
        return cell
    }
//MARK: TableView Delegate Method
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let placeHolderImg = UIImage(named: "placeholder")!
        guard !heights.isEmpty else {
            return placeHolderImg.size.height
        }
        return heights[indexPath.row]
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
//MARK: Button
    
}

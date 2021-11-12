////
////  DetailTableViewController.swift
////  NotImgur
////
////  Created by Mcrew-Tech on 08/11/2021.
////
//
//import UIKit
//import AVKit
//import AVFoundation
////MARK: Top
////
////class DetailTableViewController: UITableViewController {
////
////    static let identifier = "DetailTableView"
////    private var imgurManager = ImgurNetworkManager()
////
////    private var album = AlbumDetailItem()
////    private var image = ImageDetailItem(title: "", description: "")
////
////    private var heights = [CGFloat]()
////    private var stackWidth: CGFloat = 0
////    private var isCached = false
////    private var isDownloaded = false
////
////    //var itemGot = (id: "ekIqbY2",isAlbum: true)
////    var itemGot = (id: "KxiXTUT",isAlbum: true)
////    //var itemGot = (id: "ydZ1jjx", isAlbum: true)
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        ImageDetailItem.thumbnailSize = .largeThumbnail
////
////        tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
//////        tableView.estimatedRowHeight = 640
//////        tableView.rowHeight = UITableView.automaticDimension
////        print(itemGot)
////
////
////        Task {
////            do {
////                let model = try await imgurManager.getDetail(with: itemGot)
////
////                if itemGot.isAlbum {
////                    album = getAlbumDetail(model)
////                    let urls = album.images.compactMap { $0.url }
////
////                    let images = try await imgurManager.multipleDownload(with: urls)
////                    heights = .init(repeating: 0, count: images.count)
////                    for i in 0..<album.images.count {
////                        album.images[i].image = images[i]
//////                        print(album.images[i].title)
//////                        print(album.images[i].description)
////                    }
////                    heights = images.map { calculateHeight($0.size) }
//////                    heights = .init(repeating: 0.0, count: images.count)
//////                    print(album.title)
//////                    print(album.description)
////                } else {
////                    image = ImageDetailItem(title: model.data.title, description: model.data.description, link: model.data.link, animated: model.data.animated!, mp4: model.data.mp4)
////                    image.image = try await imgurManager.singleDownload(with: image.url!)
////                    let calculatedHeight = calculateHeight(image.image.size)
////                    heights = [calculatedHeight]
//////                    print(image.title)
//////                    print(image.description)
////                }
////                print("begin reloading data")
////                isDownloaded = true
////                tableView.reloadData()
////            } catch {
////                print(error)
////            }
////        }
////    }
////
////    private func getAlbumDetail(_ model: DetailModel) -> AlbumDetailItem {
////        var newAlbum = AlbumDetailItem(title: model.data.title, description: model.data.description, images: [])
////        let items = model.data.images!
////        for image in items {
////            let newImage = ImageDetailItem(title: image.title, description: image.description, link: image.link, animated: image.animated, mp4: image.mp4)
////            newAlbum.images.append(newImage)
////        }
////        return newAlbum
////    }
////    func calculateHeight(_ pictureSize: CGSize)->CGFloat{
////        let deviceSize = view.frame.size
////        let wOffSet = pictureSize.width - deviceSize.width
////        let wOffSetPercent = (wOffSet*100)/pictureSize.width
////        let hOffSet = (wOffSetPercent*pictureSize.height)/100
////        let newHeight = pictureSize.height - hOffSet
////        return newHeight
////    }
////    private func playVideo(url: URL) {
////        let player = AVPlayer(url: url)
////
////        let vc = AVPlayerViewController()
////        vc.player = player
////
////        self.present(vc, animated: true) {
////            vc.player?.play()
////        }
////    }
////// MARK: - Table view data source
////
////    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        if itemGot.isAlbum {
////            return album.images.count
////        } else {
////            return 1
////        }
////    }
////    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        print("Dequeueing Cell")
////        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
////        if itemGot.isAlbum {
////            let albumItem = album.images[indexPath.row]
////
////            let albumDesc = album.description
////            let albumItemDesc = albumItem.description
////            let description = albumDesc != nil ? albumDesc : albumItemDesc
////
////            var title : String?
////            if indexPath.row == 0 {
////                title = album.title
////            } else { title = album.images[indexPath.row].title }
//////            cell.config(image: albumItem.image, title: title, desc: description)
////            cell.config(image: albumItem.image, title: title ?? "", desc: description ?? "", isDownload: isDownloaded)
////
////        } else {
//////            cell.config(image: image.image, title: image.title, desc: image.description)
////            cell.config(image: image.image, title: image.title, desc: image.description, isDownload: isDownloaded)
////        }
////        return cell
////    }
//////MARK: TableView Delegate Method
////    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        print("Doing Height \(indexPath.row)")
////        let placeHolderImg = UIImage(named: "placeholder")!
////        guard !heights.isEmpty else {
////            return placeHolderImg.size.height
////        }
////        return heights[indexPath.row]
////    }
////    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
////        print("Cell will begin displaying")
////        if let detailCell = cell as? DetailCell {
////            print(detailCell.titleLabel?.frame.height)
////            if detailCell.titleLabel?.frame.height == 0.0 {
////                if !isCached {
////                    var titleHeight: CGFloat
////                    var descHeight: CGFloat
////                    if itemGot.isAlbum {
////                        for (index,item) in album.images.enumerated() {
////
////                            titleHeight = 0.0
////                            descHeight = 0.0
////
////                            if index == 0 {
////
////                                titleHeight = heightForView(text: album.title, font: .systemFont(ofSize: 17), width: detailCell.stackWidth)
////
////                                let description = album.description != nil ? album.description : item.description
////                                if let albumDescription = description {
////                                    descHeight = heightForView(text: albumDescription , font: .systemFont(ofSize: 17), width: detailCell.stackWidth)
////                                }
////                            } else {
////                                if let albumTitle = item.title {
////                                    titleHeight = heightForView(text: albumTitle, font: .systemFont(ofSize: 17), width: detailCell.stackWidth)
////                                }
////                                if let albumDescription = item.description {
////                                    descHeight = heightForView(text: albumDescription , font: .systemFont(ofSize: 17), width: detailCell.stackWidth)
////                                }
////                            }
//////                            print(titleHeight)
//////                            print(descHeight)
////                            heights[index] += titleHeight + descHeight
////                        }
////                    } else {
////                        descHeight = 0.0
////                        titleHeight = heightForView(text: image.title!, font: .systemFont(ofSize: 17), width: stackWidth)
////                        if let imageDescription = image.description {
////                            descHeight = heightForView(text: imageDescription, font: .systemFont(ofSize: 17), width: stackWidth)
////                        }
////                        heights[0] += titleHeight + descHeight
////                    }
////                    isCached = true
////                    tableView.reloadData()
////                }
////            }
////        }
////    }
////
////    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        if itemGot.isAlbum {
////            let item = album.images[indexPath.row]
////            if item.animated {
////                guard let url = URL(string: item.mp4!) else {
////                    return
////                }
////                playVideo(url: url)
////            }
////        } else {
////            if image.animated {
////                guard let url = URL(string: image.mp4!) else { return }
////                playVideo(url: url)
////            }
////        }
////        if let cell = tableView.cellForRow(at: indexPath) as? DetailCell {
////            //...
////            print(heights[indexPath.row])
////            //print(cell.frame.height)
////            print(cell.titleLabel?.frame.height)
////            print(cell.descriptionLabel?.frame.height)
////            print(calculateHeight(album.images[indexPath.row].image.size))
////            print(cell.cellImage?.frame.height)
////            print(album.images[indexPath.row].description)
////            print(album.title)
////        }
////    }
////MARK: Redo TableView
////MARK: Misc Functions
//    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = .byTruncatingTail
//        label.font = font
//        label.text = text
//
//        label.sizeToFit()
//        return label.frame.height
//    }
//    func registerCell() {
//        tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)
//    }
//}

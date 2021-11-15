//
//  RedoDetailTableView.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 12/11/2021.
//

import UIKit

class RedoDetailTableView: UITableViewController {
    
    static let identifier = "RedoDetailTableView"
    
    //var itemGot = (id: "KxiXTUT",isAlbum: true)
    //var itemGot = (id: "Oi4EWz4", isAlbum: true)
    var itemGot = (id: "OozMaVC", isAlbum: false)
    
    private var imgurManager = ImgurNetworkManager()
    private var isCached = false
    private var heights: [CGFloat] = []
    
    private var album = AlbumDetailItem()
    private var image = ImageDetailItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell(DetailCell.identifier)
        ImageDetailItem.thumbnailSize = .hugeThumbnail
        ImageDetailItem.isThumbnail = false
        
        print(itemGot)
        //Top
        Task {
            do {
                let model = try await imgurManager.getDetail(with: itemGot)
                if itemGot.isAlbum {
                    album = getAlbumDetail(model)
                    let urls = album.images.compactMap{ $0.url }
                    let images = try await imgurManager.multipleDownload(with: urls)

                    for (index,item) in album.images.enumerated() {
                        item.image = images[index]
                    }

                    heights = .init(repeating: 0.0, count: album.images.count)
                    print(album.title)
                    print(album.description)
                    print(album.images[0].title)
                    print(album.images[0].description)
                } else {
                    image = ImageDetailItem(title: model.data.title, description: model.data.description, link: model.data.link, animated: model.data.animated!, mp4: model.data.mp4)
                    guard let url = image.url else {
                        throw ImgurNetworkManager.ImageDownloadError.badURL
                    }
                    let newImage = try await imgurManager.singleDownload(with: url)
                    image.image = newImage
                    heights.append(0.0)
                }
                tableView.reloadData()
            } catch {
                print(error)
            }
           
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard !heights.isEmpty else {
            return 0
        }
        if itemGot.isAlbum {
            return album.images.count
        } else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        
        guard !heights.isEmpty else {
            return cell
        }
        
        if itemGot.isAlbum {
            
            // Configure the cell...
            
            let item = album.images[indexPath.row]
            
            if album.images.count == 1 {
                cell.config(image: item.image, title: item.title, desc: item.description, top: album.title, bottom: album.description, isLast: true)
            } else {
                if indexPath.row == 0 {
                    //Top
                    cell.config(image: item.image, title: item.title, desc: item.description, top: album.title, bottom: nil, isLast: false)
                }else if indexPath.row == album.images.count - 1 {
                    //Bottom
                    cell.config(image: item.image, title: item.title, desc: item.description, top: nil, bottom: album.description, isLast: true)
                } else {
                    cell.config(image: item.image, title: item.title, desc: item.description, top: nil, bottom: nil, isLast: false)
                }
            }
        } else {
            cell.config(image: image.image, title: nil, desc: nil, top: image.title, bottom: image.description, isLast: true)
        }
        return cell
    }

    //MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard isCached else {
            return 0
        }
        return heights[indexPath.row]
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let detailCell = cell as? DetailCell else{
            return
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if !heights.isEmpty {
            if !isCached {
                calculateHeights(cell: detailCell, isAlbum: itemGot.isAlbum)
                isCached = true
                tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    //MARK: Height Functions
    func calculateHeight(_ pictureSize: CGSize, frameWidth width: CGFloat )->CGFloat{
        let wOffSet = pictureSize.width - width
        let wOffSetPercent = (wOffSet*100)/pictureSize.width
        let hOffSet = (wOffSetPercent*pictureSize.height)/100
        let newHeight = pictureSize.height - hOffSet
        return newHeight
    }
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    private func calculateHeights(cell detailCell: DetailCell ,isAlbum: Bool) {
        
        let labelHInsets: CGFloat = 10 * 2
        let labelVInsets: CGFloat = 20 * 2
        let separator = detailCell.separatorHeight
        
        let frameWidth = detailCell.outerView!.frame.width
        let labelFrameWidth = frameWidth - labelHInsets
        
        if isAlbum {
            for (index,item) in album.images.enumerated() {

                var titleHeight = heightForView(text: item.title ?? "", font: .systemFont(ofSize: 17), width: labelFrameWidth)
                var descHeight = heightForView(text: item.description ?? "", font: .systemFont(ofSize: 17), width: labelFrameWidth)
                let imageHeight = calculateHeight(item.image.size, frameWidth: frameWidth)
                
                titleHeight = titleHeight != 0 ? titleHeight + labelVInsets : titleHeight
                descHeight = descHeight != 0 ? descHeight + labelVInsets : descHeight
                
                heights[index] = titleHeight + descHeight + imageHeight

                switch index {
                case 0:
                    
                    var topTitleHeight = heightForView(text: album.title, font: .systemFont(ofSize: 17), width: labelFrameWidth)
                    
                    topTitleHeight += labelVInsets
                    
                    if album.images.count == 1 {
                        var bottomDescHeight = heightForView(text: album.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                        
                        bottomDescHeight = bottomDescHeight != 0 ? bottomDescHeight + labelVInsets : bottomDescHeight
                        
                        heights[index] += topTitleHeight + bottomDescHeight
                    } else {
                        
                        heights[index] += topTitleHeight + separator
                    }
                    
                case album.images.count - 1:
                    var bottomDescHeight = heightForView(text: album.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                    
                    bottomDescHeight = bottomDescHeight != 0 ? bottomDescHeight + labelVInsets : bottomDescHeight
                    
                    heights[index] += bottomDescHeight
                    
                default:
                    heights[index] += separator
                }
            }
        } else {
            let topTitleHeight = heightForView(text: image.title!, font: .systemFont(ofSize: 17), width: frameWidth)
            let imageHeight = calculateHeight(image.image.size, frameWidth: frameWidth)
            let bottomDescHeight = heightForView(text: image.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
            
            let height = topTitleHeight + imageHeight + bottomDescHeight
            heights.append(height)
        }
    }
    //MARK: Cell Function
    func registerCell(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib , forCellReuseIdentifier: identifier)
    }
    //MARK: Album Function
    private func getAlbumDetail(_ model: DetailModel) -> AlbumDetailItem {
        var newAlbum = AlbumDetailItem(title: model.data.title, description: model.data.description, images: [])
        let items = model.data.images!
        for image in items {
            let newImage = ImageDetailItem(title: image.title, description: image.description, link: image.link, animated: image.animated, mp4: image.mp4)
            newAlbum.images.append(newImage)
        }
        return newAlbum
    }
}

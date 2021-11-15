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
    var itemGot = (id: "Oi4EWz4", isAlbum: true)
    
    private var imgurManager = ImgurNetworkManager()
    private var isCached = false
    private var heights: [CGFloat] = []
    
    private var album = AlbumDetailItem()
    private var image = ImageDetailItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell(DetailCell.identifier)
        ImageDetailItem.thumbnailSize = .mediumThumbnail
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
                    heights[0] = 0.0
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
        if itemGot.isAlbum {
            guard !album.images.isEmpty else {
                return 0
            }
            return album.images.count
        } else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        
        if itemGot.isAlbum {
            guard !album.images.isEmpty else {
                return cell
            }
            // Configure the cell...
            
            let item = album.images[indexPath.row]
            
            if album.images.count == 1 {
                cell.config(image: item.image, title: item.title, desc: item.description, top: album.title, bottom: album.description)
            } else {
                if indexPath.row == 0 {
                    //Top
                    cell.config(image: item.image, title: item.title, desc: item.description, top: album.title, bottom: nil)
                }else if indexPath.row == album.images.count - 1 {
                    //Bottom
                    cell.config(image: item.image, title: item.title, desc: item.description, top: nil, bottom: album.description)
                } else {
                    cell.config(image: item.image, title: item.title, desc: item.description, top: nil, bottom: nil)
                }
            }
        } else {
            cell.config(image: image.image, title: nil, desc: nil, top: image.title, bottom: image.description)
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
        
        let horizontalInset: CGFloat = 10 * 2
        let verticalInset: CGFloat = 10 * 2
        
        let frameWidth = detailCell.outerView!.frame.width - horizontalInset
        var paddingCount = 0
        let padding: CGFloat = 5
        if isAlbum {
            for (index,item) in album.images.enumerated() {

                let titleHeight = heightForView(text: item.title ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                let descHeight = heightForView(text: item.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                let imageHeight = calculateHeight(item.image.size, frameWidth: frameWidth)
                heights[index] = titleHeight + descHeight + imageHeight + verticalInset
                
                paddingCount = descHeight != 0.0 ? paddingCount + 1 : paddingCount

                switch index {
                case 0:
                    
                    let topTitleHeight = heightForView(text: album.title, font: .systemFont(ofSize: 17), width: frameWidth)
                    
                    if album.images.count == 1 {
                        let bottomDescHeight = heightForView(text: album.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                        
                        paddingCount += 1
                        paddingCount = bottomDescHeight != 0.0 ? paddingCount + 1 : paddingCount
                        
                        heights[index] = topTitleHeight + bottomDescHeight + heights[index] + (padding * CGFloat(paddingCount))
                        print(paddingCount)
                    } else {
                        
                        heights[index] = topTitleHeight + heights[index] + (padding * CGFloat(paddingCount))
                    }
                    
                case album.images.count - 1:
                    let bottomDescHeight = heightForView(text: album.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)

                    heights[index] = bottomDescHeight + heights[index] + (padding * CGFloat(paddingCount))
                    
                default:
                    heights[index] = heights[index] + (padding * CGFloat(paddingCount))
                }
            }
        } else {
            let topTitleHeight = heightForView(text: image.title!, font: .systemFont(ofSize: 17), width: frameWidth)
            let imageHeight = calculateHeight(image.image.size, frameWidth: frameWidth)
            let bottomDescHeight = heightForView(text: image.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
            
            let height = topTitleHeight + imageHeight + bottomDescHeight + horizontalInset
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

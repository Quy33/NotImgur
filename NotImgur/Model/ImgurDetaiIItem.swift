//
//  ImgurDetaiItem.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import Foundation
import UIKit

class ImageDetailItem {

    var title: String?
    
    var description: String?
    
    var link: String
    
    var animated: Bool
    
    var mp4: String?
    
    var image: UIImage
    
    static var thumbnailSize: ImgurNetworkManager.ThumbnailSize = .mediumThumbnail
    
    static var isThumbnail = true
            
    var url: URL? {
        var newLink = ""
        if ImageDetailItem.isThumbnail {
            newLink = animated ? concatStr(with: mp4!) : concatStr(with: link)
        } else {
            newLink = animated ? concatStr(with: mp4!) : link
        }
        return URL(string: newLink)
    }
    private func concatStr(with string: String) -> String {
        var result = string
        guard let i = result.lastIndex(of: ".") else {
            return ""
        }
        result.insert(ImageDetailItem.thumbnailSize.rawValue, at: i)
        return result
    }
    convenience init() {
        self.init(title: "", description: "")
    }
    convenience init(title: String, description: String) {
        self.init(title: title, description: description, link: "", animated: false, mp4: nil)
    }
    init(title: String?, description: String?, link: String, animated: Bool, mp4: String?, image : UIImage = UIImage(named: "placeholder")!) {
        self.title = title
        self.description = description
        self.link = link
        self.animated = animated
        self.mp4 = mp4
        self.image = image
    }
}
struct AlbumDetailItem {
    var title : String
    var description: String?
    var images : [ImageDetailItem]
    init() {
        title = ""
        description = nil
        images = [ImageDetailItem()]
    }
    init(title: String, description: String?, images: [ImageDetailItem]) {
        self.title = title
        self.description = description
        self.images = images
    }
}

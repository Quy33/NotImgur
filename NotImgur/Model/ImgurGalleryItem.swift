//
//  Image.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import Foundation
import UIKit

struct ImgurGalleryItem {
    var id: String
    var isAlbum: Bool
    var image: UIImage
    var type: String
    var title: String
    init() {
        id = ""
        isAlbum = false
        image = UIImage(named: "placeholder")!
        type = ""
        title = ""
    }
    init(id: String, is_album: Bool, image: UIImage, type: String, title: String) {
        self.id = id
        isAlbum = is_album
        self.image = image
        self.type = type
        self.title = title
    }
}

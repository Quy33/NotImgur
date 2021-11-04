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
    init() {
        id = ""
        isAlbum = false
        image = UIImage(named: "placeholder")!
    }
    init(id: String, is_album: Bool, image: UIImage) {
        self.id = id
        isAlbum = is_album
        self.image = image
    }
}

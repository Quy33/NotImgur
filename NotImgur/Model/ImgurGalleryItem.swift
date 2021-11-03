//
//  Image.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import Foundation
import UIKit

struct ImgurGalleryItem {
    let id: String
    let isAlbum: Bool
    init() {
        id = ""
        isAlbum = false
    }
    init(id: String, is_album: Bool) {
        self.id = id
        isAlbum = is_album
    }
}

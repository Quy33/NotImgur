//
//  ImageModel.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import Foundation

struct GalleryModel: Decodable {
    let data: [SingleImage]
}
struct SingleImage: Decodable {
    let id: String
    let link: String
    let title: String
    let type: String?
    let mp4: String?
    let gifv: String?
    let animated: Bool?
    let images: [MultiImage]?
    let is_album: Bool
}
struct MultiImage: Decodable {
    let type: String
    let link: String
    let mp4: String?
    let gifv: String?
    let animated: Bool
}



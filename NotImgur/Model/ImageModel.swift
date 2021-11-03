//
//  ImageModel.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import Foundation

struct ImageModel: Decodable {
    let data: [SingleImage]
}
struct SingleImage: Decodable {
    let id: String
    let link: String
    let images: [MultiImage]?
    let is_album: Bool
}
struct MultiImage: Decodable {
    let link: String
}

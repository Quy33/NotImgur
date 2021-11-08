//
//  DetailModel.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import Foundation

struct DetailModel: Decodable {
    let data: Content
}
struct Content: Decodable {
    let id: String
    let title: String
    let description: String?
    let link: String
    let mp4: String?
    let type: String?
    let animated: Bool?
    let images: [AlbumContent]?
}
struct AlbumContent: Decodable {
    let id: String
    let title: String?
    let description: String?
    let link: String
    let type: String
    let animated: Bool
    let mp4: String?
}

//
//  ImgurDetaiItem.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import Foundation

struct ImageDetailItem {

    var title: String? = nil
    
    var description: String? = nil
    
    var link: String = ""
    
    var animated: Bool = false
    
    var mp4: String? = nil
        
    var url: String {
        let newLink = animated ? concatStr(with: mp4!) : link
        return newLink
    }
    private func concatStr(with string: String) -> String {
        var result = string
        guard let i = result.lastIndex(of: ".") else {
            return ""
        }
        result.insert("h", at: i)
        return result
    }
}
struct AlbumDetailItem {
    var link: String = ""
    var title: String = ""
    var images = [ImageDetailItem]()
}

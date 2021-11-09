//
//  ImgurDetaiItem.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import Foundation
import UIKit

struct ImageDetailItem {

    var title: String?
    
    var description: String?
    
    var link: String
    
    var animated: Bool
    
    var mp4: String?
    
    var image: UIImage
        
    var url: URL? {
        let newLink = animated ? concatStr(with: mp4!) : concatStr(with: link)
        return URL(string: newLink)
    }
    private func concatStr(with string: String) -> String {
        var result = string
        guard let i = result.lastIndex(of: ".") else {
            return ""
        }
        result.insert("m", at: i)
        return result
    }
    init() {
        title = nil
        description = nil
        link = ""
        animated = false
        mp4 = nil
        image = UIImage(named: "placeholder")!
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
    var title = ""
    var description: String?
    var images = [ImageDetailItem]()
}

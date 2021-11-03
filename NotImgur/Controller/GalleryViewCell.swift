//
//  GalleryViewCell.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 03/11/2021.
//

import UIKit

class GalleryViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    
    static let identifier = "GalleryViewCell"
    
    func configure(image: UIImage){
        imageView?.image = image
    }
}

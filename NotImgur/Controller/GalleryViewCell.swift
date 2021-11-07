//
//  GalleryViewCell.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 03/11/2021.
//

import UIKit

class GalleryViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var title: UILabel?
    
    static let identifier = "GalleryViewCell"
    
    func configure(image: UIImage, titleAt: String){
        imageView?.image = image
        title?.text = titleAt
    }
}

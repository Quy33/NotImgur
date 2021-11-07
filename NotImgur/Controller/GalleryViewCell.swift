//
//  GalleryViewCell.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 03/11/2021.
//

import UIKit

class GalleryViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel!
    
    static let identifier = "GalleryViewCell"
    
    func configure(image: UIImage, titleAt: String, typeAt: String){
        imageView?.image = image
        titleLabel?.text = titleAt
        typeLabel?.text = typeAt
    }
}

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
    @IBOutlet weak var typeLabel: UILabel?
    @IBOutlet weak var labelStackView: UIStackView?
    
    static let identifier = "GalleryViewCell"
    
    func configure(image: UIImage, titleAt: String, typeAt: String){
        imageView?.image = image
        titleLabel?.text = titleAt
        let type = ImgurNetworkManager.ImageType(rawValue: typeAt)
        switch type {
        case .mp4:
            typeLabel?.text = "MP4"
        case .gif:
            typeLabel?.text = "GIF"
        case .jpeg, .png:
            typeLabel?.text = "IMG"
        default:
            typeLabel?.text = "???"
        }
    }
}

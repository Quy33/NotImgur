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
    
    static let identifier = "GalleryViewCell"
    
    var elementHeights: CGFloat {
        guard let titleHeight = titleLabel?.frame.height else {
            return 0
        }
        guard let typeHeight = typeLabel?.frame.height else {
            return 0
        }
        let cellStackPadding: CGFloat = 10
        let labelStackInset: CGFloat = 20
        let labelStackPadding: CGFloat = 10
        return titleHeight + typeHeight + cellStackPadding + labelStackPadding + labelStackInset
    }
    
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

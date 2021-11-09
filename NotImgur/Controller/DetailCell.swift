//
//  DetailCell.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import UIKit

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var imageFrame: UIView?

    
    static let identifier = "DetailCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(image: UIImage, title: String?, desc: String?, height: CGFloat){
        cellImage?.image = image
        imageFrame?.frame.size.height = height
        if title == nil {
            titleLabel?.isHidden = true
        } else {
            titleLabel?.text = title
        }
        if desc == nil {
            descriptionLabel?.isHidden = true
        } else {
            descriptionLabel?.text = desc
        }
    }
    func getCellHeight() -> CGFloat {
        let titleHeight = titleLabel?.frame.height ?? 0
        let descHeight = descriptionLabel?.frame.height ?? 0
        let result = titleHeight + descHeight 
        return result
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

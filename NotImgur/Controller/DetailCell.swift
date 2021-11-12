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
    @IBOutlet weak var stackView: UIStackView?

    static let identifier = "DetailCell"
    var stackWidth : CGFloat {
        stackView?.bounds.width ?? 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(image: UIImage, title: String?, desc: String?){
        cellImage?.image = image
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
//        titleLabel?.text = title ?? ""
//        descriptionLabel?.text = desc ?? ""
    }
    func getValue() -> CGFloat {
        let titleHeight = titleLabel?.frame.height
        let descriptionHeight = descriptionLabel?.frame.height
        return titleHeight! + descriptionHeight!
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

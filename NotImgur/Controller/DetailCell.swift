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
    @IBOutlet weak var topLabel: UILabel?
    @IBOutlet weak var bottomLabel: UILabel?
    @IBOutlet weak var outerView: UIView?
    @IBOutlet weak var upperStackView: UIStackView?
    @IBOutlet weak var lowerStackView: UIStackView?
    
    static let identifier = "DetailCell"
    
    func config(image: UIImage, title: String?, desc: String?, top: String?, bottom: String?){
        cellImage?.image = image
        titleLabel?.text = title
        descriptionLabel?.text = desc
        topLabel?.text = top
        bottomLabel?.text = bottom
        bottomLabel?.isHidden = true
    }
}

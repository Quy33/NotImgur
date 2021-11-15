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
    
    @IBOutlet weak var topFrame: UIView?
    @IBOutlet weak var bottomFrame: UIView?
    @IBOutlet weak var titleFrame: UIView?
    @IBOutlet weak var descriptionFrame: UIView?
    
    @IBOutlet weak var separator: UIView?
    
    static let identifier = "DetailCell"
    
    var separatorHeight : CGFloat {
        separator?.frame.height ?? 0.0
    }
    
    func config(image: UIImage, title: String?, desc: String?, top: String?, bottom: String?, isLast: Bool){
        cellImage?.image = image
        
        configLabel(text: title, label: titleLabel, frame: titleFrame)
        configLabel(text: desc, label: descriptionLabel, frame: descriptionFrame)
        configLabel(text: top, label: topLabel, frame: topFrame)
        configLabel(text: bottom, label: bottomLabel, frame: bottomFrame)
        
        if isLast {
            separator?.isHidden = true
        } else {
            separator?.isHidden = false
        }
    }
    func configLabel(text: String?, label: UILabel?, frame: UIView?) {
        label?.text = text
        if text == nil {
            label?.isHidden = true
            frame?.isHidden = true
        } else {
            label?.isHidden = false
            frame?.isHidden = false
        }
    }
}

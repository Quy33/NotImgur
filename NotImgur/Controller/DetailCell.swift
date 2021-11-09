//
//  DetailCell.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 08/11/2021.
//

import UIKit

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    
    static let identifier = "DetailCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(image: UIImage){
        cellImage.image = image
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

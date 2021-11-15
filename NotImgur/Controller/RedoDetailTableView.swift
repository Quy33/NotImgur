//
//  RedoDetailTableView.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 12/11/2021.
//

import UIKit

class RedoDetailTableView: UITableViewController {
    
    static let identifier = "RedoDetailTableView"
    
    var itemGot = (id: "KxiXTUT",isAlbum: true)
    
    private var imgurManager = ImgurNetworkManager()
    private var isCached = false
    private var heights: [CGFloat] = []
    
    private let dummyTitle = """
    "Every betrayal contains a perfect moment, a coin stamped heads or tails with salvation on the other side."
    
    -Barbara Kingsolver
    """
    
    var dummyDesc0 = """
    \"Last thing I remember,\nI was running for the door\"\n-The Eagles, Hotel California
    """
    var dummyDesc1 = """
    https://hillreporter.com/report-pence-aides-and-staff-forced-into-hiding-on-jan-6th-because-they-were-locked-out-of-their-offices-117343 \n\n\"The access badges worked that morning before the mob entered the capitol, but once Pence was removed from the chamber floor, their badges no longer worked.\"
    """
    var dummyDesc3 = """
    https://twitter.com/MuellerSheWrote/status/1458139441151705091?s=20\n\n\"You keep\'a knockin\', \nBut you can\'t come in\"\n-Little Richard, Keep\'a Knockin\'
    """
    var dummyDesc4 = """
    https://www.huffpost.com/entry/mike-pence-capitol-riot-photos_n_6189da2ce4b055e47d7ee53a \n\n\"I have a suspicion that the Jan. 6 committee is going to want to see the photos,” Karl said.\n“Those aren’t his photos,” Colbert added.\n\"No, they’re your photos. They’re everybody’s photos here,” Karl replied
    """
    var dummyDesc5 = """
    “I’m not getting in the car, Tim,” Mr Pence replied. “I trust you, Tim, but you’re not driving the car. If I get in that vehicle, you guys are taking off. I’m not getting in the car.”\n\n-Mike Pence, January 6th, 2021\n\nWhat if they weren\'t chanting: \"Hang Mike Pence!\" but were actually chanting: \"This Great Fence!\" or \"This Makes Sense!\" or something?  I\'m going head on over to the fOxNEwS and see what the Branson set thinks.
    """
    private var dummy = AlbumDetailItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell(DetailCell.identifier)
        ImageDetailItem.thumbnailSize = .hugeThumbnail
        //Top
        Task {
            let model = try await imgurManager.getDetail(with: itemGot)
            dummy = getAlbumDetail(model)
            let urls = dummy.images.compactMap{ $0.url }
            let images = try await imgurManager.multipleDownload(with: urls)

            for (index,item) in dummy.images.enumerated() {
                item.image = images[index]
            }

            heights = .init(repeating: 0.0, count: dummy.images.count)
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard !dummy.images.isEmpty else {
            return 0
        }
        return dummy.images.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        
//        let placeHolder = UIImage(named: "placeholder")!
        //let placeHolder = #imageLiteral(resourceName: "First(1)")
        
        guard !dummy.images.isEmpty else {
            return cell
        }
        // Configure the cell...
        
        let item = dummy.images[indexPath.row]
        
        if indexPath.row == 0 {
            //Top
            cell.config(image: item.image, title: item.title, desc: item.description, top: dummy.title, bottom: nil)
        }else if indexPath.row == dummy.images.count - 1 {
            //Bottom
            cell.config(image: item.image, title: item.title, desc: item.description, top: nil, bottom: dummy.description)
        } else {
            cell.config(image: item.image, title: item.title, desc: item.description, top: nil, bottom: nil)
        }
        
        return cell
    }

    //MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !dummy.images.isEmpty else {
            return 0
        }
        return heights[indexPath.row]
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let detailCell = cell as? DetailCell else{
            return
        }
        //let labelHeight = detailCell.topLabel?.frame.height
        if !heights.isEmpty {
            if !isCached {
                let frameWidth = detailCell.outerView!.frame.width
                for (index,item) in dummy.images.enumerated() {

                    let titleHeight = heightForView(text: item.title ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                    let descHeight = heightForView(text: item.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)
                    let imageHeight = calculateHeight(item.image.size)

                    switch index {
                    case 0:
                        let topTitleHeight = heightForView(text: dummy.title, font: .systemFont(ofSize: 17), width: frameWidth)
                        heights[index] = topTitleHeight + titleHeight + descHeight + imageHeight
                    case dummy.images.count - 1:
                        let bottomDescHeight = heightForView(text: dummy.description ?? "", font: .systemFont(ofSize: 17), width: frameWidth)

                        heights[index] = bottomDescHeight + titleHeight + descHeight + imageHeight
                    default:
                        heights[index] = titleHeight + descHeight + imageHeight
                    }
                }
                isCached = true
                print(heights)
                tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DetailCell
        print(cell.topLabel?.frame.height)
        print(cell.titleLabel?.frame.height)
        print(cell.cellImage?.frame.height)
        print(cell.descriptionLabel?.frame.height)
        print(cell.bottomLabel?.frame.height)
        print(cell.frame.height)
        print(cell.bottomLabel?.text)
        print("...")
        print(calculateHeight(dummy.images[indexPath.row].image.size))
    }
    
    //MARK: Misc Functions
    func registerCell(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib , forCellReuseIdentifier: identifier)
    }
    func calculateHeight(_ pictureSize: CGSize)->CGFloat{
        let deviceSize = view.frame.size
        let wOffSet = pictureSize.width - deviceSize.width
        let wOffSetPercent = (wOffSet*100)/pictureSize.width
        let hOffSet = (wOffSetPercent*pictureSize.height)/100
        let newHeight = pictureSize.height - hOffSet
        return newHeight
    }
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    private func getAlbumDetail(_ model: DetailModel) -> AlbumDetailItem {
        var newAlbum = AlbumDetailItem(title: model.data.title, description: model.data.description, images: [])
        let items = model.data.images!
        for image in items {
            let newImage = ImageDetailItem(title: image.title, description: image.description, link: image.link, animated: image.animated, mp4: image.mp4)
            newAlbum.images.append(newImage)
        }
        return newAlbum
    }
}

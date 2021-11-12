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
    private var dummy = AlbumDetailItem(title: "Test Title", description: nil, images: .init(repeating: ImageDetailItem(), count: 20))


    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        
        
        
//        Task {
//            let model = try await imgurManager.getDetail(with: itemGot)
//            print(model.data.title)
//            print(model.data.description)
//            print(model.data.images?.count)
//            for item in model.data.images! {
//                print("title: \(item.title)")
//                print("desc: \(item.description)")
//            }
//        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dummy.images.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        // Configure the cell...
        
        return cell
    }

    //MARK: Table View Delegate
    
    //MARK: Misc Functions
    func registerCell() {
        let nib = UINib(nibName: DetailCell.identifier, bundle: nil)
        tableView.register(nib , forCellReuseIdentifier: DetailCell.identifier)
    }
}

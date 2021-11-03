//
//  ViewController.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import UIKit

class ViewController: UIViewController {
//    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var imageView: UIImageView?
    var imgurManager = ImgurNetworkManager()
    var imgurItems = [ImgurGalleryItem]()
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        networking()
    }
    
    func networking(){
        Task {
            do {
                let model = try await imgurManager.requestGallery()
                let imagesGot = try await imgurManager.downloadImage(model)
                let galleryModel = imgurManager.getImgurModels(with: model)
                self.images.append(contentsOf: imagesGot)
            } catch {
                print(error)
            }
        }
    }
}


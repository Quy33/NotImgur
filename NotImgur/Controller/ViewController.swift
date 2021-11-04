//
//  ViewController.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView?
    var imgurManager = ImgurNetworkManager()
    var imgurItems = [ImgurGalleryItem]()
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
        let layout = PinterestLayout()
        layout.numberOfColumns = 2
//        layout.delegate = self
//        let layout = UICollectionViewFlowLayout()
//        collectionView?.delegate = self
        collectionView?.collectionViewLayout = layout
        networking()
    }
    
    func networking(){
        Task {
            do {
                let model = try await imgurManager.requestGallery()
                print(model.data[0])
//                print("Finish calling data")
                let imagesGot = try await imgurManager.downloadImage(model)
//                print("Finish downloading images")
//                let galleryModel = imgurManager.getImgurModels(with: model)
                self.images.append(contentsOf: imagesGot)
                
                collectionView?.reloadData()
                collectionView?.collectionViewLayout.invalidateLayout()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func layoutPressed(_ sender: UIButton) {
        collectionView?.reloadData()
        
        let layout = PinterestLayout()
        layout.delegate = self
        layout.numberOfColumns = 2
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.collectionViewLayout = layout
    }
    
}
//MARK: CollectionView Datasource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryViewCell.identifier, for: indexPath) as! GalleryViewCell
        cell.configure(image: images[indexPath.row])
        return cell
    }
}
//MARK: Flow Layout Delegate
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/2 - 10, height: 200)
    }
}
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        return images[indexPath.row].size.height
    }
}


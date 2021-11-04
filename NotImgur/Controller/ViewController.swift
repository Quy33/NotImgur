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
    var images = [UIImage](repeating: UIImage(named: "placeholder")!, count: 60)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView?.collectionViewLayout = layout
        networking()
    }
    
    func networking(){
        Task {
            do {
                let model = try await imgurManager.requestGallery()
                print(model.data[0])
                print("Finish calling data")
                let imagesGot = try await imgurManager.downloadImage(model)
                print("Finish downloading images")
                //let galleryModel = imgurManager.getImgurModels(with: model)
                self.images = imagesGot
                print(images.count)
                updateLayout()
            } catch {
                print(error)
            }
        }
    }
    @IBAction func testAdd(_ sender: UIButton){
        guard let newImgs = makePlaceHolders() else {
            print("Can't find place holder image")
            return
        }
        self.images.append(contentsOf: newImgs)
        reload(collectionView: collectionView!)
    }
    
    func updateLayout() {
        let layout = PinterestLayout()
        layout.delegate = self
        
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.collectionViewLayout = layout
    }
    func makePlaceHolders() -> [UIImage]? {
        guard let image = UIImage(named: "placeholder") else {
            return nil
        }
        return [UIImage](repeating: image, count: 60)
    }
    func reload(collectionView: UICollectionView){
        let contentOffset = collectionView.contentOffset
        updateLayout()
        collectionView.setContentOffset(contentOffset, animated: false)
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
//MARK: Pinterest Layout Delegate
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        return images[indexPath.row].size.height
    }
}


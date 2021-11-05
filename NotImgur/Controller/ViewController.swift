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
    let queryAmount = 60
    private var pageAt = 0
    private var isDoingTask = false
    var galleryItems = [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: 60)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
        collectionView?.delegate = self
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView?.collectionViewLayout = layout
        Task {
            await initalNetworking()
            print("Finished")
        }
    }
    
    func initalNetworking() async {
        do {
            let model = try await imgurManager.requestGallery()
            
//            self.images = imagesGot
            let urls = try imgurManager.getAllLinks(model)
            
            for i in 0..<galleryItems.count {
                let newImage = try await imgurManager.singleDownload(with: urls[i])
                galleryItems[i].image = newImage
                
                let indexPath = IndexPath(item: i, section: 0)
                DispatchQueue.main.async {
                    self.collectionView?.reloadItems(at: [indexPath])
                    self.reload(collectionView: self.collectionView!)
                }
            }
            print("Done")
        } catch {
            print(error)
        }
    }
        
    @IBAction func testAdd(_ sender: UIButton){
        
        guard !isDoingTask else {
            print("Busy Adding Images")
            return
        }
        pageAt += 1
        
        Task {
            do {
                isDoingTask = true
                
                let model = try await imgurManager.requestGallery(page: pageAt)
                print(model.data.count)
                let links = try imgurManager.getAllLinks(model)
                let upperBounds = model.data.count + galleryItems.count
                let startingIndex = galleryItems.count
                
                var indexes = [IndexPath]()
                for index in startingIndex..<upperBounds {
                    let indexPath = IndexPath(item: index, section: 0)
                    indexes.append(indexPath)
                }
                print(indexes)
                print(indexes.count)
                
                for i in 0..<model.data.count {
                    let newImage = try await imgurManager.singleDownload(with: links[i])
                    let newItems = ImgurGalleryItem(id: model.data[i].id, is_album: model.data[i].is_album, image: newImage)
                    
                    
                    let indexPath = indexes[i]
                    galleryItems.append(newItems)

                    DispatchQueue.main.async {
                        self.collectionView?.reloadItems(at: [indexPath])
                        self.reload(collectionView: self.collectionView!)
                    }
                }
                
                isDoingTask = false
            } catch {
                print(error)
            }
        }
    }
    @IBAction func reloadPressed(_ sender: Any) {
        
    }
    
//    func updateLayout() {
//        let layout = PinterestLayout()
//        layout.delegate = self
//
//        //collectionView?.reloadData()
//        collectionView?.collectionViewLayout.invalidateLayout()
//        collectionView?.collectionViewLayout = layout
//    }
    func makePlaceHolders() -> [ImgurGalleryItem] {
        return [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: queryAmount)
    }
    func reload(collectionView: UICollectionView){
        let contentOffset = collectionView.contentOffset
        
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.collectionViewLayout = layout
        
        collectionView.setContentOffset(contentOffset, animated: false)
    }
}
//MARK: CollectionView Datasource & Delegate
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryViewCell.identifier, for: indexPath) as! GalleryViewCell
        let image = galleryItems[indexPath.row].image
        cell.configure(image: image)
        return cell
    }
}
extension ViewController: UICollectionViewDelegate {
}
//MARK: Pinterest Layout Delegate
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        let image = galleryItems[indexPath.row].image
        return image.size.height
    }
}



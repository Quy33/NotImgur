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
        guard !isDoingTask else {
            print("Busy downloading initial image")
            return
        }
        isDoingTask = true
        do {
            try await performDownloads(count: queryAmount, page: 0)
            print("Done")
            isDoingTask = false
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
        isDoingTask = true
        Task {
            do {
                try await performBatchesDownload(batch: 20, page: pageAt)
            } catch {
                print(error)
            }
        }
        isDoingTask = false
    }
    @IBAction func reloadPressed(_ sender: Any) {
        
    }
    
    func performDownloads(count: Int, page: Int) async throws {
        let model = try await imgurManager.requestGallery(page: page)
        
        let urls = try imgurManager.getLinks(from: model)
        
        for i in 0..<count {
            let newImage = try await imgurManager.singleDownload(with: urls[i])
            galleryItems[i].image = newImage
            imgurManager.configProperty(model: model, with: &galleryItems)
            
            let indexPath = IndexPath(item: i, section: 0)
            DispatchQueue.main.async {
                self.update(collectionView: self.collectionView!, updateItemAt: indexPath)
            }
        }
    }
    
    func performBatchesDownload(batch: Int, page: Int) async throws {
        let model = try await imgurManager.requestGallery(page: page)
        
        let urls = try imgurManager.getLinks(from: model)
        
        print(urls.count)
        var count = urls.count
//        while i != 0 {
//            if i >= batch {
//                i = i - batch
//            } else if i <= batch{
//                i = i - i
//            }
//        }
        
        while count != 0 {
            if count >= batch {
                count = count - batch
            } else if count <= batch{
                count = count - count
            }
        }
    }
    
    func update(collectionView: UICollectionView, updateItemAt indexPath: IndexPath){
        collectionView.reloadItems(at: [indexPath])
        reload(collectionView: collectionView)
    }

    func makePlaceHolders(count: Int) -> [ImgurGalleryItem] {
        return [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: count)
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



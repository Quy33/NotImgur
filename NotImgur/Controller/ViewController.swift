//
//  ViewController.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var imgurManager = ImgurNetworkManager()
    let queryAmount = 60
    private var pageAt = 0
    private var isDoingTask = false
    var galleryItems = [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: 60)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        setLayout(collectionView: collectionView)
        
        initialNetworking()
    }
    
    func initialNetworking() {
        Task {
            guard !isDoingTask else {
                print("Busy downloading initial image")
                return
            }
            print("Begin initial setup")
            isDoingTask = true
            do {
                try await performDownloads(count: queryAmount, page: 0, isReset: false)
                
                print("Done")
                isDoingTask = false
            } catch {
                print(error)
            }
            print("Finished initial setup")
        }
    }
        
//MARK: Buttons
        @IBAction func addPressed(_ sender: UIButton){
            
            guard !isDoingTask else {
                print("Busy Adding Images")
                return
            }
            print("Begin Adding more Images")
            pageAt += 1
            isDoingTask = true
            Task {
                do {
                    try await performBatchesDownload(page: pageAt,isReset: false)
                    isDoingTask = false
                    print("Finish Loading page \(pageAt)")
                } catch {
                    print(error)
                }
            }
            
        }

        @IBAction func reloadPressed(_ sender: Any) {
            guard !isDoingTask else {
                print("Busy Adding Images")
                return
            }
            print("Begin reloading")
            isDoingTask = true
            pageAt = 0
            galleryItems = makePlaceHolders(count: queryAmount)
            
            reset(collectionView: collectionView)
            collectionView.reloadData()
            
            Task {
                do {
                    try await performDownloads(count: queryAmount, page: pageAt, isReset: true)
                    isDoingTask = false
                    print("Finished Reloading")
                } catch {
                    print(error)
                }
            }
        }

    //MARK: download Functions
    func performDownloads(count: Int, page: Int, isReset: Bool) async throws {
        let model = try await imgurManager.requestGallery(page: page)
        
        let urls = try imgurManager.getLinks(from: model)
        
        imgurManager.configProperty(model: model, with: &galleryItems)
        
        for i in 0..<count {
            let newImage = try await imgurManager.singleDownload(with: urls[i])
            galleryItems[i].image = newImage
            
            let indexPath = IndexPath(item: i, section: 0)
            DispatchQueue.main.async {
                self.update(collectionView: self.collectionView, updateItemAt: indexPath, isReset: isReset)
            }
        }
    }
    
    func performBatchesDownload(page: Int, isReset: Bool) async throws {
        let model = try await imgurManager.requestGallery(page: page)
        
        let urls = try imgurManager.getLinks(from: model)
        
        async let images = try await imgurManager.multipleDownload(with: urls)
        
        var items = [ImgurGalleryItem]()
        
        for i in 0..<model.data.count {
            let newItem = ImgurGalleryItem(id: model.data[i].id, is_album: model.data[i].is_album, image: try await images[i])
            items.append(newItem)
        }
        
        galleryItems.append(contentsOf: items)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.reload(collectionView: self.collectionView)
        }
    }
    
    func makePlaceHolders(count: Int) -> [ImgurGalleryItem] {
        return [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: count)
    }
    
//MARK: Function to update & reset the collectionView
    func update(collectionView: UICollectionView, updateItemAt indexPath: IndexPath, isReset: Bool){
        if isReset {
            reset(collectionView: collectionView)
        } else {
            reload(collectionView: collectionView)
        }
        collectionView.reloadItems(at: [indexPath])
    }
    func reload(collectionView: UICollectionView){
        let contentOffset = collectionView.contentOffset
        
        setLayout(collectionView: collectionView)
        
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    func reset(collectionView: UICollectionView){
        setLayout(collectionView: collectionView)
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    func setLayout(collectionView: UICollectionView) {
        let layout = PinterestLayout()
        layout.delegate = self
        //collectionView.collectionViewLayout.invalidateLayout()
        collectionView.collectionViewLayout = layout
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



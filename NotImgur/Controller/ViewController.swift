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
    private var indexPathToMove = IndexPath()
    var galleryItems = [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: 60)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        setLayout(collectionView: collectionView)
        
        imgurManager.configThumbnail = .mediumThumbnail
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
                try await performDownloads(count: queryAmount, page: 0)
                
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
                    try await performBatchesDownload(page: pageAt)
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
            
            collectionView.reloadData()
            reset(collectionView: collectionView)
            
            
            Task {
                do {
                    try await performDownloads(count: queryAmount, page: pageAt)
                    
                    isDoingTask = false
                    print("Finished Reloading")
                } catch {
                    print(error)
                }
            }
        }

    //MARK: download Functions
    func performDownloads(count: Int, page: Int) async throws {
        let model = try await imgurManager.requestGallery(page: page)
        
        let urls = try imgurManager.getLinks(from: model)
        
        imgurManager.configProperty(model: model, with: &galleryItems)
        
        for i in 0..<count {
            let newImage = try await imgurManager.singleDownload(with: urls[i])
            galleryItems[i].image = newImage
            
            let indexPath = IndexPath(item: i, section: 0)
            DispatchQueue.main.async {
                self.update(collectionView: self.collectionView, updateItemAt: indexPath)
            }
        }
    }
    
    func performBatchesDownload(page: Int) async throws {
        let model = try await imgurManager.requestGallery(page: page)
        
        let urls = try imgurManager.getLinks(from: model)
        
        async let images = try await imgurManager.multipleDownload(with: urls)
        
        var items = [ImgurGalleryItem]()
        
        for i in 0..<model.data.count {
            let newItem = ImgurGalleryItem(
                id: model.data[i].id,
                is_album: model.data[i].is_album,
                image: try await images[i],
                type: model.data[i].type ?? model.data[i].images![0].type,
                title: model.data[i].title
            )
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
    
    func check() {
        for item in galleryItems {
            print(item.type)
        }
        print(galleryItems.count)
    }
    
//MARK: Function to update & reset the collectionView
    func update(collectionView: UICollectionView, updateItemAt indexPath: IndexPath){
        reload(collectionView: collectionView)
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
        let testTitle = galleryItems[indexPath.row].title
        let testType = galleryItems[indexPath.row].type
        cell.configure(image: image,titleAt: testTitle, typeAt: testType)
        return cell
    }
}
//MARK: CollectionView Delegate & segue
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isDoingTask else {
            print("Busy doing Task")
            return
        }
        
        indexPathToMove = indexPath
        
        performSegue(withIdentifier: DetailTableViewController.identifier, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailTableViewController else {
            fatalError("Cannot find the destination")
        }
        destination.id = galleryItems[indexPathToMove.item].id
    }
}
//MARK: Pinterest Layout Delegate
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        let image = galleryItems[indexPath.row].image
        
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryViewCell {
            return image.size.height + cell.elementHeights
        }
        
        return image.size.height
    }
}



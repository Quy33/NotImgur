//
//  ViewController.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 02/11/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var imgurManager = ImgurNetworkManager()
    private let queryAmount = 60
    private var pageAt = 0
    private var isDoingTask = false
    private var indexPathToMove = IndexPath()
    private var galleryItems = [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: 60)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        setLayout(collectionView: collectionView)
        
        imgurManager.configThumbnail = .mediumThumbnail
        //initialNetworking()
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
            ImgurNetworkManager.cancellation = true
//            guard !isDoingTask else {
//                print("Busy Adding Images")
//                return
//            }
//            print("Begin reloading")
//            isDoingTask = true
//            pageAt = 0
//            galleryItems = makePlaceHolders(count: queryAmount)
//
//            collectionView.reloadData()
//            reset(collectionView: collectionView)
//
//
//            Task {
//                do {
//                    try await performDownloads(count: queryAmount, page: pageAt)
//
//                    isDoingTask = false
//                    print("Finished Reloading")
//                } catch {
//                    print(error)
//                }
//            }
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
        
        //var images: [UIImage] = []
        
//        let increment = 5
//        let remainder = count % increment
//
//        var lowerbound = 0
//        if remainder == 0 {
//            for upperbound in stride(from: 5, through: count, by: increment){
//                let newImages = try await imgurManager.multipleDownload(with: limitedURL[lowerbound..<upperbound])
//                images.append(contentsOf: newImages)
//                lowerbound += increment
//            }
//        }
        let loadFirstUrls = urls[0..<queryAmount].compactMap { $0 }
        
        let remainingUrls = urls[queryAmount..<urls.count].compactMap { $0 }

        let loadFirstRange = 0..<queryAmount
        
        let remainingRange = queryAmount..<urls.count
        
        //First 60 image
        
        let firstImages = try await imgurManager.multipleDownload(with: loadFirstUrls)
        
        var firstItems = makeGalleryItems(withRange: loadFirstRange, model: model, images: firstImages)
        
        galleryItems.append(contentsOf: firstItems)
        updateAfterDownloading(collectionView: collectionView)
        
        //The rest load here
        
        let remainingImages = try await imgurManager.multipleDownload(with: remainingUrls)
        
        var remainingItems = makeGalleryItems(withRange: remainingRange, model: model, images: remainingImages)
        
        galleryItems.append(contentsOf: remainingItems)
        updateAfterDownloading(collectionView: collectionView)
    }
    
    private func makeGalleryItems(withRange range: Range<Int>, model: GalleryModel, images: [UIImage]) -> [ImgurGalleryItem] {
        var items: [ImgurGalleryItem] = []
        for i in range {
            let newItem = ImgurGalleryItem(
                id: model.data[i].id,
                is_album: model.data[i].is_album,
                image: images[i],
                type: model.data[i].type ?? model.data[i].images![0].type,
                title: model.data[i].title
            )
            items.append(newItem)
        }
        return items
    }
    
    private func makePlaceHolders(count: Int) -> [ImgurGalleryItem] {
        return [ImgurGalleryItem](repeating: ImgurGalleryItem(), count: count)
    }
    
    
//MARK: Function to update & reset the collectionView
    private func updateAfterDownloading(collectionView: UICollectionView) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.reload(collectionView: self.collectionView)
        }
    }
    private func update(collectionView: UICollectionView, updateItemAt indexPath: IndexPath){
        reload(collectionView: collectionView)
        collectionView.reloadItems(at: [indexPath])
    }
    private func reload(collectionView: UICollectionView){
        let contentOffset = collectionView.contentOffset
        
        setLayout(collectionView: collectionView)
        
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    private func reset(collectionView: UICollectionView){
        setLayout(collectionView: collectionView)
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    private func setLayout(collectionView: UICollectionView) {
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
        destination.itemGot.id = galleryItems[indexPathToMove.item].id
        destination.itemGot.isAlbum = galleryItems[indexPathToMove.item].isAlbum
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



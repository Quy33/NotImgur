//
//  PinterestLayout.swift
//  NotImgur
//
//  Created by Mcrew-Tech on 03/11/2021.
//

import UIKit

protocol PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    var delegate: PinterestLayoutDelegate?
    //Properties for calculating the Layout
    var numberOfColumns = 1
    private let cellPadding: CGFloat = 6
    //Cache for returning the layout attributes back to the collectionView so we don't have to recalculate it everytime.
    private var cache = [UICollectionViewLayoutAttributes]()
    //Size of content to be calculated later
    private var contentHeight: CGFloat = 0
    // The width of the content to be smaller than the collectionView
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        //Check cache if empty
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        // Making columns equal to the amount of column set.
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        //X & Y to get a reference of where each content is inside each column.
        var xOffSets = [CGFloat]()
        //Cuz of the CollectionView is static so we can immediately populate the column.
        for column in 0..<numberOfColumns {
            xOffSets.append(CGFloat(column) * columnWidth)
        }
        var yOffSets: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        //Looping through each item inside the collectionView
        var column = 0
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            //Size of photo getting from collectionView
            let photoHeight = delegate?.collectionView(collectionView: collectionView, heightForItemAtIndexPath: indexPath) ?? 180
            //Making the frame for the UIViewLayoutAttributes.
            let frame = CGRect(x: xOffSets[column], y: yOffSets[column], width: columnWidth, height: photoHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            //Making the attribute to cache.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            //Updating the content height to account for the frame of the newly calculated item
            contentHeight = max(contentHeight,frame.maxY)
            //Advancing the yOffSet to the next item base on the frame
            yOffSets[column] = yOffSets[column] + photoHeight
            //Advance the column
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        print("check")
    }
    //This method basically will check if the rect inside the cache is inside the visible rect that the collectionView give back, if so then it will append to make those rect appear.
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        // Check if the frame intersect with the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    //Bonus func to get the indexPath from cache
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if cache.isEmpty {
            print("empty")
            return nil
        }
        return cache[indexPath.item]
    }
}

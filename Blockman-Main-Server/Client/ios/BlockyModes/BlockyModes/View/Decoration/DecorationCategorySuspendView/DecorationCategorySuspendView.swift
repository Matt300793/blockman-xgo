//
//  DecorationGroupsView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/4.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

/// You can addTarget: action: for the .valueChanged event
class DecorationCategorySuspendView: UIControl {
    
    fileprivate(set) var selectedIndex: Int = 0
    fileprivate(set) var selectedImage: UIImage?
    fileprivate(set) var selectedImageURLString: String?
    
    private weak var collectionView: UICollectionView!
    fileprivate let itemSize = CGSize(width: 45, height: 45)
    fileprivate let lineSpacing = 5
    fileprivate var items: [Any] = []
    
    /// items can be image or remote image URLString.
    required init(items: [Any]) {
        super.init(frame: CGRect(x: 0, y: 0, width: Int(itemSize.width), height: items.count * Int(itemSize.width) + (items.count - 1) * lineSpacing))
        
        self.items = items
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).addTo(superView: self).configure { (collectionView) in
            collectionView.backgroundColor = UIColor.clear
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.bounces = false
            collectionView.register(DecorationGroupsCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(DecorationGroupsCollectionViewCell.self))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
    
    override func updateConstraints() {
        collectionView.layout { (make) in
            make.edges.equalToSuperview()
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func appendItems(contents: [Any]) {
        items += contents
        collectionView.reloadData()
    }
    
    public func set(content: Any, at index: Int) {
        guard index < items.count else {return}
        items[index] = content
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    public func removeAllItems() {
        items.removeAll()
        collectionView.reloadData()
    }
    
}

extension DecorationCategorySuspendView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(DecorationGroupsCollectionViewCell.self), for: indexPath) as! DecorationGroupsCollectionViewCell
        cell.configure(content: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: (collectionView.width - itemSize.width) / 2, bottom: 0, right: (collectionView.width - itemSize.width))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(lineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        let selectedItem = items[indexPath.item]
        if type(of: selectedItem) == UIImage.self {
            selectedImage = selectedItem as? UIImage
            selectedImageURLString = nil
        }else {
            selectedImage = nil
            selectedImageURLString = selectedItem as? String
        }
        sendActions(for: .valueChanged)
    }
}



// MARK: DecorationGroupsCollectionViewCell
private class DecorationGroupsCollectionViewCell: UICollectionViewCell {
    
    private weak var imageView: NetImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._fae7ca()
        
        imageView = NetImageView().addTo(superView: self).configure({ (imageView) in
            imageView.image = R.image.decoration_facing()
        }).layout { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(content: Any) {
        if type(of: content) == UIImage.self {
            imageView.image = content as? UIImage
        }else {
            imageView.imageWithUrlString(content as? String)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

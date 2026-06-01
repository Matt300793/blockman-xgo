//
//  GamesRecommendTableCell.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/1.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class GamesRecommendTableCell: BMTableViewCell {

    fileprivate weak var placeHolderView: LoadingHolderView?
    fileprivate(set) weak var gamesCollectionView: UICollectionView?
    fileprivate(set) weak var tagLabel: UILabel?
    
    fileprivate lazy var horizontalFlowLayout: UICollectionViewFlowLayout = {
        let horizontal = UICollectionViewFlowLayout()
        horizontal.itemSize = CGSize(width: 121, height: 163)
        horizontal.sectionInset = UIEdgeInsetsMake(30, 16, 13, 16)
        horizontal.minimumInteritemSpacing = 2
        horizontal.scrollDirection = .horizontal
        return horizontal
    }()
    
    fileprivate lazy var verticalFlowLayout: UICollectionViewFlowLayout = {
        let spacing = 2
        let itemWH = (Int(UIScreen.main.bounds.width) - 16 * 2 - spacing) / 2
        
        let vertical = UICollectionViewFlowLayout()
        vertical.minimumLineSpacing = 2
        vertical.minimumInteritemSpacing = 2
        vertical.sectionInset = UIEdgeInsetsMake(30, 16, 13, 16)
        vertical.itemSize = CGSize(width: itemWH, height: itemWH)
        vertical.scrollDirection = .vertical
        return vertical
    }()
    
    fileprivate var gameCollectionEntities: [GameCollectionCellEntity] = []
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = R.color.appColor._e7c99e()
        clipsToBounds = true
        selectionStyle = .none
        
        gamesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: verticalFlowLayout).addTo(superView: contentView).configure { (collectionView) in
            collectionView.backgroundColor = R.color.appColor._e7c99e()
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(cellForClass: GameCollectionCell.self)
            collectionView.showsHorizontalScrollIndicator = false
        }.layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview()
        })
        
        let seperatorLine = UIView().addTo(superView: contentView).configure { (view) in
            view.backgroundColor = R.color.appColor._7a4e38()
        }.layout { (make) in
            make.top.equalToSuperview().offset(1)
            make.left.equalToSuperview().offset(margin_16)
            make.size.equalTo(CGSize(width: 2, height: 14))
        }
        
        tagLabel = UILabel().addTo(superView: contentView).configure { (label) in
            label.textColor = R.color.appColor._7a4e38()
            label.font = UIFont.size15
        }.layout { (make) in
            make.left.equalTo(seperatorLine).offset(5)
            make.centerY.equalTo(seperatorLine)
        }
        
        placeHolderView = LoadingHolderView().addTo(superView: contentView).configure({ (loadingView) in
            loadingView.stopAnimating(holder: R.string.localizable.no_data())
            loadingView.isHidden = true
        }).layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let recommendEntity = entity as! GamesRecommendTableCellEntity
        
        if indexPath.section == 0 {
            gamesCollectionView?.isScrollEnabled = false
            gamesCollectionView?.collectionViewLayout = verticalFlowLayout
            guard recommendEntity.games.count != 0 else {
                placeHolderView?.isHidden = false
                return
            }
            placeHolderView?.isHidden = true
        }else {
            placeHolderView?.isHidden = true
            gamesCollectionView?.isScrollEnabled = true
            gamesCollectionView?.collectionViewLayout = horizontalFlowLayout
        }

        tagLabel?.text = recommendEntity.title
        gameCollectionEntities = recommendEntity.games.map({
            GameCollectionCellEntity(gameModel: $0)
        })
        gamesCollectionView?.reloadData()
    }
}

extension GamesRecommendTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameCollectionEntities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GameCollectionCell
        cell.bindToCellEntity(gameCollectionEntities[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gameId = gameCollectionEntities[indexPath.row].gameId
        AppDelegate.globalServive().pushViewModel(GameDetailViewModel.self, params: gameId, animated: true)
    }
}

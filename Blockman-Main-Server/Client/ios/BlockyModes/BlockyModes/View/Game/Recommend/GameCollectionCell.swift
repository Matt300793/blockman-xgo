//
//  GameCollectionCell.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/1.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class GameCollectionCell: BMCollectionViewCell {
    
    private weak var thumbnailImageView: NetImageView?
    private weak var playingNumberLabel: UILabel?
    private weak var titleLabel: UILabel?
    private weak var appreciationNumberLabel: UILabel?
    private weak var categoryLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let thumbnailImageView = NetImageView(image: R.image.game_1())
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.thumbnailImageView = thumbnailImageView
        
        let thumbnailMaskImageView = UIImageView(image: R.image.game_thumbnail_mask())
        contentView.addSubview(thumbnailMaskImageView)
        thumbnailMaskImageView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        let playNumberLabel = UILabel().config(text: "", textColor: UIColor.white, textAlignment: .center, font: UIFont.size12)
        playNumberLabel.backgroundColor = R.color.appColor._0ab950()
        contentView.addSubview(playNumberLabel)
        playNumberLabel.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(70)
            make.height.equalTo(16)
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
        playingNumberLabel = playNumberLabel
        
        let gameCategoryLabel = UILabel().config(text: "PVP | 解密", textColor: UIColor.white)
        contentView.addSubview(gameCategoryLabel)
        gameCategoryLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        categoryLabel = gameCategoryLabel
        
        let appreciationImageView = UIImageView(image: R.image.game_favorite())
        contentView.addSubview(appreciationImageView)
        appreciationImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalTo(gameCategoryLabel.snp.top).offset(-7)
        }
        
        let appreciationNumberLabel = UILabel().config(text: "212", textColor: UIColor.white)
        contentView.addSubview(appreciationNumberLabel)
        appreciationNumberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(appreciationImageView.snp.right).offset(4)
            make.centerY.equalTo(appreciationImageView)
        }
        self.appreciationNumberLabel = appreciationNumberLabel
        
        let gameTitleLabel = UILabel().config(text: "SEfish sefe", textColor: UIColor.white, font: UIFont.boldSize15)
        contentView.addSubview(gameTitleLabel)
        gameTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin_10)
            make.right.equalToSuperview().offset(-margin_10)
            make.bottom.equalTo(appreciationNumberLabel.snp.top).offset(-7)
        }
        titleLabel = gameTitleLabel
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let entity = entity as! GameCollectionCellEntity
        
        titleLabel?.text = entity.gameTitle
        appreciationNumberLabel?.text = entity.appreciationNumber
        categoryLabel?.text = entity.gameCategory
        playingNumberLabel?.text = entity.playingNumber
        thumbnailImageView?.imageWithUrlString(entity.gameThumbnail)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

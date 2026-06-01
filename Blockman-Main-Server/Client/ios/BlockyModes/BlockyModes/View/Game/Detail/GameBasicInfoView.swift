//
//  GameBasicInfoView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/3.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class GameBasicInfoView: UIView {

    private weak var thumbnailsCycleView: SDCycleScrollView?
    private weak var infoTitleLabel: UILabel?
    private weak var infoCategoryLabel: UILabel?
    private weak var appreciationImageView: UIImageView?
    private weak var appreciationNumberLabel: UILabel?
    private weak var appreciateButton: UIButton?
    
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._fae7ca()
        
        let cycleViewW = UIScreen.main.bounds.width - 4 * margin_16
        let thumbnailsCycleScrollView = SDCycleScrollView(frame: CGRect(x: margin_16, y: margin_16, width: cycleViewW, height: 165), delegate: self, placeholderImage: nil)
        thumbnailsCycleScrollView?.bannerImageViewContentMode = .scaleAspectFill
        thumbnailsCycleScrollView?.autoScrollTimeInterval = 5
        thumbnailsCycleScrollView?.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        thumbnailsCycleScrollView?.currentPageDotColor = R.color.appColor._10f025()
        thumbnailsCycleScrollView?.pageDotColor = UIColor.white
        addSubview(thumbnailsCycleScrollView!)
        thumbnailsCycleView = thumbnailsCycleScrollView
        
        let infoBottomView = UIView().addTo(superView: self).layout { (make) in
            make.left.bottom.right.equalToSuperview().inset(margin_16)
            make.height.equalTo(60)
            }.configure { (view) in
                view.backgroundColor = R.color.appColor._0ab950()
        }
        
        infoTitleLabel = UILabel().addTo(superView: infoBottomView).layout { (make) in
            make.left.top.equalToSuperview().offset(margin_10)
            make.right.equalToSuperview().offset(-120)
            }.configure { (label) in
                label.textColor = UIColor.white
                label.font = UIFont.boldSize19
        }
        
        infoCategoryLabel = UILabel().addTo(superView: infoBottomView).configure { (label) in
            label.textColor = UIColor.white
            label.font = UIFont.size11
            label.sizeToFit()
            }.layout { (make) in
                make.top.equalTo(infoTitleLabel!.snp.bottom).offset(5)
                make.left.equalToSuperview().offset(margin_10)
        }
        
        appreciateButton = UIButton().addTo(superView: infoBottomView).configure { (button) in
            button.backgroundColor = UIColor.white
            }.layout { (make) in
                make.size.equalTo(CGSize(width: 90, height: 30))
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalToSuperview()
        }
        
        appreciationNumberLabel = UILabel().addTo(superView: appreciateButton!).configure { (label) in
            label.textColor = R.color.appColor._333333()
            label.font = UIFont.size14
            }.layout { (make) in
                make.centerX.equalToSuperview().offset(10)
                make.centerY.equalToSuperview()
        }
        
        appreciationImageView = UIImageView().addTo(superView: appreciateButton!).configure { (imageView) in
            imageView.image = R.image.game_favorites()
            }.layout { (make) in
                make.size.equalTo(CGSize(width: 19, height: 19))
                make.centerY.equalTo(appreciationNumberLabel!)
                make.right.equalTo(appreciationNumberLabel!.snp.left).offset(-5)
        }
    }
    
    func bindToEntity(_ entity: GameDetailEntity) {
        thumbnailsCycleView?.imageURLStringsGroup = entity.gameThumbnails.map({ $0.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "" })
        infoTitleLabel?.text = entity.gameTitle
        infoCategoryLabel?.text = entity.gameCategory
        appreciationNumberLabel?.text = entity.appreciationNumber
        appreciationImageView?.image = entity.isAppreciated ? R.image.game_not_favorites() : R.image.game_favorites()
        
        // 点击赞
        appreciateButton!.rx.tap.asDriver().throttle(0.5).filter({ [unowned self] in
            if AccountStatusManager.shared.statusVariable.value == .visit {
                BlockyHUD.showText(R.string.localizable.no_permission(), inView: self.window!)
                return false
            }
            
            if entity.isAppreciated {
                BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("you_have_been_appreciate", comment: "你已经点过赞了"))
                return false
            }
            AnalysisManager.trackEvent(AnalysisManager.Event.click_good)
            return !entity.isAppreciated
        }) .flatMap({
            GamesNetServer.appreciateGame(gameId: entity.gameId).map({ [weak self] response -> Bool in
                self?.appreciationNumberLabel?.text = String(response["data"] as! Int)
                self?.appreciationImageView?.image = R.image.game_not_favorites()
                return true
            }).asDriver(onErrorRecover: { (error) in
                let blockyError = error as! BlockyError
                switch blockyError {
                case .withoutPlayGame:
                    BlockyHUD.showText(R.string.localizable.without_play_game(), inView: AppDelegate.keyWindow())
                default:
                    BlockyHUD.showText(R.string.localizable.common_request_fail_retry(), inView: AppDelegate.keyWindow())
                }
                return Driver.just(false)
            })
        }).map({
            !$0
        }).drive(appreciateButton!.rx.isEnabled).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameBasicInfoView: SDCycleScrollViewDelegate {
    
}

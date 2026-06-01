//
//  VIPViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/28.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class VIPViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return VIPInput.self}
    
    private weak var vipLabel: UILabel?
    private weak var scrollContainView: UIView?
    private weak var vipMenu: VIPMenu?
    fileprivate weak var privilegeTitleView: UIButton?
    private weak var collectionView: BMCollectionView?
    private weak var bottomContainView: UIView?
    private weak var vipLevelImageView: UIImageView?
    private weak var vipPriceLabel: UILabel?
    private let dataSource = BMCollectionViewDataSource(reuseCellType: VIPPrivilegeCollectionCell.self)
    fileprivate var privilegeEntities: [[VIPPrivilegeEntity]] = []
    fileprivate var itemSize: CGSize = .zero
    fileprivate var selectedVipLevel = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func createAndLayoutChildViews() {
        
        let containScrollView = UIScrollView().addTo(superView: view).configure { (scrollView) in
            scrollView.showsVerticalScrollIndicator = false
        }.layout { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollContainView = UIView().addTo(superView: containScrollView).layout { (make) in
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        vipLabel = UILabel().addTo(superView: scrollContainView!).configure({ (label) in
            label.backgroundColor = R.color.appColor._c8a16b()
            label.font = UIFont.size12
            label.textColor = R.color.appColor._fcf1de()
        }).layout(snapKitMaker: { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(29)
        })
        
        let thumbnailsCycleScrollView = UIImageView(image: R.image.game_banner()).addTo(superView: scrollContainView!).configure { (imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(9)
            make.top.equalTo(vipLabel!.snp.bottom).offset(5)
        }
//        let cycleViewW = UIScreen.main.bounds.width - 2 * 9
//        let thumbnailsCycleScrollView = SDCycleScrollView(frame: CGRect(x: 9, y: 34, width: cycleViewW, height: 110), delegate: self, placeholderImage: R.image.game_banner())
//        thumbnailsCycleScrollView?.bannerImageViewContentMode = .scaleAspectFill
//        thumbnailsCycleScrollView?.autoScrollTimeInterval = 5
//        thumbnailsCycleScrollView?.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
//        thumbnailsCycleScrollView?.currentPageDotColor = R.color.appColor._10f025()
//        thumbnailsCycleScrollView?.pageDotColor = UIColor.white
//        scrollContainView?.addSubview(thumbnailsCycleScrollView!)
        
        vipMenu = VIPMenu().addTo(superView: scrollContainView!).layout { (make) in
            make.left.right.equalToSuperview().inset(9)
            make.top.equalTo(thumbnailsCycleScrollView.snp.bottom).offset(5)
            make.height.equalTo(40)
        }.configure({ (menu) in
            menu.selectedIndex = 0
        })
        vipMenu!.rx.controlEvent(.valueChanged).asDriver().drive(onNext: {[unowned self] in
            self.refreshPrivileges(vipLevel: self.vipMenu!.selectedIndex)
        }).disposed(by: disposeBag)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.sectionInset = UIEdgeInsets(top: 60, left: 7, bottom: 7, right: 7)
        let itemWidth = (view.width - 2 * 9 - 2 * flowLayout.minimumLineSpacing - flowLayout.sectionInset.left * 2) / 3
        itemSize = CGSize(width: itemWidth, height: itemWidth * 0.9)
        flowLayout.itemSize = itemSize
        
        collectionView = BMCollectionView(frame: .zero, collectionViewLayout: flowLayout).addTo(superView: scrollContainView!)
        .configure {[unowned self] (collectionView) in
            collectionView.backgroundColor = R.color.appColor._cbad83()
            collectionView.bmDataSource = self.dataSource
            collectionView.bmDelegate = self
            collectionView.register(cellForClass: VIPPrivilegeCollectionCell.self)
            collectionView.bounces = false
        }
        
        privilegeTitleView = UIButton().addTo(superView: scrollContainView!).configure { (button) in
            button.isUserInteractionEnabled = false
            button.setBackgroundImage(R.image.vip_privilege_bg(), for: .normal)
            button.setTitle(R.string.localizable.vip_page_title(9, 9), for: .normal)
            button.titleLabel?.font = UIFont.size12
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: -3, left: 0, bottom: 3, right: 0)
        }.layout {[unowned self] (make) in
            make.top.equalTo(self.vipMenu!.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(36)
        }
        
        bottomContainView = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._341e00().withAlphaComponent(0.6)
        }.layout { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        vipLevelImageView = UIImageView(image: R.image.vip_page_0()).addTo(superView: bottomContainView!).layout(snapKitMaker: { (make) in
            make.left.equalToSuperview().offset(margin_16)
            make.top.equalToSuperview().offset(margin_12)
        })
        
        vipPriceLabel = UILabel().addTo(superView: bottomContainView!).layout(snapKitMaker: { (make) in
            make.left.equalTo(vipLevelImageView!.snp.right).offset(3)
            make.centerY.equalTo(vipLevelImageView!)
        })
        
        UILabel().addTo(superView: bottomContainView!).configure { (label) in
            label.font = UIFont.size11
            label.textColor = R.color.appColor._e4caa5()
            label.text = R.string.localizable.vip_discount_text()
        }.layout { [unowned self] (make) in
            make.left.equalTo(self.vipLevelImageView!)
            make.top.equalTo(self.vipLevelImageView!.snp.bottom).offset(8)
        }
        
        let paymentButton = UIButton().addTo(superView: bottomContainView!).configure { (button) in
            button.backgroundColor = R.color.appColor._d52626()
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont.size14
            button.setTitle(R.string.localizable.vip_pay_title(), for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
        }.layout { (make) in
            make.right.equalToSuperview().inset(margin_16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 36))
        }
        paymentButton.rx.tap.subscribe(onNext: {
            AppDelegate.globalServive().pushViewModel(VIPPaymentViewModel.self, params: nil, animated: true)
        }).disposed(by: disposeBag)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            bottomContainView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let vipOutput = output as! VIPOutput
        vipOutput.privilegeEntities.drive(onNext: { [unowned self] (entities) in
            self.privilegeEntities = entities
            let row = entities.first!.count % 3 == 0 ? entities.first!.count / 3 : entities.first!.count / 3 + 1
            self.collectionView?.layout(snapKitMaker: { (make) in
                make.top.equalTo(self.vipMenu!.snp.bottom)
                make.left.right.equalToSuperview().inset(9)
                make.height.equalTo(Int(self.itemSize.height) * row + 67 + (row - 1) * 3)
            })
            self.scrollContainView?.layout(snapKitMaker: { (make) in
                make.bottom.equalTo(self.collectionView!.snp.bottom).offset(50)
            })
            self.refreshPrivileges(vipLevel: 0)
        }).disposed(by: disposeBag)
        
        vipOutput.vipStatusText.drive(vipLabel!.rx.text).disposed(by: disposeBag)
    }
    
    private func refreshPrivileges(vipLevel: Int) {
        selectedVipLevel = vipLevel
        vipLevelImageView?.image = UIImage(named: "vip_page_\(vipLevel)")
        
        let privileges = privilegeEntities[vipLevel]
        dataSource.set([SectionObject(items: privileges)])
        let totalPrivilegeCount = privileges.count
        let enablePrivilegeCount = privileges.filter {
            $0.enable
        }.count
        privilegeTitleView?.setTitle(R.string.localizable.vip_page_title(enablePrivilegeCount, totalPrivilegeCount), for: .normal)
        switch vipLevel {
        case 0:
            privilegeTitleView?.setBackgroundImage(R.image.vip_privilege_bg(), for: .normal)
        case 1:
            privilegeTitleView?.setBackgroundImage(R.image.vip_plus_privilege_bg(), for: .normal)
        case 2:
            privilegeTitleView?.setBackgroundImage(R.image.mvp_privilege_bg(), for: .normal)
        default:
            break
        }
        vipPriceLabel?.attributedText = (viewModel as! VIPViewModel).vipPriceAttributedText(vipLevel: vipLevel)
        collectionView?.reloadData()
    }
}

extension VIPViewController: SDCycleScrollViewDelegate, BMCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppDelegate.globalServive().pushViewModel(VIPPrivilegeViewModel.self, params: privilegeEntities[selectedVipLevel][indexPath.item], animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

struct VIPInput: ViewToViewModelInput {
    init(view: BaseViewController) {
    }
}

//
//  VIPPrivilegeViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class VIPPrivilegeViewController: BaseViewController {

    private weak var bottomPayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = R.string.localizable.vip_detail_title()
    }
    
    override func createAndLayoutChildViews() {
        let containScrollView = UIScrollView().addTo(superView: view).configure { (scrollView) in
            scrollView.showsVerticalScrollIndicator = false
        }.layout { (make) in
            make.edges.equalToSuperview()
        }
        
        let scrollContainView = UIView().addTo(superView: containScrollView).layout { (make) in
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let privilegeEntity = params as! VIPPrivilegeEntity
        let thumbnailImageView = UIImageView().addTo(superView: scrollContainView).configure { (imageView) in
            imageView.image = UIImage(named: privilegeEntity.thumbnailName)
        }.layout { (make) in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        
        let titleView = UIButton().addTo(superView: scrollContainView).configure { (button) in
            button.setBackgroundImage(R.image.vip_privilege_detail_bg(), for: .normal)
            button.titleLabel?.font = UIFont.size15
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle(privilegeEntity.title, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        }.layout { (make) in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(29)
        }
        
        let detailContainView = UIView().addTo(superView: scrollContainView).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.top.equalTo(titleView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(10)
        }
        
        let seperatorView = UIView().addTo(superView: detailContainView).configure { (view) in
            view.backgroundColor = R.color.appColor._7a4e38()
        }.layout { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 2, height: 14))
        }
        
        UILabel().addTo(superView: detailContainView).configure { (label) in
            label.font = UIFont.boldSize15
            label.textColor = R.color.appColor._7a4e38()
            label.text = R.string.localizable.vip_detail_target()
        }.layout { (make) in
            make.left.equalTo(seperatorView.snp.right).offset(4)
            make.centerY.equalTo(seperatorView)
        }
        
        let supportLevelLabel = UILabel().addTo(superView: detailContainView).configure { (label) in
            label.font = UIFont.size15
            label.textColor = R.color.appColor._7a4e38()
            label.text = privilegeEntity.supportLevel
        }.layout { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(seperatorView.snp.bottom).offset(10)
        }
        
        let detailImageView = NetImageView().addTo(superView: detailContainView).configure { (imageView) in
            imageView.imageWithUrlString(privilegeEntity.thumbnailURLString)
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(supportLevelLabel.snp.bottom).offset(20)
            make.height.equalTo(150)
        }
        
        detailContainView.layout { (make) in
            make.bottom.equalTo(detailImageView.snp.bottom).offset(30)
        }
        scrollContainView.layout { (make) in
            make.bottom.equalTo(detailContainView.snp.bottom)
        }
        
        bottomPayView = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._341e00().withAlphaComponent(0.6)
        }.layout { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let paymentButton = UIButton().addTo(superView: bottomPayView!).configure { (button) in
            button.backgroundColor = R.color.appColor._d52626()
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont.size14
            button.setTitle(R.string.localizable.vip_pay_title(), for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(margin_16)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        paymentButton.rx.tap.subscribe(onNext: {
            AppDelegate.globalServive().pushViewModel(VIPPaymentViewModel.self, params: nil, animated: true)
        }).disposed(by: disposeBag)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            bottomPayView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
}

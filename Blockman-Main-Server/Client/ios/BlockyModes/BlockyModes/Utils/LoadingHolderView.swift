//
//  LoadingHolderView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/8.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

@objc protocol LoadingHolderViewDelegate : class {
    @objc optional func loadingHolderViewDidTap(_ loadingView: LoadingHolderView)
}

class LoadingHolderView: UIView {

    weak var delegate: LoadingHolderViewDelegate?
    
    private let disposeBag = DisposeBag()
    private weak var imageView: UIImageView?
    private weak var textLable: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._e7c99e()
        
        imageView = UIImageView().addTo(superView: self).configure({ (imageView) in
            imageView.image = R.image.loading_1()
            imageView.animationImages = [R.image.loading_1()!, R.image.loading_2()!, R.image.loading_3()!, R.image.loading_4()!]
            imageView.animationDuration = 0.6
            imageView.startAnimating()
        }).layout(snapKitMaker: { (make) in
            make.size.equalTo(CGSize(width: 29, height: 29))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
        })
        
        textLable = UILabel().addTo(superView: self).configure({ (label) in
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size14
            label.text = R.string.localizable.loading()
            label.textAlignment = .center
            label.numberOfLines = 0
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(imageView!.snp.bottom).offset(20)
            make.centerX.equalTo(imageView!)
            make.width.equalToSuperview().multipliedBy(0.6)
        })
    }
    
    public func withNoData(holder: String) {
        imageView?.stopAnimating()
        imageView?.image = R.image.loading_error()
        imageView!.snp.remakeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
        }
        textLable?.text = holder
        
    }
    
    func stopAnimating(holder: String?) {
        imageView?.stopAnimating()
        imageView?.image = R.image.loading_error()
        textLable?.text = holder
        
        if self.gestureRecognizers?.count != nil {
            return
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [unowned self] _ in
            guard let delegate = self.delegate else {
                return
            }
            self.imageView?.startAnimating()
            self.textLable?.text = R.string.localizable.loading()
            delegate.loadingHolderViewDidTap!(self)
        }).disposed(by: disposeBag)
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ProfileTableCell.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/22.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class ProfileTableCell: BMTableViewCell {

    let disposeBag = DisposeBag()
    
    private(set) weak var iconView: UIImageView?
    private(set) weak var titleLab: UILabel?
    private(set) weak var detailTitleLab: UILabel?
    private(set) weak var detailImageV:  NetImageView?
    private(set) weak var arrowIconView: UIImageView?
    private(set) weak var underline: UIView?
    private var titleToContentViewConstraint: Constraint!
    private var titleToIconViewViewConstraint: Constraint!
    private var underlineToContentViewNoneMarginConstraint: Constraint!
    private var underlineToContentViewHasMarginConstraint: Constraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = R.color.appColor._fae7ca()
        
        let iconV = UIImageView()
        contentView.addSubview(iconV)
        iconV.snp.makeConstraints { (make) in
            make.width.height.equalTo(33)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(13)
        }
        iconView = iconV
     
        let lab = UILabel().config(text: nil, textColor: R.color.appColor._333333(), font: UIFont.size15)
        contentView.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconV)
            titleToIconViewViewConstraint = make.left.equalTo(iconV.snp.right).offset(8).priority(900).constraint
            titleToContentViewConstraint = make.left.equalToSuperview().offset(16).priority(500).constraint
        }
        titleLab = lab
        
        let arrow = UIImageView(image: R.image.profile_arrow_right())
        contentView.addSubview(arrow)
        arrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(lab)
            make.right.equalToSuperview().offset(-16)
        }
        arrowIconView = arrow
        
        let detailLab = UILabel().config(text: "", textColor: R.color.appColor._666666(), textAlignment: .right)
        contentView.addSubview(detailLab)
        detailLab.snp.makeConstraints { (make) in
            make.width.equalTo(UIScreen.main.bounds.width * 0.5)
            make.centerY.equalTo(arrow)
            make.right.equalTo(arrow).offset(-16)
        }
        detailTitleLab = detailLab
        
        let detailImageV = NetImageView()
        contentView.addSubview(detailImageV)
        detailImageV.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.top.equalToSuperview().offset(12.5)
            make.bottom.equalToSuperview().offset(-12.5)
            make.right.equalTo(arrow).offset(-16)
        }
        self.detailImageV = detailImageV
        
        let line = UIView()
        line.backgroundColor = R.color.appColor._e7c99e()
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            underlineToContentViewHasMarginConstraint = make.left.equalToSuperview().offset(54).priority(900).constraint
            underlineToContentViewNoneMarginConstraint = make.left.equalToSuperview().priority(500).constraint
            make.height.equalTo(1)
        }
        underline = line
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let profile = entity as! ProfileTableCellEntity
        if profile.profileIsShowIconView {
            titleToIconViewViewConstraint.update(priority: 900)
            titleToContentViewConstraint.update(priority: 500)
        }else {
            titleToContentViewConstraint.update(priority: 900)
            titleToIconViewViewConstraint.update(priority: 500)
        }
        iconView?.isHidden = !profile.profileIsShowIconView
        iconView?.image = profile.profileIcon
        titleLab?.text = profile.profileTitle
        profile.profileDetailTitle?.drive(detailTitleLab!.rx.text).disposed(by: disposeBag)
        detailTitleLab?.isHidden = !profile.profileIsShowDetailTitle
        detailImageV?.isHidden = !profile.profileIsShowDetailImage
        profile.profileDetailImageUrl?.drive(onNext: {[weak self] in
            self?.detailImageV?.imageWithUrlString($0, placeHolder: R.image.common_default_userimage())
        }).disposed(by: disposeBag)
        underline?.isHidden = !profile.profileIsShowUnderline
        if profile.profileIsFillShowUnderline {
            underlineToContentViewNoneMarginConstraint.update(priority: 900)
            underlineToContentViewHasMarginConstraint.update(priority: 500)
        }else {
            underlineToContentViewHasMarginConstraint.update(priority: 900)
            underlineToContentViewNoneMarginConstraint.update(priority: 500)
        }
    }
}

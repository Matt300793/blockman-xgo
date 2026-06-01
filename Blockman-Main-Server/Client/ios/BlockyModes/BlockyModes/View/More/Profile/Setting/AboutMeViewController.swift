//
//  AboutMeViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/26.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class AboutMeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("about_me", comment: "关于Blocky Mods")
    }
    
    override func createAndLayoutChildViews() {
        
        let iconImageView = UIImageView().addTo(superView: view).configure { (imageView) in
            imageView.image = R.image.common_default_icon()
        }.layout { (make) in
            make.size.equalTo(CGSize(width: 83, height: 57))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        
        let appNameLabel = UILabel().addTo(superView: view).configure { (label) in
            label.font = UIFont.boldSize15
            label.textColor = R.color.appColor._666666()
            label.text = "Blocky Mods"
            label.textAlignment = .center
            }.layout { (make) in
                make.centerX.equalTo(iconImageView)
                make.top.equalTo(iconImageView.snp.bottom).offset(15)
        }
        
        UILabel().addTo(superView: view).configure { (label) in
            label.font = UIFont.size13
            label.textColor = R.color.appColor.text_normal()
            label.text = NSLocalizedString("version", comment: "版本") + AppInfo.currentShortVersion + " build " + AppInfo.currentBuildVersion
            label.textAlignment = .center
            }.layout { (make) in
                make.centerX.equalTo(appNameLabel)
                make.top.equalTo(appNameLabel.snp.bottom).offset(15)
        }
        
        // copyrightLabel
        UILabel().addTo(superView: view).configure { (label) in
            label.font = UIFont.size13
            label.textColor = R.color.appColor.text_normal()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = "copyright © 2018 Blocky Mods.\n"
            }.layout { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(15)
        }
    }
}

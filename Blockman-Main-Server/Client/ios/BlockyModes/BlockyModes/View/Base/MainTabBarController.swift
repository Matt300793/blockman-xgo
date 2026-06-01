//
//  MainTabBarController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        setValue(MainTabBar(), forKey: "tabBar")
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else {return}
        
        var barButtons: [UIView] = []
        for subView in tabBar.subviews { // 找出UITabBarButton
            if subView.isKind(of: NSClassFromString("UITabBarButton")!) {
                barButtons.append(subView)
            }
        }
        for subView in barButtons[index].subviews { // 找出UITabBarButton的UITabBarSwappableImageView
            if subView.isKind(of: NSClassFromString("UITabBarSwappableImageView")!) {
                subView.beatingAnimation()
                break
            }
        }
    }
}

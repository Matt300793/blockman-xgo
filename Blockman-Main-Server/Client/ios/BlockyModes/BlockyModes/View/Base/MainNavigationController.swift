//
//  MainNavigationController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    private let transitionController = TransitionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationBar.setBackgroundImage(R.image.common_nav_bg(), for: .default)
        navigationBar.backIndicatorImage = R.image.common_nav_back()?.withRenderingMode(.alwaysOriginal)
        navigationBar.backIndicatorTransitionMaskImage = R.image.common_nav_back()?.withRenderingMode(.alwaysOriginal)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : R.color.appColor._FEFEFE(), NSFontAttributeName : UIFont.size18]
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        modalPresentationStyle = .custom
        transitioningDelegate = transitionController
        rootViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController!.preferredStatusBarStyle
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController!.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController!.preferredInterfaceOrientationForPresentation
    }
}

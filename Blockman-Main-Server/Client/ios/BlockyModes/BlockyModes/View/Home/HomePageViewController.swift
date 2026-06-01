//
//  HomePageViewController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return HomePageInput.self}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        let barController = MainTabBarController()
        barController.delegate = self
        self.addChildViewController(barController)
        barController.view.frame = view.bounds
        self.view.addSubview(barController.view)
        barController.didMove(toParentViewController: self)
        
        let gameVC = GamesPageViewController(viewModelType: GamesPageViewModel.self)
        gameVC.tabBarItem = tabBarItem(title: NSLocalizedString("tab_title_games", comment: "游戏"), image: R.image.tabbar_game(), selectedImage: R.image.tabbar_game_selected())
        let gameNavigationController = MainNavigationController(rootViewController: gameVC)
        
        let decorationVC = DecorationViewController(viewModelType: DecorationViewModel.self)
        decorationVC.tabBarItem = tabBarItem(title: NSLocalizedString("tab_title_decoration", comment: "装饰"), image: R.image.tabbar_decoration(), selectedImage: R.image.tabbar_decoration_selected())
        let decorationNavigationController = MainNavigationController(rootViewController: decorationVC)
        
        let chatVC = ChatViewController(viewModelType: ChatViewModel.self)
        chatVC.tabBarItem = tabBarItem(title: NSLocalizedString("tab_title_chat", comment: "聊天"), image: R.image.tabbar_chat(), selectedImage: R.image.tabbar_chat_selected())
        let chatNavigationController = MainNavigationController(rootViewController: chatVC)
        
        let profileVC = ProfileViewController(viewModelType: ProfileViewModel.self)
        profileVC.tabBarItem = tabBarItem(title: NSLocalizedString("tab_title_profile", comment: "个人详情"), image: R.image.tabbar_more(), selectedImage: R.image.tabbar_more_selected())
        let profileNavigationController = MainNavigationController(rootViewController: profileVC)
        
        barController.viewControllers = [gameNavigationController, decorationNavigationController, /*chatNavigationController,*/ profileNavigationController]
        
        AppDelegate.delegate().navigationStack?.pushNavigationController(gameNavigationController)
        
        let homeViewModel = viewModel as! HomePageViewModel
        homeViewModel.checkVisitorInfo()
        homeViewModel.fetchProperty()
    }
    
    private func tabBarItem(title: String?, image: UIImage?, selectedImage: UIImage?) -> UITabBarItem {
        let barItem = UITabBarItem(title: title, image: image?.withRenderingMode(.alwaysOriginal), selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        barItem.setTitleTextAttributes([NSForegroundColorAttributeName : R.color.appColor.text_normal()], for: .normal)
        barItem.setTitleTextAttributes([NSForegroundColorAttributeName : R.color.appColor._FEFEFE()], for: .selected)
        return barItem
    }
}

extension HomePageViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            AnalysisManager.trackEvent(AnalysisManager.Event.home_game_tab)
        case 1:
            AnalysisManager.trackEvent(AnalysisManager.Event.home_dress_tab)
        case 2:
            AnalysisManager.trackEvent(AnalysisManager.Event.home_more_tab)
//            AnalysisManager.trackEvent(AnalysisManager.Event.home_chat_tab)
        case 3:
            AnalysisManager.trackEvent(AnalysisManager.Event.home_more_tab)
        default:
            break
        }
        var _ = AppDelegate.delegate().navigationStack?.popNavigationController()
        AppDelegate.delegate().navigationStack?.pushNavigationController(viewController as! UINavigationController)
    }
}

struct HomePageInput: ViewToViewModelInput {
    init(view: BaseViewController) {
    }
}

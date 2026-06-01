//
//  GamesPageViewController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/31.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa

class GamesPageViewController: BaseViewController {

    private(set)var pageController: UIPageViewController?
    
    fileprivate var recommendController: GamesRecommendViewController?
    fileprivate var categoryController: GamesCategoryViewController?
    fileprivate var gameSegmentControl: GamesSegmentControl?
    
    override var inputType: ViewToViewModelInput.Type? {return GamesPageInput.self }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.daily_task()?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.presentDailyTask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalysisManager.trackEvent(AnalysisManager.Event.home_view)
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        gameSegmentControl = GamesSegmentControl().addTo(superView: view).layout { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(30)
        }.configure { segmentControl in
            segmentControl.selectedIndex = 0
        }
        gameSegmentControl!.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            switch self.gameSegmentControl!.selectedIndex {
            case 0:
                self.pageController?.setViewControllers([self.recommendController!], direction: .reverse, animated: true, completion: nil)
                AnalysisManager.trackEvent(AnalysisManager.Event.home_reco)
            case 1:
                self.pageController?.setViewControllers([self.categoryController!], direction: .forward, animated: true, completion: nil)
                AnalysisManager.trackEvent(AnalysisManager.Event.home_class)
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        recommendController = GamesRecommendViewController(viewModelType: GamesRecommendViewModel.self)
        categoryController = GamesCategoryViewController(viewModelType: GamesCategoryViewModel.self)

        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-49)
        }
        self.pageController = pageController
        pageController.setViewControllers([recommendController!], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        pageController!.view.snp.remakeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalToSuperview().offset(30)
                make.left.right.bottom.equalToSuperview().inset(view.safeAreaInsets)
            }
        }
    }
    
    @objc private func presentDailyTask() {
        guard AccountStatusManager.shared.statusVariable.value != .visit else {
            BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.sign_in_after_login(), showCancel: true).done(closure: { (_) in
                AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true)
            })
            return
        }
        AppDelegate.globalServive().presentViewModel(DailyTaskViewModel.self, params: self, animated: true, completion: nil)
    }
}

extension GamesPageViewController: DailyTaskViewControllerDelegate, UIViewControllerTransitioningDelegate {
    func dailyTaskViewControllerDidClickedCloseButton(_ viewController: DailyTaskViewController) {
        AppDelegate.globalServive().dismissViewModel(animated: true, completion: nil)
    }
    
}

extension GamesPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if gameSegmentControl?.selectedIndex == 0 {
            return nil
        }
        
        return recommendController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if gameSegmentControl?.selectedIndex == 1 {
            return nil
        }
        return categoryController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard previousViewControllers.count != 0 else {
            return
        }
        
        if previousViewControllers.first == recommendController, completed {
            gameSegmentControl?.selectedIndex = 1
        }else {
            gameSegmentControl?.selectedIndex = 0
        }
    }
}

struct GamesPageInput: ViewToViewModelInput {
    init(view: BaseViewController) {
    }
}

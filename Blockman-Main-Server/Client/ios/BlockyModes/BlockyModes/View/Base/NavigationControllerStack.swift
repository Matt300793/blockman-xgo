//
//  NavigationControllerStack.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/16.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class NavigationControllerStack: NSObject {
    
    public let service: ViewModelService
    
    private var navigationControllers: [UINavigationController] = []
    private let disposeBag = DisposeBag()
    
    required init(viewModelService: ViewModelService) {
        service = viewModelService
        super.init()
        
        observeService()
    }
    
    public func pushNavigationController(_ navigationController: UINavigationController) {
        guard !navigationControllers.contains(navigationController) else {
            return
        }
        navigationController.delegate = self
        navigationControllers.append(navigationController)
    }
    
    @discardableResult
    public func popNavigationController() -> UINavigationController {
        let navigationController = navigationControllers.last!
        navigationControllers.removeLast()
        return navigationController
    }
    
    public func topNavigationController() -> UINavigationController {
        return navigationControllers.last!
    }
    
    private func observeService() {
        
        service.pushSubject.subscribe(onNext: { [unowned self] in
            if let topViewController = self.navigationControllers.last?.topViewController as? BaseViewController {
                if topViewController.tabBarController != nil {
                    topViewController.snapshot = topViewController.tabBarController!.view.snapshotView(afterScreenUpdates: false)
                }else {
                    topViewController.snapshot = self.navigationControllers.last?.view.snapshotView(afterScreenUpdates: false)
                }
            }
            let (viewModel, params, animated) = $0
            let view = Router.viewController(of: viewModel)
            view.params = params
            view.hidesBottomBarWhenPushed = true
            self.navigationControllers.last?.pushViewController(view, animated: animated)
        }).disposed(by: disposeBag)
        
        
        service.popSubject.subscribe(onNext: { [unowned self] animated in
            self.navigationControllers.last?.popViewController(animated: animated)
        }).disposed(by: disposeBag)
        
        
        service.popToRootSubject.subscribe(onNext: { [unowned self] animated in
            self.navigationControllers.last?.popToRootViewController(animated: animated)
        }).disposed(by: disposeBag)
        
        
        service.presentSubject.subscribe(onNext: { [unowned self] tuple in
            let (viewModel, params, animated, completion) = tuple
            let lastNavController = self.navigationControllers.last
            let viewController = Router.viewController(of: viewModel)
            viewController.params = params
            let presentNav = MainNavigationController(rootViewController: viewController)
            self.pushNavigationController(presentNav)
            lastNavController?.present(presentNav, animated: animated, completion: completion)
        }).disposed(by: disposeBag)
        
        
        service.dismissSubject.subscribe(onNext: { [unowned self] tuple in
            let (aniamted, completion) = tuple
            self.popNavigationController()
            self.navigationControllers.last?.dismiss(animated: aniamted, completion: completion)
        }).disposed(by: disposeBag)
        
        
        service.resetRootSubject.subscribe(onNext: { [unowned self] viewModel in
            self.navigationControllers.removeAll()
            var viewController = Router.viewController(of: viewModel) as UIViewController
            if !viewController.isKind(of: UINavigationController.self), !viewController.isKind(of: HomePageViewController.self) {
                viewController = MainNavigationController(rootViewController: viewController)
                self.pushNavigationController(viewController as! UINavigationController)
            }
            AppDelegate.delegate().window?.rootViewController = viewController
        }).disposed(by: disposeBag)
    }
}

extension NavigationControllerStack: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard (fromVC as! BaseViewController).interactivePopTransition != nil else {
            return nil
        }
        return PushAnimation(navigation: operation, from: fromVC as! BaseViewController, to: toVC as! BaseViewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as! PushAnimation).fromViewController?.interactivePopTransition
    }
}

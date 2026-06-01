//
//  BaseViewController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController, ViewToViewModelInputProvider, ShowErrorToast {

    public let disposeBag = DisposeBag()
    public var interactivePopTransition: UIPercentDrivenInteractiveTransition?
    public var params: Any?
    public var snapshot: UIView?
    public var inputType: ViewToViewModelInput.Type? {
        return nil
    }
    
    private let viewModelType: BaseViewModel.Type?
    private(set) var viewModel: BaseViewModel?

    required init(viewModelType: BaseViewModel.Type?) {
        self.viewModelType = viewModelType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = R.color.appColor._e7c99e()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationController?.delegate = self
        createAndLayoutChildViews()
        
        if navigationController != nil, self != navigationController?.viewControllers.first, !(self is DecorationShopViewController) {
            let popRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePopRecognizer(_:)))
            view.addGestureRecognizer(popRecognizer)
            popRecognizer.delegate = self
        }
        
        if let vmType = viewModelType, let input = self.provideInput() {
            viewModel = vmType.init(viewInput: input)
            viewModel?.viewTitle.asObservable().subscribe(onNext: { [weak self] viewTitle in
                self?.title = viewTitle
            }).disposed(by: disposeBag)
            if let output = viewModel?.provideOutput() {
                viewModelOutputDrive(output: output)
            }
        }   
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            snapshot = navigationController?.view.snapshotView(afterScreenUpdates: false)
        }
    }
    
    func createAndLayoutChildViews() {
    }
    
    func viewModelOutputDrive(output: ViewModelToViewOutput) {
        DebugLog("子类需要重载 viewModelOutputDrive(output:), 否则无法监听viewModel的数据流及更新界面UI")
    }
    
    @objc private func handlePopRecognizer(_ recognizer: UIPanGestureRecognizer) {
        var progress = recognizer.translation(in: view).x / view.width
        progress = min(1.0, max(0.0, progress))
        
        if recognizer.state == .began {
            interactivePopTransition = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        }else if recognizer.state == .changed {
            interactivePopTransition?.update(progress)
        }else if recognizer.state == .ended || recognizer.state == .cancelled {
            if progress > 0.2 {
                interactivePopTransition?.finish()
            }else {
                interactivePopTransition?.cancel()
            }
            interactivePopTransition = nil
        }
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: view).x > 0
    }
}

extension BaseViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard DeviceInfo.isPhone_X else {
            return
        }
        if let rect = self.tabBarController?.tabBar.frame {
            if rect.origin.y < UIScreen.main.bounds.height - 83 {
                self.tabBarController?.tabBar.frame.origin.y = UIScreen.main.bounds.height - 83
            }
        }
    }
}

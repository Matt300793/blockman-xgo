//
//  DailyTaskViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol DailyTaskViewControllerDelegate: class {
    func dailyTaskViewControllerDidClickedCloseButton(_ viewController: DailyTaskViewController)
}

class DailyTaskViewController: BaseViewController {

    public weak var delegate: DailyTaskViewControllerDelegate?
    
    override var inputType: ViewToViewModelInput.Type? {return DailyTaskInput.self}
    
    fileprivate let dataSource = BMCollectionViewDataSource(reuseCellType: DailyTaskCollectionCell.self)
    fileprivate let tasksBehavior = BehaviorSubject.init(value: ())
    fileprivate let taskTypePublish = PublishSubject<Int>()
    fileprivate var adsManager: UnityVideoAdsManager!
    private weak var updateTimeLabel: UILabel?
    private weak var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        adsManager = UnityVideoAdsManager(presentingController: self, delegate: self)
        delegate = params as? GamesPageViewController
    }
    
    override func createAndLayoutChildViews() {
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        let containView = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.43)
            make.center.equalToSuperview()
        }
        
        let titleView = UIButton().addTo(superView: containView).configure { (button) in
            button.isUserInteractionEnabled = false
            button.setBackgroundImage(R.image.daily_task_title_bg(), for: .normal)
            button.titleLabel?.font = UIFont.size13
            button.setTitle(R.string.localizable.golds_gift(), for: .normal)
            button.setTitleColor(R.color.appColor._8f4d00(), for: .normal)
        }.layout { (make) in
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = BMCollectionView(frame: .zero, collectionViewLayout: flowLayout).addTo(superView: containView).configure { (collectionView) in
            collectionView.backgroundColor = UIColor.clear
            collectionView.register(cellForClass: DailyTaskCollectionCell.self)
            collectionView.bmDataSource = self.dataSource
            collectionView.bmDelegate = self
            collectionView.bounces = false
        }.layout { (make) in
            make.top.equalTo(titleView.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(46)
            make.bottom.equalToSuperview().inset(76)
        }
        
        updateTimeLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.font = UIFont.size11
            label.textColor = R.color.appColor._666666()
            label.textAlignment = .center
        }.layout(snapKitMaker: { (make) in
            make.top.equalTo(collectionView!.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        })
        
        let closeButton = UIButton().addTo(superView: containView).configure { (button) in
            button.setTitleColor(R.color.appColor._0ab950(), for: .normal)
            button.setTitle(R.string.localizable.close(), for: .normal)
        }.layout { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        closeButton.rx.tap.subscribe(onNext: {[unowned self] in
            self.delegate?.dailyTaskViewControllerDidClickedCloseButton(self)
        }).disposed(by: disposeBag)
        
        UIView().addTo(superView: containView).configure { (view) in
            view.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(closeButton.snp.top)
            make.height.equalTo(1)
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let dailyTaskOutput = output as! DailyTaskOutput
        dailyTaskOutput.dailyTasks.drive(onNext: { [weak self] (entity) in
            self?.updateTimeLabel?.text = entity.updateTime
            self?.dataSource.set([SectionObject(items: entity.tasks)])
            self?.collectionView?.reloadData()
            if UnityVideoAdsManager.unityIsInitialized() {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { 
                    self?.setWatchVideoButtonEnable(true)
                })
            }
        }).disposed(by: disposeBag)
        
        dailyTaskOutput.signInResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
                self.tasksBehavior.onNext(())
                BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.common_receive_success(), showCancel: false)
            case .fail(.hasSignedIn):
                BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("daily_task_already_received", comment: ""), showCancel: false)
            default:
                BlockyHUD.showText(R.string.localizable.common_request_fail_retry(), inView: self.view)
            }
        }).disposed(by: disposeBag)
    }
    
    fileprivate func setWatchVideoButtonEnable(_ enable: Bool) {
        guard let cells = collectionView?.visibleCells.reversed(), let watchVideoCell = cells.last as? DailyTaskCollectionCell, cells.count == 2 else {
            return
        }

        let entity = dataSource.sectionObject(for: 0).item(at: 1) as! TaskItemEntity
        if entity.status != 0 {
            BlockyUserDefaults.removeValue(forKey: BlockyUserDefaults.dailyWatchVideoAdsTimeIntervalKey)
            watchVideoCell.setSignInButtonEnable(false)
            return
        }
        let watchedTimeInterval = BlockyUserDefaults.timeInterval(forKey: BlockyUserDefaults.dailyWatchVideoAdsTimeIntervalKey)
        let canWatch = watchedTimeInterval == 0 || (Date().timeIntervalSince1970 - watchedTimeInterval) > 3600
        watchVideoCell.setSignInButtonEnable(entity.status == 0 && enable && canWatch)
    }
}

extension DailyTaskViewController: BMCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width - 30) / 2, height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let taskCell = cell as! DailyTaskCollectionCell
        taskCell.delegate = self
    }
}

extension DailyTaskViewController: DailyTaskCollectionCellDelegate {
    func dailyTaskCell(_ cell: DailyTaskCollectionCell, didClickedSignInButton cellEntity: TaskItemEntity) {
        guard cellEntity.type == 3 else {
            taskTypePublish.onNext(cellEntity.type)
            return
        }
        BlockyUserDefaults.storeTimeInterval(Date().timeIntervalSince1970, forKey: BlockyUserDefaults.dailyWatchVideoAdsTimeIntervalKey)
        adsManager.show()
    }
}

extension DailyTaskViewController: UnityVideoAdsManagerDelegate {
    func adsReady(_ manager: UnityVideoAdsManager) {
        setWatchVideoButtonEnable(true)
    }
    
    func adsDidError(_ manager: UnityVideoAdsManager) {
        setWatchVideoButtonEnable(false)
        BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("video_load_failed_close_retry", comment: ""))
    }
    
    func adsDidFinish(_ manager: UnityVideoAdsManager, with state: UnityVideoAdsManager.VideoAdsFinishState) {
        switch state {
        case .completed:
            taskTypePublish.onNext(3)
        default:
            break
        }
    }
}

struct DailyTaskInput: ViewToViewModelInput {
    let taskTypeInput: Driver<Int>
    let fetchTasksInput: Driver<()>
    
    init(view: BaseViewController) {
        let taskView = view as! DailyTaskViewController
        fetchTasksInput = taskView.tasksBehavior.asDriver(onErrorJustReturn: ())
        taskTypeInput = taskView.taskTypePublish.asDriver(onErrorJustReturn: 0)
    }
}

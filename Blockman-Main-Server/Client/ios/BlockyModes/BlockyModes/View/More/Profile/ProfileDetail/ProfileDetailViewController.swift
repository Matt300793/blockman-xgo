//
//  ProfileDetailViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileDetailViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return ProfileDetailInput.self}
    
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: ProfileTableCell.self)
    private weak var tableView: BMTableView?
    
    fileprivate let genderSubject = PublishSubject<Int>()
    fileprivate let birthdaySubject = PublishSubject<String>()
    fileprivate let pickerImageController: ImagePickerController = ImagePickerController()
    fileprivate let picFilePathSubject = PublishSubject<String>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func createAndLayoutChildViews() {
        
        tableView = BMTableView().addTo(superView: view).configure { [unowned self] (tableView) in
            tableView.bmDelegate = self
            tableView.bmDataSource = self.dataSource
            tableView.register(cellForClass: ProfileTableCell.self)
        }.layout { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            tableView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        
        let profileDetailOutput = output as! ProfileDetailOutput
        
        profileDetailOutput.profileDetailResults.drive(onNext: { [unowned self] objects in
            self.dataSource.set(objects)
            self.tableView?.reloadData()
        }).disposed(by: disposeBag)
    
        profileDetailOutput.genderPickResult.drive(onNext: { [unowned self] code in
            switch code {
            case .success:
                BlockyHUD.showText(NSLocalizedString("modify_success", comment: "修改成功"), inView: self.view)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
        
        profileDetailOutput.birthdayPickResult.drive(onNext: {[unowned self] code in
            switch code {
            case .success:
                AnalysisManager.trackEvent(AnalysisManager.Event.more_bir_suc)
                BlockyHUD.showText(NSLocalizedString("modify_success", comment: "修改成功"), inView: self.view)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
        
        profileDetailOutput.portraitUploadResult.drive(onNext: { [unowned self] in
            if $0 {
                AnalysisManager.trackEvent(AnalysisManager.Event.more_head_suc)
                BlockyHUD.showText(NSLocalizedString("upload_success", comment: "上传成功"), inView: self.view)
            }else{
                BlockyHUD.showText(NSLocalizedString("upload_fail_retry", comment: "上传失败，请重试"), inView: self.view)
            }
        }).disposed(by: disposeBag)
    }
    
    fileprivate func showGenderPickerView() {
        let genderPickerView = GenderPickerView()
        genderPickerView.delegate = self
        AppDelegate.delegate().window?.addSubview(genderPickerView)
        genderPickerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    fileprivate func showBirthdayPickerView() {
        let birthdayPickerView = DatePickerView()
        birthdayPickerView.delegate = self
        AppDelegate.delegate().window?.addSubview(birthdayPickerView)
        birthdayPickerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension ProfileDetailViewController: BMTableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            pickerImageController.present(from: self, delegate: self, popoverSourceViewForIPad:tableView.cellForRow(at: indexPath))
        case (1, 0):
            BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("nickname_can_not_modify", comment: "昵称暂不支持修改"))
        //            AppDelegate.globalServive().pushViewModel(ModifyNickNameViewModel.self, params: nil, animated: true)
        case (1, 1):
            BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("gender_can_not_modify", comment: "性别暂不支持修改"))
        //            showGenderPickerView()
        case (1, 2):
            showBirthdayPickerView()
        case (1, 3):
            AppDelegate.globalServive().pushViewModel(ModifyIntroductionViewModel.self, params: nil, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return margin_12
    }
}

extension ProfileDetailViewController: GenderPickerViewDelegate, DatePickerViewDelegate, ImagePickerControllerDelegate {
    func genderPickerDidPicked(_ gender: String, index: Int) {
        genderSubject.onNext(index)
    }
    
    func datePickerDidPicked(_ date: String) {
        birthdaySubject.onNext(date)
    }
    
    func imagePickerDidPickedImage(_ image: PickedImage) {
        picFilePathSubject.onNext(image.fileURLString)
    }
}

struct ProfileDetailInput: ViewToViewModelInput {
    let genderInput: Driver<Int>
    let birthdayInput: Driver<String>
    let picFilePathInput: Driver<String>
    
    init(view: BaseViewController) {
        let profileDetailView = view as! ProfileDetailViewController
        genderInput = profileDetailView.genderSubject.asDriver(onErrorJustReturn: 1)
        birthdayInput = profileDetailView.birthdaySubject.asDriver(onErrorJustReturn: "")
        picFilePathInput = profileDetailView.picFilePathSubject.asDriver(onErrorJustReturn: "")
    }
}

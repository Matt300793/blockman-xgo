//
//  MailContentViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MailContentViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return MailContentInput.self}
    
    fileprivate let updateMailStatusPublish = PublishSubject<(MailboxEntity.Status, Int64)>()
    fileprivate let receiveAttachmentPublish = PublishSubject<Int64>()
    private weak var operateButton: UIButton?
    private weak var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let entity = params as! MailboxEntity
        if entity.attachments.count == 0 {
            updateMailStatusPublish.onNext((.read, entity.id))
        }
        title = entity.title
    }

    override func createAndLayoutChildViews() {
        
        let entity = params as! MailboxEntity
        
        let scrollView = UIScrollView().addTo(superView: view).layout { (make) in
            make.edges.equalToSuperview()
        }
        
        let scrollContainView = UIView().addTo(superView: scrollView).layout { (make) in
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let titleLabel = UILabel().addTo(superView: scrollContainView).configure { (label) in
            label.font = UIFont.size14
            label.textColor = R.color.appColor._333333()
            label.text = R.string.localizable.mail_title() + entity.title
            label.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.top.left.right.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        let contentView = UIView().addTo(superView: scrollContainView).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(1)
        }
        
        let contentTipLabel = UILabel().addTo(superView: contentView).configure { (label) in
            label.font = UIFont.size13
            label.textColor = R.color.appColor._333333()
            label.text = R.string.localizable.mail_content()
        }.layout { (make) in
            make.left.top.equalToSuperview().offset(16)
        }
        
        let contentLabel = UILabel().addTo(superView: contentView).configure { (label) in
            label.font = UIFont.size13
            label.textColor = R.color.appColor._333333()
            label.numberOfLines = 0
            label.text = "         " + entity.content
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(contentTipLabel.snp.bottom).offset(10)
        }
        
        let expireDateLabel = UILabel().addTo(superView: contentView).configure { (label) in
            label.font = UIFont.size11
            label.textColor = R.color.appColor._666666()
            label.textAlignment = .right
            label.text = R.string.localizable.mail_delete_after_fifteen_days()
        }.layout { (make) in
            make.right.equalToSuperview().inset(10)
            make.top.equalTo(contentLabel.snp.bottom).offset(30)
        }
        contentView.layout { (make) in
            make.bottom.equalTo(expireDateLabel.snp.bottom).offset(15)
        }
        
        let attachmentView = UIView().addTo(superView: scrollContainView).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(contentView.snp.bottom).offset(2)
        }
        
        let attachLabel = UILabel().addTo(superView: attachmentView).configure { (label) in
            label.font = UIFont.size14
            label.textColor = R.color.appColor._333333()
            label.text = R.string.localizable.mail_attachment()
        }.layout { (make) in
            make.top.left.equalToSuperview().offset(10)
        }
        
        let attachCount = entity.attachments.count
        let row = attachCount % 5 == 0 ? attachCount / 5 : attachCount / 5 + 1
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).addTo(superView: attachmentView).configure { (collectionView) in
            collectionView.backgroundColor = UIColor.clear
            collectionView.register(cellForClass: MailAttachmentCollectionCell.self)
            collectionView.bounces = false
            collectionView.dataSource = self
            collectionView.delegate = self
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(attachLabel.snp.bottom).offset(15)
            make.height.equalTo(row * 50 + (row - 1) * 10)
        }
        attachmentView.layout { (make) in
            make.bottom.equalTo(collectionView!.snp.bottom).offset(30)
        }
        
        operateButton = UIButton().addTo(superView: scrollContainView).configure { (button) in
            button.setDefaultStyle(fontSize: 16)
            button.setTitleColor(R.color.appColor.white(), for: .normal)
            if entity.attachments.count != 0 {
                button.setTitle(entity.status != .read ? R.string.localizable.receive() : R.string.localizable.common_delete(), for: .normal)
            }else {
                button.setTitle(R.string.localizable.common_delete(), for: .normal)
            }
        }.layout { (make) in
            make.width.equalToSuperview().multipliedBy(0.6)
            make.top.equalTo(attachmentView.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        operateButton!.rx.tap.subscribe(onNext: { [unowned self] in
            if entity.attachments.count == 0 {
                self.updateMailStatusPublish.onNext((.deleted, entity.id))
            }else {
                entity.status != .read ? self.receiveAttachmentPublish.onNext(entity.id) : self.updateMailStatusPublish.onNext((.deleted, entity.id))
            }
        }).disposed(by: disposeBag)
        
        scrollContainView.layout { (make) in
            make.bottom.equalTo(operateButton!.snp.bottom).offset(15)
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let mailContentOutput = output as! MailContentOutput
        mailContentOutput.updateStautsResult.drive(onNext: {[weak self] (tuple) in
            let (status, isSuccessful) = tuple
            let entity = self?.params as! MailboxEntity
            switch status {
            case .deleted:
                isSuccessful ? entity.updateStatus(.deleted) : entity.updateStatus(.read)
                BlockyHUD.showText(isSuccessful ? R.string.localizable.common_delete_success() : R.string.localizable.common_delete_fail(), inView: self!.view)
                if isSuccessful {
                    AppDelegate.globalServive().popViewModel(animated: true)
                }
            case .read:
                isSuccessful ? entity.updateStatus(.deleted) : entity.updateStatus(.send)
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        mailContentOutput.receiveAttachResult.drive(onNext: { [unowned self] (isSuccessful) in
            let entity = self.params as! MailboxEntity
            entity.updateStatus(.read)
            BlockyAlert.show(title: R.string.localizable.notification(), message: isSuccessful ? R.string.localizable.common_receive_success() : R.string.localizable.common_request_fail_retry())
            if isSuccessful {
                self.operateButton?.setTitle(R.string.localizable.common_delete(), for: .normal)
                self.updateProperty()
            }
            self.collectionView?.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func updateProperty() {
        RechargeNetServer.fetchProperty().mapModel(type: UserPropertyModel.self).asObservable().subscribe(onNext: { (propertyModel) in
            AccountPropertyManager.shared.updateProperty(propertyModel)
        })
        .disposed(by: disposeBag)
    }
}

extension MailContentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (params as! MailboxEntity).attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as MailAttachmentCollectionCell
        cell.bindToAttachmentEntity((params as! MailboxEntity).attachments[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView.width - 5 * 50) / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

struct MailContentInput: ViewToViewModelInput {
    let updateMailStatusInput: Driver<(MailboxEntity.Status, Int64)>
    let receiveAttachInput: Driver<Int64>
    
    init(view: BaseViewController) {
        let mailContentView = view as! MailContentViewController
        updateMailStatusInput = mailContentView.updateMailStatusPublish.asDriver(onErrorJustReturn: (.send, 0))
        receiveAttachInput = mailContentView.receiveAttachmentPublish.asDriver(onErrorJustReturn: 0)
    }
}

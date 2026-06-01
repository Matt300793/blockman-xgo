//
//  DatePickerView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

protocol DatePickerViewDelegate: class {
    func datePickerDidPicked(_ date: String)
}

class DatePickerView: UIView {
    
    fileprivate let disposeBag = DisposeBag()
    private weak var pickerView: UIDatePicker?
    weak var delegate: DatePickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        pickerView = UIDatePicker().addTo(superView: self).configure { (picker) in
            picker.tintColor = R.color.appColor._666666()
            picker.backgroundColor = R.color.appColor._fae7ca()
            picker.datePickerMode = .date
            picker.setDate(Date(), animated: true)
            }.layout { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(180)
                make.height.equalTo(180)
                self.layoutIfNeeded()
        }
        
        UIButton().addTo(superView: self).configure { (button) in
            button.titleLabel?.font = UIFont.size15
            button.setTitle("取消", for: .normal)
            button.setTitleColor(R.color.appColor._666666(), for: .normal)
            }.layout { (make) in
                make.size.equalTo(CGSize(width: 65, height: 20))
                make.left.equalToSuperview()
                make.top.equalTo(pickerView!).offset(5)
            }.rx.tap.subscribe(onNext: { [weak self] in
                self?.dismiss()
            }).disposed(by: disposeBag)
        
        UIButton().addTo(superView: self).configure { (button) in
            button.titleLabel?.font = UIFont.size15
            button.setTitle("确定", for: .normal)
            button.setTitleColor(R.color.appColor._0ab950(), for: .normal)
            }.layout { (make) in
                make.size.equalTo(CGSize(width: 65, height: 20))
                make.top.equalTo(pickerView!).offset(5)
                make.right.equalToSuperview()
            }.rx.tap.subscribe(onNext: { [weak self] in
                self?.dismiss()
                self?.delegate?.datePickerDidPicked(self!.pickerView!.date.convertToString(formatter: "yyyy-MM-dd"))
            }).disposed(by: disposeBag)
        
        pickerView?.snp.updateConstraints({ (make) in
            make.bottom.equalToSuperview()
        })
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        pickerView?.snp.updateConstraints({ (make) in
            make.bottom.equalToSuperview().offset(180)
        })
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
        }, completion: { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }
    
}

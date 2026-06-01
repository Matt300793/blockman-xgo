//
//  GenderPickerView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

protocol GenderPickerViewDelegate: class {
    func genderPickerDidPicked(_ gender: String, index: Int)
}

class GenderPickerView: UIView {
    
    weak var delegate: GenderPickerViewDelegate?
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let dataSource = ["男", "女"]
    fileprivate var selectedGender = "男"
    fileprivate var selectedIndex = 1
    private weak var pickerView: UIPickerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        pickerView = UIPickerView().addTo(superView: self).configure({ (picker) in
            picker.tintColor = R.color.appColor._666666()
            picker.backgroundColor = R.color.appColor._fae7ca()
            picker.dataSource = self
            picker.delegate = self
        }).layout(snapKitMaker: { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(180)
            make.height.equalTo(180)
            self.layoutIfNeeded()
        })
        
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
                self?.delegate?.genderPickerDidPicked(self!.selectedGender, index: self!.selectedIndex)
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

extension GenderPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = dataSource[row]
        selectedIndex = row + 1
    }
}

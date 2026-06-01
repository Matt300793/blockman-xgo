//
//  CaptchaCountDownButton.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/7.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class CaptchaCountDownButton: UIButton {

    private var timer: Timer?
    private var originCountDown: Int
    private var second: Int
    
    init(countDown: Int) {
        originCountDown = countDown
        second = countDown
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        
        super.addTarget(target, action: action, for: controlEvents)
    }

    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        second = originCountDown
        super.sendAction(action, to: target, for: event)
    }
    
    @objc func updateTime() {
        second -= 1
        if second == 0 {
            timer?.invalidate()
            timer = nil
            self.isEnabled = true
        }else {
            self.setTitle(String(second) + "s后重新发送", for: .disabled)
            self.isEnabled = false
        }
    }
}

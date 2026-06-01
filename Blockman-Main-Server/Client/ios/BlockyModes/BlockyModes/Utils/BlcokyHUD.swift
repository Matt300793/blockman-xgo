//
//  BlcokyHUD.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/19.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

struct BlockyHUD {
    
    /// MARK: 展示指示器，不会自动隐藏
    public static func showLoading(inView view: UIView) {
        let showingHUD = hud(forView: view)
        showingHUD.mode = .indeterminate
        showingHUD.show(animated: true)
    }
    
    /// 只有文字提示，view表示显示的主view，默认0.5秒后消失
    public static func showText(_ text: String?, inView view: UIView, hideAfter delay: TimeInterval = 0.5) {
        let showingHUD = hud(forView: view)
        showingHUD.mode = .text
        showingHUD.offset = CGPoint(x: 0.0, y: MBProgressMaxOffset)
        showingHUD.label.text = text
        showingHUD.label.font = UIFont.systemFont(ofSize: 14)
        showingHUD.hide(animated: true, afterDelay: delay)
    }
    
    /// 展示指示器跟文字提示，view表示显示的主view，不会自动隐藏
    public static func showLoading(withText text: String, inView view: UIView) {
        let showingHUD = hud(forView: view)
        showingHUD.mode = .indeterminate
        showingHUD.label.text = text
        showingHUD.label.font = UIFont.systemFont(ofSize: 14)
        showingHUD.show(animated: true)
    }
    
    /// 展示成功/完成状态，view表示显示的主view，默认0.5秒消失
    public static func showSuccess(text: String, inView view: UIView) {
        let showingHUD = hud(forView: view)
        showingHUD.customView = UIImageView(image: UIImage(named: "hud_done"))
        showingHUD.mode = .customView
        showingHUD.label.text = text
        showingHUD.label.font = UIFont.systemFont(ofSize: 14)
        showingHUD.hide(animated: true, afterDelay: 0.5)
    }
    
    /// 默认立即隐藏，并从父View移除
    /// 可配置时间
    public static func hide(forView view: UIView, afterDelay: TimeInterval = 0) {
        let showingHUD = hud(forView: view)
        showingHUD.hide(animated: true, afterDelay: afterDelay)
    }
    
    private static func hud(forView view: UIView) -> MBProgressHUD {
        var hud = MBProgressHUD(for: view)
        if hud == nil {
            hud = MBProgressHUD.init(view: view)
            hud?.removeFromSuperViewOnHide = true
            view.addSubview(hud!)
            hud?.show(animated: true)
        }
        return hud!;
    }
}

//
//  NetImageView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import Kingfisher

class NetImageView: UIImageView {

    func imageWithUrlString(_ urlString: String?, placeHolder: UIImage? = nil) {
        guard let url = urlString else {
            if placeHolder != nil {
                self.image = placeHolder
            }
            return
        }
        
        self.kf.setImage(with: URL.init(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: placeHolder, options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
    }

}

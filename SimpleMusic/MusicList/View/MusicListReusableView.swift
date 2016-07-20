//
//  MusicListReusableView.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/6.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicListReusableView: UICollectionReusableView {
        
    @IBOutlet weak var typeBtn: UIButton!
    
    override func awakeFromNib() {
        typeBtn.layer.borderColor = HttpHelper.getColorWith(0xCC4546).CGColor
        typeBtn.layer.borderWidth = 1
        typeBtn.layer.cornerRadius = 3
        typeBtn.layer.masksToBounds = true
    }
}

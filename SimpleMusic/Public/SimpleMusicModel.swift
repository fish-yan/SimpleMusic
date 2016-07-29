//
//  SimpleMusicModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/29.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class SimpleMusicModel: BaseModel {
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
        if key == "urlList" {
            if value is NSArray {
                let array = value as! NSArray
                if array.count != 0 {
                    let dict = array.lastObject as! NSDictionary
                    songUrl = dict["url"] as? String
                }
            }
        }
        
    }
}

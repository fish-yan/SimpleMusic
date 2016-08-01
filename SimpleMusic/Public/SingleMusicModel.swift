//
//  SingleMusicModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/21.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class SingleMusicModel: NSObject {
    var albumName: String?
    var songUrl: String?
    var name: String?
    var singerName: String?
    var songId: NSNumber?
    var singerId: NSNumber?
    var picUrl: String?
    var downType: NSNumber?
    var filePath: String?
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

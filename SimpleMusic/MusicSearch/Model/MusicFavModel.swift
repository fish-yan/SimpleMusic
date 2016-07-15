//
//  MusicFavModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/11.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicFavModel: NSObject {
    var name: String!
    var songUrl: String!
    var singerName: String!
    var songId: NSNumber!
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        if key == "llList" {
            if value is NSArray {
                let array = value as! NSArray
                if array.count != 0 {
                    let dict = array.lastObject as! NSDictionary
                    songUrl = dict["url"] as! String
                }
            }
        }
        if songUrl == nil && key == "urlList" {
            if value is NSArray {
                let array = value as! NSArray
                if array.count != 0 {
                    let dict = array.lastObject as! NSDictionary
                    songUrl = dict["url"] as! String
                }
            }
        }
    }
}

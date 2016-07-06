//
//  MusicListModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicListModel: NSObject {
    var id: String?
    var author: String?
    var pic_url: String?
    var title: String?
    var songList: NSArray?
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
        if key == "song_list" {
            let songIDStr = value as? String
            songList = songIDStr?.componentsSeparatedByString(",")
        }
        
        if key == "_id" {
            let songId = value as? NSNumber
            id = "\(songId)"
        }
    }
}

//
//  MusicModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/20.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicModel: NSObject {
    var searchType: String! //搜索类型
    var name: String! // 歌名 //专辑名
    var title: String! // 歌单名
    var songUrl: String! // 歌曲url
    var singerName: String! // 歌手
    var songId: NSNumber! // 歌曲id
    var singerId: NSNumber! // 歌手id
    var picUrl: String! // 图片url
    var songListId: NSNumber! // 歌单id
    var songs: NSArray! // 歌曲id数组
    var albumName: String! //专辑名称
    var album_num: NSNumber! // 专辑数量
    var albumId: NSNumber! // 专辑id
    var song_num: NSNumber! // 歌曲数量
    
    override init() {
        super.init()
        picUrl = "http://img.sccnn.com/bimg/338/16031.jpg"
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
        if key == "llList" {
            if value is NSArray {
                let array = value as! NSArray
                if array.count != 0 {
                    let dict = array.lastObject as! NSDictionary
                    songUrl = dict["url"] as? String
                }
            }
        }
        
        if songUrl == nil && key == "urlList" {
            if value is NSArray {
                let array = value as! NSArray
                if array.count != 0 {
                    let dict = array.lastObject as! NSDictionary
                    songUrl = dict["url"] as? String
                }
            }
        }
        
        if key == "singer_name" {
            singerName = value as? String
        }
        
        if key == "_id" {
            singerId = value as! NSNumber
        }
        
        if key == "pic_url" {
            picUrl = value as? String
        }
        
        if key == "song_list" {
            let songIDStr = value as? String
            songs = songIDStr?.componentsSeparatedByString(",")
        }
        
        if key == "quan_id" {
            songListId = value as? NSNumber
        }
    }
}

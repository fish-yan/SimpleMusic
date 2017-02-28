//
//  XYPlayer.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/9/2.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class XYPlayer: NSObject {
    // public
    
    // private
    let player = AVPlayer()
    
    init(url: String, local: Bool) {
        super.init()
        creatPlayerWithURLStr(url, local: local)
    }
    
    
    func creatPlayerWithURLStr(url: String, local: Bool) {
        let playerItem: AVPlayerItem
        if local {
            let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
            let path1 = NSString(string: caches!)
            let path2 = path1.stringByAppendingPathComponent(url)
            let asset = AVAsset(URL: NSURL(fileURLWithPath: path2))
            playerItem = AVPlayerItem(asset: asset)
        } else {
            guard let musicURL = NSURL(string: url) else {
                return
            }
            playerItem = AVPlayerItem(URL: musicURL)
        }
        
        player.replaceCurrentItemWithPlayerItem(playerItem)
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        playerItem.addObserver(self, forKeyPath:"loadedTimeRanges" ,options:NSKeyValueObservingOptions.New, context:nil)
    }
    
}

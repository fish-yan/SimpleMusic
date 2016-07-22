//
//  MusicPlayerView.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/6.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

import AVFoundation

class MusicPlayerView: UIView {
    static let sharePlayer = MusicPlayerView(frame: CGRect(x: 0, y: kScreenHeight - 84, width: kScreenWidth, height: kScreenHeight))
    var player = AVPlayer()
    
    @IBOutlet weak var endTimeLab: UILabel!
    @IBOutlet weak var beginTimeLab: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var topPlayerBtn: UIButton!
    @IBOutlet weak var musicTitleLab: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var navHeightMargin: NSLayoutConstraint!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageTopMargin: NSLayoutConstraint!
    @IBOutlet weak var imageLedingMargin: NSLayoutConstraint!
    @IBOutlet weak var imageHeightMargin: NSLayoutConstraint!
    @IBOutlet weak var imageWidthMargin: NSLayoutConstraint!
    var model = SingleMusicModel()
    var minY:CGFloat = kScreenHeight - 84
    var songIdArray = NSArray()
    var currentIndex = 0
    private override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadNib() {
        let nib = UINib(nibName: "MusicPlayerView", bundle: nil)
        let playerView = nib.instantiateWithOwner(self, options: nil).last as! UIView
        playerView.frame = self.bounds
        addSubview(playerView)
        let tap = UITapGestureRecognizer(target: self
            , action: #selector(tapGestureAction(_:)))
        addGestureRecognizer(tap)
        configureView()
    }
    
    private func configureView() {
        UIView.animateWithDuration(0.25) { 
            self.frame = CGRect(x: 0, y: self.minY, width: kScreenWidth, height: kScreenHeight)
            self.layoutIfNeeded()
        }
        if minY == kScreenHeight - 84 {
            backBtn.hidden = true
            topPlayerBtn.hidden = false
            musicTitleLab.textAlignment = .Left
            
        } else {
            backBtn.hidden = false
            topPlayerBtn.hidden = true
            musicTitleLab.textAlignment = .Center
            
        }
    }
    
    @IBAction private func backBtnAction(sender: UIButton) {
        if minY == 0 {
            minY = kScreenHeight - 84
            backView.alpha = 0.0
            navHeightMargin.constant = 44
            imageWidthMargin.constant = 34
            imageHeightMargin.constant = 34
            imageTopMargin.constant = 5
            configureView()
        }
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        if minY == kScreenHeight - 84 {
            minY = 0
            backView.alpha = 0.3
            navHeightMargin.constant = 64
            imageWidthMargin.constant = kScreenWidth - 40
            imageHeightMargin.constant = kScreenHeight - 80
            imageTopMargin.constant = 0
            imageLedingMargin.constant = 0
            configureView()
        }
    }

}

// MARK: - PlayerAction

extension MusicPlayerView {
    private func creatAudioPlayer() {
        musicTitleLab.text = model.name
        let picDict = model.picArray[0] as! NSDictionary
        let picUrl = picDict["picUrl"] as! String
        musicImageView.sd_setImageWithURL(NSURL(string: picUrl)!)
        let playerItem = AVPlayerItem(URL: NSURL(string: model.songUrl)!)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        player.play()
        playStatus = true
    }
    
    @IBAction private func playerBtnAction(sender: UIButton) {
        sender.selected = playStatus
        if playStatus {
            player.pause()
            playStatus = false
        } else {
            player.play()
            playStatus = true
        }
    }
    
    @IBAction private func lastBtnAction(sender: UIButton) {
        currentIndex -= 1
        if currentIndex == -1 {
            currentIndex = songIdArray.count - 1
        }
        getMusic()
    }
    
    @IBAction private func nextBtnAction(sender: UIButton) {
        currentIndex += 1
        if currentIndex == songIdArray.count {
            currentIndex = 0
        }
        getMusic()
    }
}

// MARK: - Public

extension MusicPlayerView {
    
    func loadMusicWith(idArray: NSArray, index: NSInteger) {
        songIdArray = idArray
        currentIndex = index
        getMusic()
    }
    
}

// MARK: - Request

extension MusicPlayerView {
    
    private func getMusic() {
        HttpHelper.shareHelper.loadData(withView: self, url: "http://api.dongting.com/song/song/\(songIdArray[currentIndex])", parameters: nil) { (response) in
            self.model = SingleMusicModel()
            let dict = response!["data"] as! NSDictionary
            self.model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
            self.getPicture(self.model.songId, singerId: self.model.singerId)
        }
    }
    
    private func getPicture(songId: NSNumber, singerId: NSNumber) {
        HttpHelper.shareHelper.loadData(withView: self, url: "http://so.ard.iyyin.com/s/pic", parameters: ["song_id":"\(songId)", "singerid":"\(singerId)"]) { (response) in
            let data = response!["data"] as! NSArray
            guard data.count != 0 else {
                return
            }
            let dataDict = data[0]
            if dataDict["picUrls"] is NSArray {
                self.model.picArray = dataDict["picUrls"] as! NSArray
                self.creatAudioPlayer()
            }
        }
    }
    
}

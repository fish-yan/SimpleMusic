//
//  MusicPlayerView.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/6.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit
import MediaPlayer

import AVFoundation

class MusicPlayerView: UIView {
    static let sharePlayer = MusicPlayerView(frame: CGRect(x: 20, y: kScreenHeight - 44, width: kScreenWidth - 40, height: kScreenHeight - 88))
    var player = AVPlayer()
    
    @IBOutlet weak var collectBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var forgroundView: UIView!
    @IBOutlet weak var endTimeLab: UILabel!
    @IBOutlet weak var beginTimeLab: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var topPlayerBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var musicTitleLab: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var navHeightMargin: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageLeading: NSLayoutConstraint!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    var senderVC: RootViewController!
    var model = SingleMusicModel()
    var songIdArray = NSArray()
    var currentSongId: String = ""
    var currentIndex = 0
    var currentImage: UIImage!
    var isAdd = true
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
        
        slider.setThumbImage(UIImage(named: "slider"), forState: .Normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAtion(_:)))
        addGestureRecognizer(pan)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(nextBtnAction(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        remoteMusic()
    }
    
    @IBAction private func backBtnAction(sender: UIButton) {
        hiddenMusicPlayerView()
        
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        showMusicPlayerView()
    }
    
    var isDown = false
    @objc private func panGestureAtion(sender: UIPanGestureRecognizer) {
        let translateY = sender.translationInView(self).y
        var y = CGRectGetMinY(frame)
        y = y < 44 ? 44 : y
        y = y > kScreenHeight - 44 ? kScreenHeight - 44 : y
        switch sender.state {
        case .Changed:
            frame = CGRect(x: 20, y: y + translateY, width: kScreenWidth - 40, height: kScreenHeight - 88)
            backView.alpha = (kScreenHeight - 44 - y) / (kScreenHeight - 44)
            if translateY > 0 {
                isDown = true
            } else{
                isDown = false
            }
        case .Ended, .Cancelled:
            if isDown && y > 150 || !isDown && y > kScreenHeight - 44 - 150 {
                
                hiddenMusicPlayerView()
            } else {
                showMusicPlayerView()
            }
        default: break
        }
        sender.setTranslation(CGPointZero, inView: self)
    }
    
    private func showMusicPlayerView() {
        
        navHeightMargin.constant = 64
        imageTop.constant = 0
        imageWidth.constant = kScreenWidth - 40
        imageHeight.constant = kScreenHeight - 80
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .AllowUserInteraction, animations: {
            self.musicTitleLab.textAlignment = .Center
            self.backView.alpha = 1
            self.backBtn.alpha = 1
            self.topPlayerBtn.alpha = 0
            self.frame = CGRect(x: 20, y: 44, width: kScreenWidth - 40, height: kScreenHeight - 88)
            self.layoutIfNeeded()
        }) { (finish) in
        }
    }
    
    private func hiddenMusicPlayerView() {
        navHeightMargin.constant = 44
        imageTop.constant = 5
        imageWidth.constant = 34
        imageHeight.constant = 34
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .AllowUserInteraction, animations: {
            self.musicTitleLab.textAlignment = .Left
            self.backView.alpha = 0
            self.backBtn.alpha = 0
            self.topPlayerBtn.alpha = 1
            self.frame = CGRect(x: 20, y: kScreenHeight - 44, width: kScreenWidth - 40, height: kScreenHeight - 88)
            self.layoutIfNeeded()
        }) { (finish) in
            
        }
    }
    /*
    func fullScreen() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 1)
        senderVC.navigationController!.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let inImage = UIGraphicsGetImageFromCurrentImageContext()
        return inImage
    }
    
    private func creatBlurImage(inImage: UIImage) -> UIImage {
        let inputImage = CIImage(CGImage: inImage.CGImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(float: 1.5), forKey: "inputRadius")
        let context = CIContext(options: nil)
        let outputImage = filter?.outputImage
        let refImage = context.createCGImage(outputImage!, fromRect: UIScreen.mainScreen().bounds)
        let outImage = UIImage(CGImage: refImage)
        return outImage
    }
    */
}

extension MusicPlayerView {
    
    private func configurePlayerStatus() {
        musicTitleLab.text = model.name
        musicImageView.sd_setImageWithURL(NSURL(string: model.picUrl!)!, completed: { (image, error, type, url) in
            if image != nil {
                self.currentImage = image
                self.updateNowPlayerInfoCenter()
            }
        })
        
        
        player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue()) { (time) in
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(self.player.currentItem!.duration)
            self.beginTimeLab.text = "\(Int(currentTime / 60)):\(Int(currentTime % 60))"
            if totalTime > 0.0 {
                self.endTimeLab.text = "\(Int(totalTime / 60)):\(Int(totalTime % 60))"
            }
            let value = currentTime/totalTime as Float64
            self.slider.value = Float(value)
        }
    }
    
    func updateNowPlayerInfoCenter() {
        var info = [String : AnyObject]()
        info[MPMediaItemPropertyTitle] = model.name
        info[MPMediaItemPropertyArtist] = model.singerName
        info[MPMediaItemPropertyAlbumTitle] = model.albumName
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: currentImage)
        info[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(float: player.rate)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(double: CMTimeGetSeconds(player.currentItem!.currentTime()))
        info[MPMediaItemPropertyPlaybackDuration] = NSNumber(double: CMTimeGetSeconds(player.currentItem!.duration))
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            switch player.status {
            case .Unknown:
               print("unknow")
            case .ReadyToPlay:
                configurePlayerStatus()
            case .Failed:
                print("failed")
            }
        }
    }
    
    func remoteMusic() {
        let remote = MPRemoteCommandCenter.sharedCommandCenter()
        remote.pauseCommand.addTarget(self, action: #selector(playerBtnAction(_:)))
        remote.playCommand.addTarget(self, action: #selector(playerBtnAction(_:)))
        remote.previousTrackCommand.addTarget(self, action: #selector(lastBtnAction(_:)))
        remote.nextTrackCommand.addTarget(self, action: #selector(nextBtnAction(_:)))
    }
    
}

// MARK: - PlayerAction

extension MusicPlayerView {
    private func creatAudioPlayer() {
        if currentSongId == "\(model.songId)"{
            playerBtnAction(UIButton())
            return
        }
        currentSongId = "\(model.songId)"
        if player.currentItem != nil {
            player.currentItem?.removeObserver(self, forKeyPath: "status")
            player.replaceCurrentItemWithPlayerItem(nil)
        }
        let temp = SimpleMusicModel.getModelWith(model.songId!)
        if temp as! NSObject == false {
            let playerItem = AVPlayerItem(URL: NSURL(string: model.songUrl!)!)
            player.replaceCurrentItemWithPlayerItem(playerItem)
            
        } else {
            let simpleModel = temp as! SimpleMusicModel
            let asset = AVAsset(URL: NSURL(fileURLWithPath: simpleModel.filePath!))
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItemWithPlayerItem(playerItem)
        }
        player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        player.play()
        playStatus = true
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
    }
    
    @objc @IBAction private func playerBtnAction(sender: UIButton) {
        if playStatus {
            player.pause()
            playStatus = false
        } else {
            player.play()
            playStatus = true
        }
        
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
        updateNowPlayerInfoCenter()
    }
    
    @objc @IBAction private func lastBtnAction(sender: UIButton) {
        isAdd = false
        currentIndex -= 1
        if currentIndex == -1 {
            currentIndex = songIdArray.count - 1
        }
        getMusic()
    }
    
    @objc @IBAction func nextBtnAction(sender: UIButton) {
        isAdd = true
        currentIndex += 1
        if currentIndex == songIdArray.count {
            currentIndex = 0
        }
        getMusic()
    }
    
    @IBAction func sliderAction(sender: UISlider) {
        let changeTime = Float64(sender.value) * CMTimeGetSeconds((player.currentItem?.duration)!)
        player.pause()
        if player.currentItem?.status == AVPlayerItemStatus.ReadyToPlay {
            player.seekToTime(CMTimeMake(Int64(changeTime), 1), completionHandler: { (success) in
                self.player.play()
            })
        }
        updateNowPlayerInfoCenter()
    }
    
    @IBAction func downBtnAction(sender: UIButton) {
        HttpHelper.shareHelper.downloadMusic(withUrl: model.songUrl!, progress: { (progress) in
            
            }) { (filePath) in
                self.model.downType = 2
                self.model.filePath = "\(filePath)"
                SimpleMusicModel.insertWith(self.model)
        }
    }
    
    @IBAction func collecBtnAction(sender: UIButton) {
        self.model.downType = 1
        SimpleMusicModel.insertWith(self.model)
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
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(["idArray":songIdArray, "index":currentIndex], forKey: "currentSong")
        HttpHelper.shareHelper.loadData(withView: self, url: "http://api.dongting.com/song/song/\(songIdArray[currentIndex])", parameters: nil) { (response) in
            self.model = SingleMusicModel()
            let dict = response!["data"] as! NSDictionary
            self.model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
            if self.model.songUrl == nil {
                if self.isAdd {
                    self.nextBtnAction(UIButton())
                } else {
                    self.lastBtnAction(UIButton())
                }
            }
            self.getPicture(self.model.songId!, singerId: self.model.singerId!)
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
                let picArray = dataDict["picUrls"] as! NSArray
                if picArray.count != 0 {
                    let picDict =  picArray[0] as! NSDictionary
                    self.model.picUrl = picDict["picUrl"] as? String
                }
                
            }
            self.creatAudioPlayer()
        }
    }
    
    
}


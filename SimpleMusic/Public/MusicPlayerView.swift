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
    var playerItem: AVPlayerItem!
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
    var modelArray = NSArray()
    var isFromDownload = false
    var currentSongId: String = ""
    var currentIndex = 0
    var currentImage: UIImage!
    var isAdd = true
    var dowmloadType = NSNumber(integer: 0)
    var currentCacheTime: Float64 = 0
    var currentPlayTime: Float64 = 0
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(routeChange(_:)), name: AVAudioSessionRouteChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self , selector: #selector(interruptionAction(_:)), name: AVAudioSessionInterruptionNotification, object: nil)
        
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
        if dowmloadType == 0 {
            collectBtn.setImage(UIImage(named: "unselect"), forState: .Normal)
            downloadBtn.setImage(UIImage(named: "unDownload"), forState: .Normal)
            collectBtn.userInteractionEnabled = true
            downloadBtn.userInteractionEnabled = true
        } else if dowmloadType == 1 {
            collectBtn.userInteractionEnabled = true
            downloadBtn.userInteractionEnabled = true
            collectBtn.setImage(UIImage(named: "selected"), forState: .Normal)
            downloadBtn.setImage(UIImage(named: "unDownload"), forState: .Normal)
        } else {
            collectBtn.userInteractionEnabled = false
            downloadBtn.userInteractionEnabled = false
            collectBtn.setImage(UIImage(named: "unselect"), forState: .Normal)
            downloadBtn.setImage(UIImage(named: "download"), forState: .Normal)
        }
        
        player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue()) { (time) in
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(self.playerItem!.duration)
            self.beginTimeLab.text = "\(Int(currentTime / 60)):\(Int(currentTime % 60))"
            if totalTime > 0.0 {
                self.endTimeLab.text = "\(Int(totalTime / 60)):\(Int(totalTime % 60))"
            }
            let value = currentTime/totalTime as Float64
            self.slider.value = Float(value)
            print(self.player.rate)
            self.currentPlayTime = currentTime
            if self.currentPlayTime > self.currentCacheTime - 1 {
                MBProgressHUD .showHUDAddedTo(self, animated: true)
            }
        }
    }
    
    func updateNowPlayerInfoCenter() {
        var info = [String : AnyObject]()
        info[MPMediaItemPropertyTitle] = model.name
        info[MPMediaItemPropertyArtist] = model.singerName
        info[MPMediaItemPropertyAlbumTitle] = model.albumName
        if currentImage != nil {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: currentImage)
        }
        info[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(float: player.rate)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(double: CMTimeGetSeconds(playerItem!.currentTime()))
        info[MPMediaItemPropertyPlaybackDuration] = NSNumber(double: CMTimeGetSeconds(playerItem!.duration))
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
        if keyPath == "loadedTimeRanges" {
            let array = playerItem?.loadedTimeRanges
            let timeRange = array?.first?.CMTimeRangeValue
            let totalBuffer = CMTimeGetSeconds(timeRange!.start) + CMTimeGetSeconds(timeRange!.duration)
            currentCacheTime = totalBuffer
            if playStatus && currentCacheTime >= currentPlayTime + 5 {
                MBProgressHUD.hideHUDForView(self, animated: true)
                if player.rate == 0  {
                    play()
                }
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
        if playerItem != nil {
            playerItem.removeObserver(self, forKeyPath: "status")
            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            player.replaceCurrentItemWithPlayerItem(nil)
        }
        let temp = SimpleMusicModel.getModelWith(model.songId!)
        if temp as! NSObject == false {
            playerItem = AVPlayerItem(URL: NSURL(string: model.songUrl!)!)
            player.replaceCurrentItemWithPlayerItem(playerItem)
            dowmloadType = 0
        } else {
            
            let simpleModel = temp as! SimpleMusicModel
            dowmloadType = simpleModel.downType!
            if dowmloadType == 1 {
                let playerItem = AVPlayerItem(URL: NSURL(string: model.songUrl!)!)
                player.replaceCurrentItemWithPlayerItem(playerItem)
            } else {
                let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
                let path1 = NSString(string: caches!)
                let path2 = path1.stringByAppendingPathComponent(simpleModel.filePath!)
                let asset = AVAsset(URL: NSURL(fileURLWithPath: path2))
                let playerItem = AVPlayerItem(asset: asset)
                player.replaceCurrentItemWithPlayerItem(playerItem)
            }
            
        }
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        playerItem.addObserver(self, forKeyPath:"loadedTimeRanges" ,options:NSKeyValueObservingOptions.New, context:nil)
        player.play()
        playStatus = true
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
    }
    
    @objc @IBAction private func playerBtnAction(sender: UIButton) {
        if playStatus {
            pause()
        } else {
            play()
        }
    }
    
    @objc @IBAction private func lastBtnAction(sender: UIButton) {
        isAdd = false
        currentIndex -= 1
        if currentIndex == -1 {
            currentIndex = songIdArray.count - 1
        }
        if isFromDownload {
            getMusicFromLoacal()
        } else {
            getMusic()
        }
    }
    
    @objc @IBAction func nextBtnAction(sender: UIButton) {
        isAdd = true
        currentIndex += 1
        if currentIndex == songIdArray.count {
            currentIndex = 0
        }
        if isFromDownload {
            getMusicFromLoacal()
        } else {
            getMusic()
        }
        
    }
    
    private func play() {
        player.play()
        playStatus = true
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
        updateNowPlayerInfoCenter()
    }
    
    @objc private func pause() {
        player.pause()
        playStatus = false
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
        updateNowPlayerInfoCenter()
    }
    
    @IBAction func sliderAction(sender: UISlider) {
        let changeTime = Float64(sender.value) * CMTimeGetSeconds((playerItem?.duration)!)
        player.pause()
        if playerItem.status == AVPlayerItemStatus.ReadyToPlay {
            player.seekToTime(CMTimeMake(Int64(changeTime), 1), completionHandler: { (success) in
                self.player.play()
            })
        }
        updateNowPlayerInfoCenter()
    }
    
    @IBAction func downBtnAction(sender: UIButton) {
        HttpHelper.shareHelper.downloadMusic(withUrl: model.songUrl!, progress: { (progress) in
            
            }) { (suggestName) in
                self.model.downType = 2
                self.model.filePath = suggestName
                SimpleMusicModel.insertWith(self.model)
                self.collectBtn.setImage(UIImage(named: "unselect"), forState: .Normal)
                self.downloadBtn.setImage(UIImage(named: "download"), forState: .Normal)
                NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
        }
    }
    
    @IBAction func collecBtnAction(sender: UIButton) {
        self.model.downType = 1
        SimpleMusicModel.insertWith(self.model)
        collectBtn.setImage(UIImage(named: "selected"), forState: .Normal)
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
    }
    
    @objc private func routeChange(sender: NSNotification) {
        guard let dict = sender.userInfo else {
            return
        }
        let change = dict[AVAudioSessionRouteChangeReasonKey] as? AVAudioSessionRouteChangeReason
        if  change == .OldDeviceUnavailable {
            let routeDescription = dict[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
            let portDes = routeDescription?.outputs.first
            if portDes?.portType == "Headphones" {
                pause()
            }
            
        }
    }
    
    @objc private func interruptionAction(sender: NSNotification){
        guard let dict = sender.userInfo else {
            return
        }
        let type = dict[AVAudioSessionInterruptionTypeKey] as? AVAudioSessionInterruptionType
        if type == .Began {
            pause()
        } else {
            play()
        }
    }
    
}

// MARK: - Public

extension MusicPlayerView {
    
    func loadMusicWith(idArray: NSArray, index: NSInteger) {
        isFromDownload = false
        songIdArray = idArray
        currentIndex = index
        getMusic()
    }
    
    func loadLocalMusicWidth(mArray: NSArray, index: NSInteger) {
        isFromDownload = true
        modelArray = mArray
        currentIndex = index
        getMusicFromLoacal()
    }
}

// MARK: - Request

extension MusicPlayerView {
    
    func getMusicFromLoacal() {
        let smodel = modelArray[currentIndex] as! SimpleMusicModel
        model.albumName = smodel.albumName
        model.name = smodel.name
        model.picUrl = smodel.picUrl
        model.singerId = smodel.singerId
        model.singerName = smodel.singerName
        model.songId = smodel.songId
        model.songUrl = smodel.songUrl
        creatAudioPlayer()
    }
    
    private func getMusic() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(["idArray":songIdArray, "index":currentIndex], forKey: "currentSong")
        HttpHelper.shareHelper.loadData(withView: nil, url: "http://api.dongting.com/song/song/\(songIdArray[currentIndex])", parameters: nil) { (response) in
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
        HttpHelper.shareHelper.loadData(withView: nil, url: "http://so.ard.iyyin.com/s/pic", parameters: ["song_id":"\(songId)", "singerid":"\(singerId)"]) { (response) in
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


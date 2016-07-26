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
    
    @IBOutlet weak var forgroundView: UIView!
    @IBOutlet weak var backImage: UIImageView!
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
    var currentSongId: NSNumber!
    var currentIndex = 0
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
    }
    
    @IBAction private func backBtnAction(sender: UIButton) {
        hiddenMusicPlayerView()
        
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        showMusicPlayerView()
    }
    
    @objc private func panGestureAtion(sender: UIPanGestureRecognizer) {
        var transform = CATransform3DIdentity
        let translateY = sender.translationInView(self).y
        
        let changeY = translateY > 0 ? -kScreenHeight + 84 + translateY : translateY
        switch sender.state {
        case .Changed:
            transform = CATransform3DTranslate(transform, 0, changeY, 0)
            self.layer.transform = transform
        case .Ended, .Cancelled:
            print(translateY)
            if (translateY < -150 || (translateY > 0 && translateY < 150) ) {
                showMusicPlayerView()
            } else {
                hiddenMusicPlayerView()
            }
            
        default: break
        }
        
    }
    
    
    private func showMusicPlayerView() {
        forgroundView.hidden = true
        let screenImage = fullScreen()
        forgroundView.hidden = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let image = self.creatBlurImage(screenImage)
            dispatch_async(dispatch_get_main_queue(), {
                self.backImage.image = image
            })
        })
        
        navHeightMargin.constant = 64
        imageTop.constant = 0
        imageWidth.constant = kScreenWidth - 40
        imageHeight.constant = kScreenHeight - 80
        backBtn.hidden = false
        topPlayerBtn.hidden = true
        musicTitleLab.textAlignment = .Center
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, -kScreenHeight + 84, 0)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .AllowUserInteraction, animations: {
            self.backView.alpha = 0.3
            self.layer.transform = transform
            self.layoutIfNeeded()
        }) { (finish) in
        }
    }
    
    private func hiddenMusicPlayerView() {
        self.backImage.image = nil
        navHeightMargin.constant = 44
        imageTop.constant = 5
        imageWidth.constant = 34
        imageHeight.constant = 34
        backBtn.hidden = true
        topPlayerBtn.hidden = false
        musicTitleLab.textAlignment = .Left
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .AllowUserInteraction, animations: {
            self.backView.alpha = 0
            self.layer.transform = CATransform3DIdentity
            self.layoutIfNeeded()
        }) { (finish) in
            
        }
    }
    
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
    
}


// MARK: - PlayerAction

extension MusicPlayerView {
    private func creatAudioPlayer() {
        if currentSongId == model.songId {
            playerBtnAction(UIButton())
            return
        }
        currentSongId = model.songId
        musicTitleLab.text = model.name
        if model.picArray.count != 0 {
            let picDict = model.picArray[0] as! NSDictionary
            let picUrl = picDict["picUrl"] as! String
            musicImageView.sd_setImageWithURL(NSURL(string: picUrl)!)
        }
        
        let playerItem = AVPlayerItem(URL: NSURL(string: model.songUrl)!)
        player.replaceCurrentItemWithPlayerItem(playerItem)
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
        player.play()
        playStatus = true
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
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
        
        playBtn.selected = playStatus
        topPlayerBtn.selected = playStatus
    }
    
    @IBAction private func lastBtnAction(sender: UIButton) {
        isAdd = false

        currentIndex -= 1
        if currentIndex == -1 {
            currentIndex = songIdArray.count - 1
        }
        getMusic()
    }
    
    @IBAction func nextBtnAction(sender: UIButton) {
        isAdd = true
        currentIndex += 1
        if currentIndex == songIdArray.count {
            currentIndex = 0
        }
        getMusic()
    }
    
    @IBAction func sliderAction(sender: UISlider) {
        let changeTime = Float64(sender.value) * CMTimeGetSeconds((player.currentItem?.duration)!)
        if player.currentItem?.status == AVPlayerItemStatus.ReadyToPlay {
            player.seekToTime(CMTimeMake(Int64(changeTime), 1), completionHandler: { (success) in
                self.player.play()
            })
        }
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
            if self.model.songUrl == nil {
                if self.isAdd {
                    self.nextBtnAction(UIButton())
                } else {
                    self.lastBtnAction(UIButton())
                }
            }
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


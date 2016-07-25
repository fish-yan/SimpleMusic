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
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backView: UIView!
    var model = SingleMusicModel()
    var minY:CGFloat = kScreenHeight - 84
    var songIdArray = NSArray()
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
        let tap = UITapGestureRecognizer(target: self
            , action: #selector(tapGestureAction(_:)))
        addGestureRecognizer(tap)
        configureView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(nextBtnAction(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
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
            navHeightMargin.constant = 44
            imageTop.constant = 5
            imageWidth.constant = 34
            imageHeight.constant = 34
            backView.alpha = 0
            configureView()
        }
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        if minY == kScreenHeight - 84 {
            minY = 0
            navHeightMargin.constant = 64
            imageTop.constant = 0
            imageWidth.constant = kScreenWidth - 40
            imageHeight.constant = kScreenHeight - 80
            backView.alpha = 0.5
            configureView()
        }
    }

    deinit {
        print("111")
    }
    
    private func getBlurImage(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let inputImage = CIImage(CGImage: image.CGImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(NSNumber(float: 0.5), forKey: "inputRadius")
        let outImage = filter!.outputImage
        let refImage = context.createCGImage(outImage!, fromRect: outImage!.extent)
        return UIImage(CGImage: refImage)
    }
    
}

// MARK: - PlayerAction

extension MusicPlayerView {
    private func creatAudioPlayer() {
        musicTitleLab.text = model.name
        if model.picArray.count != 0 {
            let picDict = model.picArray[0] as! NSDictionary
            let picUrl = picDict["picUrl"] as! String
            musicImageView.sd_setImageWithURL(NSURL(string: picUrl)!)
            backImage.sd_setImageWithURL(NSURL(string: picUrl)!)
        }
        
        let playerItem = AVPlayerItem(URL: NSURL(string: model.songUrl)!)
        print("000-----\(model.songUrl)")
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
        playerBtnAction(UIButton())
    }
    
    @IBAction private func playerBtnAction(sender: UIButton) {
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


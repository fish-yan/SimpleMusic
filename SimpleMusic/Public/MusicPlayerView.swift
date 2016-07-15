//
//  MusicPlayerView.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/6.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicPlayerView: UIView {


    @IBOutlet weak var endTimeLab: UILabel!
    @IBOutlet weak var beginTimeLab: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var topPlayerBtn: UIButton!
    @IBOutlet weak var musicTitleLab: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var navHeightMargin: NSLayoutConstraint!
    var minY:CGFloat = kScreenHeight - 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadNib() {
        let nib = UINib(nibName: "MusicPlayerView", bundle: nil)
        let playerView = nib.instantiateWithOwner(self, options: nil).last as! UIView
        playerView.frame = self.bounds
        addSubview(playerView)
        let tap = UITapGestureRecognizer(target: self
            , action: #selector(tapGestureAction(_:)))
        addGestureRecognizer(tap)
        configureView()
    }
    
    func configureView() {
        UIView.animateWithDuration(0.25) { 
            self.frame = CGRect(x: 0, y: self.minY, width: kScreenWidth, height: kScreenHeight)
            self.layoutIfNeeded()
        }
        if minY == kScreenHeight - 44 {
            backBtn.hidden = true
            topPlayerBtn.hidden = false
            musicTitleLab.textAlignment = .Left
        } else {
            backBtn.hidden = false
            topPlayerBtn.hidden = true
            musicTitleLab.textAlignment = .Center
        }
    }
    
    @IBAction func playerBtnAction(sender: UIButton) {
        
    }
    
    @IBAction func lastBtnAction(sender: UIButton) {
        
    }
    
    @IBAction func nextBtnAction(sender: UIButton) {
        
    }
    
    
    @IBAction func backBtnAction(sender: UIButton) {
        if minY == 0 {
            minY = kScreenHeight - 44
            navHeightMargin.constant = 44
            configureView()
        }
    }
    
    func tapGestureAction(sender: UITapGestureRecognizer) {
        if minY == kScreenHeight - 44 {
            minY = 0
            navHeightMargin.constant = 64
            configureView()
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

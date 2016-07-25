//
//  MusicSearchViewController.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var segmented: UISegmentedControl!
    var dataArray = NSMutableArray()
    var idArray = NSMutableArray()
    var songArray = NSMutableArray()
    var singerArray = NSMutableArray()
    var albumArray = NSMutableArray()
    var songListArray = NSMutableArray()
    var favArray = NSMutableArray()
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        changeBtn.layer.borderColor = HttpHelper.getColorWith(0xCC4546).CGColor
        changeBtn.layer.borderWidth = 1
        changeBtn.layer.cornerRadius = 3
        changeBtn.layer.masksToBounds = true
        searchTF.addTarget(self, action: #selector(textChange(_:)), forControlEvents: .EditingChanged)
        getFavouriteMusicList()
        // Do any additional setup after loading the view.
    }

    @IBAction func searchBtnAction(sender: UIButton) {
        if searchTF.text?.characters.count != 0 {
            showSegment()
        }
    }
    
    @IBAction func changeBtnAction(sender: UIButton) {
        getFavouriteMusicList()
    }
    
    func textChange(textField: UITextField) {
        if textField.text?.characters.count == 0 {
            hiddenSegment()
            tableView.contentOffset = CGPoint(x: 0, y: 0)
            if favArray.count == 0 {
                getFavouriteMusicList()
            } else {
                dataArray = NSMutableArray(array: favArray)
                tableView.reloadData()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSegment() {
        view.endEditing(true)
        segmented.selectedSegmentIndex = 0
        self.pageIndex = 1
        songListArray.removeAllObjects()
        songArray.removeAllObjects()
        singerArray.removeAllObjects()
        albumArray.removeAllObjects()
        segmentedAction(segmented)
        topMargin.constant = 0
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hiddenSegment() {
        topMargin.constant = -50
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        var type = ""
        tableView.contentOffset = CGPoint(x: 0, y: 0)
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.pageIndex = 1
            self.searchMusic(type)
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.pageIndex = self.dataArray.count / 20
            self.pageIndex += 1
            self.searchMusic(type)
        })
        
        switch sender.selectedSegmentIndex {
        case 0:
            type = "song"
            if songArray.count == 0 {
                tableView.mj_header.beginRefreshing()
            } else {
               dataArray = NSMutableArray(array: songArray)
            }
        case 1:
            type = "artist"
            if singerArray.count == 0 {
                tableView.mj_header.beginRefreshing()
            } else {
                dataArray = NSMutableArray(array: singerArray)
            }
        case 2:
            type = "songlist"
            if songListArray.count == 0 {
                tableView.mj_header.beginRefreshing()
            } else {
                dataArray = NSMutableArray(array: songListArray)
            }
        case 3:
            type = "album"
            if albumArray.count == 0 {
                tableView.mj_header.beginRefreshing()
            } else {
                dataArray = NSMutableArray(array: albumArray)
            }
        default: break
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC = segue.destinationViewController as! MusicListDetailViewController
        detailVC.model = sender as! MusicModel
    }
    

}

// MARK: - UITableViewDataSource

extension MusicSearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicSearchCell", forIndexPath: indexPath) as! MusicSearchCell
        let model = dataArray[indexPath.row] as! MusicModel
        switch model.searchType {
        case "song", "fav":
            cell.indexLab.hidden = false
            cell.picImage.hidden = true
            cell.indexLab.text = "\(indexPath.row + 1)"
            cell.titleLab.text = model.name
            let album = (model.albumName != nil) ? model.albumName : ""
            cell.singerNameLab.text = model.singerName + "  " + album
        case "artist":
            cell.indexLab.hidden = true
            cell.picImage.hidden = false
            cell.titleLab.text = model.singerName
            cell.picImage.sd_setImageWithURL(NSURL(string: model.picUrl))
            cell.singerNameLab.text = "\(model.song_num)首单曲  \(model.album_num)张专辑"
        case "songlist":
            cell.indexLab.hidden = true
            cell.picImage.hidden = false
            cell.titleLab.text = model.title
            cell.picImage.sd_setImageWithURL(NSURL(string: model.picUrl))
            cell.singerNameLab.text = "\(model.songs.count)首"
        case "album":
            cell.indexLab.hidden = true
            cell.picImage.hidden = false
            cell.titleLab.text = model.name
            cell.picImage.sd_setImageWithURL(NSURL(string: model.picUrl))
            cell.singerNameLab.text = model.singerName
        default: break
        }
        return cell;
    }
    
}

// MARK: - UITableViewDelegate

extension MusicSearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model = dataArray[indexPath.row] as! MusicModel
        switch model.searchType {
        case "fav", "song":
            MusicPlayerView.sharePlayer.loadMusicWith(idArray, index: indexPath.row)
        case "artist", "songlist", "album":
            performSegueWithIdentifier("detail", sender: model)
        default: break
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension MusicSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if searchTF.text?.characters.count != 0 {
            showSegment()
        }
        return true
    }
    
}

// MARK: - Request

extension MusicSearchViewController {
    
    func getFavouriteMusicList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.favorite.ttpod.com/favorite/song/plaza", parameters: ["random":"1"]) { (response) in
            self.favArray = NSMutableArray()
            self.idArray = NSMutableArray()
            let dataDict = response!["data"] as! NSDictionary
            let array = dataDict["songs"] as! NSArray
            for dict in array {
                let model = MusicModel()
                model.searchType = "fav"
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                if model.songUrl.characters.count != 0 {
                    self.favArray.addObject(model)
                    self.idArray.addObject(model.songId)
                }
            }
            self.dataArray = NSMutableArray(array: self.favArray)
        }
    }
    
    func searchMusic(type: String) {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://search.dongting.com/\(type)/search", parameters: ["size":"20", "page":"\(pageIndex)", "q": searchTF.text!]) { (response) in
            let array = response!["data"] as! NSArray
            switch type {
            case "song":
                if self.pageIndex == 1 {
                    self.songArray = NSMutableArray()
                }
            case "artist":
                if self.pageIndex == 1 {
                    self.singerArray = NSMutableArray()
                }
            case "songlist":
                if self.pageIndex == 1 {
                    self.songListArray = NSMutableArray()
                }
            case "album":
                if self.pageIndex == 1 {
                    self.albumArray = NSMutableArray()
                }
            default: break
            }

            self.dataArray = NSMutableArray()
            for dict in array {
                let model = MusicModel()
                model.searchType = type
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                switch type {
                case "song":
                    if  model.songUrl != nil {
                        self.songArray.addObject(model)
                        self.idArray.addObject(model.songId)
                    }
                case "artist":
                    self.singerArray.addObject(model)
                case "songlist":
                    self.songListArray.addObject(model)
                case "album":
                    self.albumArray.addObject(model)
                default: break
                }
            }
            switch type {
            case "song":
                self.dataArray = NSMutableArray(array: self.songArray)
            case "artist":
                self.dataArray = NSMutableArray(array: self.singerArray)
            case "songlist":
                self.dataArray = NSMutableArray(array: self.songListArray)
            case "album":
                self.dataArray = NSMutableArray(array: self.albumArray)
            default: break
            }
        }
    }
    
}


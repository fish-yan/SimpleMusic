//
//  MusicListDetailViewController.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/20.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicListDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataArray = NSMutableArray()
    var idArray = NSMutableArray()
    var model: MusicModel!
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        switch model.searchType {
        case "artist":
            tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
                self.pageIndex = 1
                self.getSingerSongsList()
            })
            tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
                self.pageIndex = self.dataArray.count / 20
                self.pageIndex += 1
                self.getSingerSongsList()
            })
            tableView.mj_header.beginRefreshing()
        case "songlist":
            getMusicListSongsList()
        case "album":
            getAlbumSongsList()
        default:
            break
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func backItemAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDataSource

extension MusicListDetailViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicSearchCell", forIndexPath: indexPath) as! MusicSearchCell
        let songModel = dataArray[indexPath.row] as! MusicModel
        cell.indexLab.text = "\(indexPath.row + 1)"
        cell.titleLab.text = songModel.name
        let album = (songModel.albumName != nil) ? songModel.albumName : ""
        cell.singerNameLab.text = songModel.singerName! + "  " + album!
        return cell;
    }
    
}

// MARK: - UITableViewDelegate

extension MusicListDetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(idArray)
    }
    
}

// MARK: - Request

extension MusicListDetailViewController {
    
    func getSingerSongsList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.dongting.com/song/singer/\(model.singerId)/songs", parameters: ["size":"20", "page":"\(pageIndex)"]) { (response) in
            let array = response!["data"] as! NSArray
            for dict in array {
                let model = MusicModel()
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                if  model.songUrl != nil {
                    self.dataArray.addObject(model)
                    self.idArray.addObject(model.songId!)
                }
            }
        }
    }
    
    func getAlbumSongsList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.dongting.com/song/album/\(model.albumId)", parameters: ["size":"20", "page":"\(pageIndex)"]) { (response) in
            let dict = response!["data"] as! NSDictionary
            let array = dict["songList"] as! NSArray
            for dict in array {
                let model = MusicModel()
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                if  model.songUrl != nil {
                    self.dataArray.addObject(model)
                    self.idArray.addObject(model.songId!)
                }
                
            }
        }
    }
    
    func getMusicListSongsList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.songlist.ttpod.com/songlists/\(model.songListId)", parameters: ["size":"20", "page":"\(pageIndex)"]) { (response) in
            let array = response!["songs"] as! NSArray
            for dict in array {
                let model = MusicModel()
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                if model.songUrl != nil {
                    self.dataArray.addObject(model)
                    self.idArray.addObject(model.songId!)
                }
            }
        }
    }
    
}

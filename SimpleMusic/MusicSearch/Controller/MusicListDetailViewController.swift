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
    var model: MusicModel!
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        switch model.searchType {
        case "artist":
            getSingerSongsList()
        case "songlist":
            getMusicListSongsList()
        case "album":
            getAlbumSongsList()
        default:
            break
        }
        // Do any additional setup after loading the view.
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
        cell.indexLab.text = "\(indexPath.row + 1)"
        
        return cell;
    }
    
}

// MARK: - UITableViewDelegate

extension MusicListDetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}

// MARK: - Request

extension MusicListDetailViewController {
    
    func getSingerSongsList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.dongting.com/song/singer/\(model.singerId)/songs", parameters: ["size":"20", "page":"\(pageIndex)"]) { (response) in
            
        }
    }
    
    func getAlbumSongsList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.dongting.com/song/album/", parameters: ["size":"20", "page":"\(pageIndex)"]) { (response) in
            
        }
    }
    func getMusicListSongsList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.songlist.ttpod.com/songlists/", parameters: ["size":"20", "page":"\(pageIndex)"]) { (response) in
            
        }
    }
    
}

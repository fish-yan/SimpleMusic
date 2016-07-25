//
//  MusicListViewController.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataArray = NSMutableArray()
    var pageIndex: NSInteger = 1
    var type = "全部"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            self.pageIndex = 1
            self.getMusicList()
        })
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.pageIndex += 1
            self.getMusicList()
        })
        collectionView.mj_header.beginRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "type" {
            let presentVC = segue.destinationViewController as! MusicTypeViewController
            presentVC.passType = {(passType) in
                self.type = passType!
                self.collectionView.mj_header.beginRefreshing()
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension MusicListViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MusicListCell", forIndexPath: indexPath) as! MusicListCell
        let model = dataArray[indexPath.row] as! MusicModel
        cell.musicImageView.sd_setImageWithURL(NSURL(string: model.picUrl))
        cell.musicTitleLab.text = model.title
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MusicListReusableView", forIndexPath: indexPath) as! MusicListReusableView
        reusableView.typeBtn.setTitle(type, forState: .Normal)
        return reusableView
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MusicListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (kScreenWidth - 60) / 2, height: (kScreenWidth - 60) / 2 + 30)
    }
    
}

// MARK: - UICollectionViewDelegate

extension MusicListViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let model = dataArray[indexPath.row] as! MusicModel
        MusicPlayerView.sharePlayer.loadMusicWith(model.songs, index: 0)
    }
    
}

// MARK: - Request

extension MusicListViewController {
    func getMusicList() {
        let url = "http://search.dongting.com/songlist/search"
        var str = ""
        if type == "全部" {
            str = ""
        }else{
            str = "|" + type
        }
        let parameters = ["size":"10", "page":"\(pageIndex)", "q":"tag:最热\(str)"]
        HttpHelper.shareHelper.loadData(withView: collectionView, url: url, parameters: parameters) { (response) in
            let data = response!["data"] as! NSArray
            if self.pageIndex == 1 {
                self.dataArray = NSMutableArray()
            }
            for dict in data {
                let model = MusicModel()
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                self.dataArray.addObject(model)
            }
        }
    }
}

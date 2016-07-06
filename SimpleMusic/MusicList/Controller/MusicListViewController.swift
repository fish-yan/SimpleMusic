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

    @IBAction func musicTypeBtnAction(sender: UIButton) {
        
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
        let model = dataArray[indexPath.row] as? MusicListModel
        cell.musicImageView.sd_setImageWithURL(NSURL(string: (model?.pic_url)!))
        cell.musicTitleLab.text = model?.title
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MusicListReusableView", forIndexPath: indexPath) as! MusicListReusableView
        
        return reusableView
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MusicListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (kScreenWidth - 30) / 2, height: (kScreenWidth - 30) / 2 + 30)
    }
    
}

// MARK: - UICollectionViewDelegate

extension MusicListViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

// MARK: - Request

extension MusicListViewController {
    func getMusicList() {
        let url = "http://search.dongting.com/songlist/search?q=tag:%E6%9C%80%E7%83%AD"
        let str = "最热"
        str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let parameters = ["size":"10", "page":"\(pageIndex)"]
        HttpHelper.shareHelper.loadData(withView: collectionView, url: url, parameters: parameters) { (response) in
            let data = response!["data"] as! NSArray
            for dict in data {
                let model = MusicListModel()
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                self.dataArray.addObject(model)
            }
        }
    }
}

//
//  MusicTypeViewController.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/11.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicTypeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var passType: ((String?) -> Void)!
    var dataArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        getMusicType()
        // Do any additional setup after loading the view.
    }

    @IBAction func backBtnAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
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

// MARK: - UICollectionViewDelegateFlowLayout

extension MusicTypeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: kScreenWidth - 20, height: 40)
        }
        return CGSize(width: (kScreenWidth - 50) / 3, height: 40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: kScreenWidth / 3, height: 50)
    }
    
}

// MARK: - UICollectionViewDataSource

extension MusicTypeViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dict = dataArray[section] as! NSDictionary
        let array = dict["children"] as! NSArray
        return array.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MusicTypeCell", forIndexPath: indexPath) as! MusicTypeCell
        let dict = dataArray[indexPath.section] as! NSDictionary
        let array = dict["children"] as! NSArray
        let childrenDict = array[indexPath.row] as! NSDictionary
        cell.typeTitleLab.text = childrenDict["tag"] as? String
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MusicTypeReusableView", forIndexPath: indexPath) as! MusicTypeReusableView
        let dict = dataArray[indexPath.section] as! NSDictionary
        reusableView.reusableTitleLab.text = dict["tag"] as? String
        return reusableView
    }
    
}

// MARK: - UICollectionViewDelegate

extension MusicTypeViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dict = dataArray[indexPath.section] as! NSDictionary
        let array = dict["children"] as! NSArray
        let childrenDict = array[indexPath.row] as! NSDictionary
        passType(childrenDict["tag"] as? String)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - Request

extension MusicTypeViewController {
    
    func getMusicType() {
        let url = "http://api.dongting.com/song/tag/songlist"
        HttpHelper.shareHelper.loadData(withView: collectionView, url: url, parameters: nil) { (response) in
            let array = response!["data"] as! NSArray
            self.dataArray = NSMutableArray(array: array)
            let dict = ["tag":"","children":[["tag":"全部"]]];
            self.dataArray.insertObject(dict, atIndex: 0)
        }
    }
    
}

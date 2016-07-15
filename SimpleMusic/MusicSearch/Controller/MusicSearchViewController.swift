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
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        changeBtn.layer.borderWidth = 1
        
        getFavouriteMusicList()
        // Do any additional setup after loading the view.
    }

    @IBAction func searchBtnAction(sender: UIButton) {
    }
    
    @IBAction func changeBtnAction(sender: UIButton) {
        getFavouriteMusicList()
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

extension MusicSearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicSearchCell", forIndexPath: indexPath) as! MusicSearchCell
        let model = dataArray[indexPath.row] as! MusicFavModel
        cell.indexLab.text = "\(indexPath.row + 1)"
        cell.titleLab.text = model.name
        cell.singerNameLab.text = model.singerName
        return cell;
    }
    
}

// MARK: - UITableViewDelegate

extension MusicSearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension MusicSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    
}

// MARK: - Request

extension MusicSearchViewController {
    func getFavouriteMusicList() {
        HttpHelper.shareHelper.loadData(withView: tableView, url: "http://api.favorite.ttpod.com/favorite/song/plaza", parameters: ["random":"1"]) { (response) in
            let dataDict = response!["data"] as! NSDictionary
            let array = dataDict["songs"] as! NSArray
            for dict in array {
                let model = MusicFavModel()
                model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
                self.dataArray.addObject(model)
            }
        }
    }
}


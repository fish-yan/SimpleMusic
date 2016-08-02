//
//  MineViewController.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MineViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    var allDataArray = NSArray()
    var dataArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getData), name: "refresh", object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    func getData() {
        self.dataArray = NSMutableArray()
        SimpleMusicModel.getAllDataWith { (array) in
            self.allDataArray = array
            for element in self.allDataArray {
                let model = element as! SimpleMusicModel
                if model.downType == 2 {
                    self.dataArray.addObject(model)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func segmentAction(sender: UISegmentedControl) {
        dataArray = NSMutableArray()
        for element in allDataArray {
            let model = element as! SimpleMusicModel
            if model.downType == 1 && sender.selectedSegmentIndex == 1 {
                dataArray.addObject(model)
            } else if model.downType == 2 && sender.selectedSegmentIndex == 0 {
                dataArray.addObject(model)
            }
        }
        tableView.reloadData()
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

extension MineViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicSearchCell", forIndexPath: indexPath) as! MusicSearchCell
        let songModel = dataArray[indexPath.row] as! SimpleMusicModel
        cell.indexLab.text = "\(indexPath.row + 1)"
        cell.titleLab.text = songModel.name
        let album = (songModel.albumName != nil) ? songModel.albumName : ""
        cell.singerNameLab.text = songModel.singerName! + "  " + album!
        return cell;
    }
    
}

// MARK: - UITableViewDelegate

extension MineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let idArray = NSMutableArray()
        for element in dataArray {
            let model = element as! SimpleMusicModel
            idArray.addObject(model.songId!)
        }
        MusicPlayerView.sharePlayer.loadLocalMusicWidth(dataArray, index: indexPath.row)
    }
    
}

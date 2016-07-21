//
//  RootViewController.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

var playStatus = false

let kScreenWidth = UIScreen.mainScreen().bounds.width
let kScreenHeight = UIScreen.mainScreen().bounds.height

class RootViewController: UIViewController {

    @IBOutlet weak var lineLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.view.addSubview(MusicPlayerView.sharePlayer)
        print(MusicPlayerView.sharePlayer)
        // Do any additional setup after loading the view.
    }

    @IBAction func selectBtnAction(sender: UIButton) {
        lineLeftMargin.constant = CGFloat(sender.tag) * 70
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPoint(x: CGFloat(sender.tag) * kScreenWidth, y: 0)
            self.navigationController?.view.layoutIfNeeded()
        }
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

// MARK: - UIScrollViewDelegate

extension RootViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        lineLeftMargin.constant = scrollView.contentOffset.x / (kScreenWidth * 3) * 210
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension RootViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count == 1 {
            return false
        }
        return true
    }
}

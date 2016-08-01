//
//  HttpHelper.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit
import CoreData

class HttpHelper: NSObject {
    static let shareHelper = HttpHelper()
    var manager = AFHTTPSessionManager()
    override init() {
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/plain", "text/html") as? Set<String>
    }
    
    func loadData(withView view: UIView?, url: String, parameters: AnyObject?, success: ((response: AnyObject?) -> Void)) {
        let task = manager.GET(url, parameters: parameters, progress: nil, success: { (dataTask, response) in
            print("\(url) \n \(response)")
//            let code = response!["code"] as! NSNumber
//            if code.boolValue {
                success(response: response!)
                if view is UITableView {
                    let tableView = view as! UITableView
                    tableView.reloadData()
                    if (tableView.mj_header != nil) {
                        tableView.mj_header.endRefreshing()
                        tableView.mj_footer.endRefreshing()
                    }
                }
                if (view is UICollectionView) {
                    let collectionView = view as! UICollectionView
                    collectionView.reloadData()
                    if (collectionView.mj_header != nil) {
                        collectionView.mj_header.endRefreshing()
                        collectionView.mj_footer.endRefreshing()
                    }
                }
//            }
        }) { (dataTask, error) in
            print(error.description)
        }
        task?.resume()
    }
    
    func downloadMusic(withUrl urlStr: String, progress: ((NSProgress) -> Void), success:((NSURL?) -> Void)) {
        let request = NSURLRequest(URL: NSURL(string: urlStr)!)
        let task = manager.downloadTaskWithRequest(request, progress: { (AFNProgress) in
            progress(AFNProgress)
            }, destination: { (url, response) -> NSURL in
                let documentURL = try? NSFileManager.defaultManager().URLForDirectory(.DocumentationDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
                return (documentURL?.URLByAppendingPathComponent(response.suggestedFilename!))!
        }) { (response, filePath, error) in
            print(filePath)
            success(filePath)
        }
        task.resume()
    }
    
    class func getColorWith(rgbValue:Int) -> UIColor {
        let color = UIColor(red: (CGFloat((rgbValue & 0xFF0000) >> 16))/255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8))/255.0, blue: (CGFloat(rgbValue & 0xFF))/255.0, alpha: 1)
        return color
    }
    
}


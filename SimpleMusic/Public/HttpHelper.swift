//
//  HttpHelper.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/5.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

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
    
    class func getColorWith(rgbValue:Int) -> UIColor {
        let color = UIColor(red: (CGFloat((rgbValue & 0xFF0000) >> 16))/255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8))/255.0, blue: (CGFloat(rgbValue & 0xFF))/255.0, alpha: 1)
        return color
    }
    
}

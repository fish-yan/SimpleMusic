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
    
    func loadData(withView view: UIView, url: String, parameters: AnyObject?, success: ((response: AnyObject?) -> Void)) {
        let task = manager.GET(url, parameters: parameters, progress: nil, success: { (dataTask, response) in
            print("\(url) \n \(response)")
            let code = response!["code"] as! NSNumber
            if code.boolValue {
                success(response: response!)
                if view is UITableView {
                    let tableView = view as! UITableView
                    tableView.reloadData()
                }
                if (view is UICollectionView) {
                    let collectionView = view as! UICollectionView
                    collectionView.reloadData()
                    collectionView.mj_header.endRefreshing()
                    collectionView.mj_footer.endRefreshing()
                }
                print(view is UICollectionView)
            }
        }) { (dataTask, error) in
            print(error.description)
        }
        task?.resume()
    }
    
}

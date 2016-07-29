//
//  BaseModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/29.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit
import CoreData

class BaseModel: NSManagedObject {
    static let shareModel = BaseModel()
    // 插入
    func insertWith(dict: NSDictionary) {
        let name = NSStringFromClass(self.classForCoder)
        var temp = getModelWith(dict["songId"] as! NSNumber)
        if temp as! NSObject == false {
            temp = NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: AppDelegate.shareDelegate.managedObjectContext)
        }
        let model = temp as! BaseModel
        model.setValuesForKeysWithDictionary(dict as! [String : AnyObject])
        AppDelegate.shareDelegate.saveContext()
    }
    
    // 查询
    func getAllDataWith(songId:String, passData: (NSArray) -> Void) {
        let name = NSStringFromClass(self.classForCoder)
        let backgroundContext = AppDelegate.shareDelegate.backgroundOnjectContext
        backgroundContext.performBlock { 
            let request = NSFetchRequest()
            let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: backgroundContext)
            request.entity = entity
            do {
                let resultArray = try backgroundContext.executeFetchRequest(request)
                let idArray = NSMutableArray()
                for ob in resultArray {
                    let object = ob as! NSManagedObject
                    idArray.addObject(object.objectID)
                }
                AppDelegate.shareDelegate.managedObjectContext.performBlock({ 
                    let finalArray = NSMutableArray()
                    for obId in idArray {
                        finalArray.addObject(AppDelegate.shareDelegate.managedObjectContext.objectWithID(obId as! NSManagedObjectID))
                    }
                    passData(finalArray)
                })
            } catch {
                print("query error")
            }
        }
    }
    // 删除
    func removeWith(songId: NSNumber) {
        let model = getModelWith(songId)
        if model as! NSObject != false {
            AppDelegate.shareDelegate.managedObjectContext.deleteObject(model as! BaseModel)
        }
    }
    
    func getModelWith(songId: NSNumber) -> AnyObject {
        let name = NSStringFromClass(self.classForCoder)
        let context = AppDelegate.shareDelegate.managedObjectContext
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)
        request.entity = entity
        let predicate = NSPredicate(format: "songId == %@", songId)
        request.predicate = predicate
        do {
            let entityArray = try context.executeFetchRequest(request)
            if entityArray.count != 0 {
                return entityArray[0]
            }
            
        } catch {
            print("insert error")
        }
        return false
    }
    
}

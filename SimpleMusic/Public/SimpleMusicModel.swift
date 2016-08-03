//
//  SimpleMusicModel.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/8/1.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import Foundation
import CoreData


class SimpleMusicModel: NSManagedObject {
    // 插入
    class func insertWith(smodel: SingleMusicModel) {
        let temp = getModelWith(smodel.songId!)
        if temp as! NSObject == false {
            let model = NSEntityDescription.insertNewObjectForEntityForName("SimpleMusicModel", inManagedObjectContext: AppDelegate.shareDelegate.managedObjectContext) as! SimpleMusicModel
            model.albumName = smodel.albumName
            model.name = smodel.name
            model.picUrl = smodel.picUrl
            model.singerId = smodel.singerId
            model.singerName = smodel.singerName
            model.songId = smodel.songId
            model.songUrl = smodel.songUrl
            model.downType = smodel.downType
            model.filePath = smodel.filePath
        }
        AppDelegate.shareDelegate.saveContext()
    }
    
    // 查询
    class func getAllDataWith(passData: (NSArray) -> Void) {
        let backgroundContext = AppDelegate.shareDelegate.backgroundOnjectContext
        backgroundContext.performBlock {
            let request = NSFetchRequest()
            let entity = NSEntityDescription.entityForName("SimpleMusicModel", inManagedObjectContext: backgroundContext)
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
    class func removeWith(model: SimpleMusicModel) {
        AppDelegate.shareDelegate.managedObjectContext.deleteObject(model)
        
        AppDelegate.shareDelegate.saveContext()
        
    }
    
    class func getModelWith(songId: NSNumber) -> AnyObject {
        let context = AppDelegate.shareDelegate.managedObjectContext
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("SimpleMusicModel", inManagedObjectContext: context)
        request.entity = entity
        let predicate = NSPredicate(format: "songId == %@", songId)
        request.predicate = predicate
        
        let entityArray = try? context.executeFetchRequest(request)
        if entityArray!.count != 0 {
            return entityArray![0]
        } else {
            return false
        }
       
    }

}

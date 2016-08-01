//
//  SimpleMusicModel+CoreDataProperties.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/8/1.
//  Copyright © 2016年 薛焱. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SimpleMusicModel {

    @NSManaged var albumName: String?
    @NSManaged var name: String?
    @NSManaged var picUrl: String?
    @NSManaged var singerId: NSNumber?
    @NSManaged var singerName: String?
    @NSManaged var songId: NSNumber?
    @NSManaged var songUrl: String?
    @NSManaged var downType: NSNumber?
    @NSManaged var filePath: String?

}

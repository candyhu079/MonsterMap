//
//  DecorationButtonImage+CoreDataProperties.swift
//  MonsterMap
//
//  Created by 林尚恩 on 2016/3/3.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DecorationButtonImage {

    @NSManaged var name: String?
    @NSManaged var picture: NSData?
    @NSManaged var picturePath: String?

}

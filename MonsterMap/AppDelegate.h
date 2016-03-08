//
//  AppDelegate.h
//  MonsterMap
//
//  Created by 翁心苹 on 2016/1/15.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
//bird
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
//
@property (strong, nonatomic) UIWindow *window;

@end


//
//  ShopPetViewController.h
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/5.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BASE_URL             @"http://api.leolin.me"
#define DECORATION_URL       [BASE_URL stringByAppendingPathComponent:@"decoration"]
#define BUYCOIN_URL       [BASE_URL stringByAppendingPathComponent:@"shopDiamond"]

typedef void (^doneBlock)(NSError * error,id result);

@interface ShopPetViewController : UIViewController

@end

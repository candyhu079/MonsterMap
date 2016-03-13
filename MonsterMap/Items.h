//
//  Items.h
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/17.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASE_URL                @"http://api.leolin.me"
//#define BASE_URL                @"http://192.168.196.48:8080"
#define ITEM_URL                [BASE_URL stringByAppendingPathComponent:@"item"]
#define BUYCOIN_URL             [BASE_URL stringByAppendingPathComponent:@"shopDiamond"]
#define SHOPCOINDECORATION_URL  [BASE_URL stringByAppendingPathComponent:@"shopCoinDecoration"]
#define SHOPCOINITEM_URL        [BASE_URL stringByAppendingPathComponent:@"shopCoinItem"]
#define SHOPCOINMONSTER_URL     [BASE_URL stringByAppendingPathComponent:@"shopCoinMonster"]
#define USERMONSTER_URL         [BASE_URL stringByAppendingPathComponent:@"userMonster"]
#define INVENTORYDECORATION_URL [BASE_URL stringByAppendingPathComponent:@"inventoryDecoration"]
#define MONSTER_URL             [BASE_URL stringByAppendingPathComponent:@"monster"]
#define DECORATION_URL          [BASE_URL stringByAppendingPathComponent:@"decoration"]

typedef void (^doneBlock)(NSError * error,id result);

@interface Items : NSObject

+ (Items *) itemsSingleton;
-(void) shopDecorationPostToken:(NSString*)token
                     completion:(doneBlock)completion;
-(void) buyCoinByDiamondPostToken:(NSString*)token
                       parameters:(int) parameters
                       completion:(doneBlock)completion;
-(void) shopCoinDecorationPostToken:(NSString*)token
                               item:(NSString*)item
                         completion:(doneBlock)completion;
-(void) shopCoinItemPostToken:(NSString*)token
                        item:(NSString*)item
                completion:(doneBlock)completion;
-(void) shopCoinMonsterPostToken:(NSString*)token
                            item:(NSString*)item
                      completion:(doneBlock)completion;
-(void) userMonsterPostToken:(NSString*)token
                  completion:(doneBlock)completion;
-(void) userDecorationPostToken:(NSString*)token
                  completion:(doneBlock)completion;
-(void) shopMonsterPostToken:(NSString*)token
                  completion:(doneBlock)completion;
-(void) shopItemPostToken:(NSString*)token
                  completion:(doneBlock)completion;
@end

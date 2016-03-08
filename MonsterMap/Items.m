//
//  Items.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/17.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "AFNetworking.h"
#import "Items.h"

@implementation Items

static Items* items = nil;

+ (Items *) itemsSingleton{
    if (items == nil) {
        items = [Items new];
    }
    return items;
}
//商店 - 取裝飾品資訊
-(void) shopDecorationPostToken:(NSString*)token
                 completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:DECORATION_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}
//購買金幣
-(void) buyCoinByDiamondPostToken:(NSString*)token
                       parameters:(int) parameters
                       completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    NSString * coinsQuantity = [NSString stringWithFormat:@"%d",parameters];
    NSDictionary * jsonObj = @{@"coinsQuantity":coinsQuantity};
    [manager POST:BUYCOIN_URL parameters:jsonObj success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        NSLog(@"doHttpPost error:%@",error.description);
    }];

}
//商店 - 購買裝飾品
-(void) shopCoinDecorationPostToken:(NSString*)token
                         item:(NSString*)item
                   completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    NSString * itemName = [NSString stringWithFormat:@"%@",item];
    NSDictionary * jsonObj = @{@"itemName":itemName};
    [manager POST:SHOPCOINDECORATION_URL
       parameters:jsonObj success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}
-(void) shopCoinItemPostToken:(NSString*)token
                         item:(NSString*)item
                   completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    NSString * itemName = [NSString stringWithFormat:@"%@",item];
    NSDictionary * jsonObj = @{@"itemName":itemName};
    [manager POST:SHOPCOINITEM_URL
       parameters:jsonObj success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           
           NSData * data = [NSData dataWithData:responseObject];
           completion(nil, data);
           
       } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
           completion(error, nil);
           NSLog(@"doHttpPost error:%@",error.description);
       }];
}
-(void) shopCoinMonsterPostToken:(NSString*)token
                            item:(NSString*)item
                      completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    NSString * itemName = [NSString stringWithFormat:@"%@",item];
    NSDictionary * jsonObj = @{@"monsterName":itemName};
    [manager POST:SHOPCOINMONSTER_URL
       parameters:jsonObj success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           
           NSData * data = [NSData dataWithData:responseObject];
           completion(nil, data);
           
       } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
           completion(error, nil);
           NSLog(@"doHttpPost error:%@",error.description);
       }];
}

//商店 - 寵物
-(void) shopMonsterPostToken:(NSString*)token
                  completion:(doneBlock)completion{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:MONSTER_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}
//商店 - 消耗品
-(void) shopItemPostToken:(NSString*)token
               completion:(doneBlock)completion{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:ITEM_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}

//建屋 - 取user寵物
-(void) userMonsterPostToken:(NSString*)token
                  completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:USERMONSTER_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}

-(void) userDecorationPostToken:(NSString*)token
                     completion:(doneBlock)completion{
    
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:INVENTORYDECORATION_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}

@end

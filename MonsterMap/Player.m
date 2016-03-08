//
//  Player.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/2.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "AFNetworking.h"
#import "Player.h"


@implementation Player

static Player* player = nil;

+ (Player*) playerSingleton{
    if (player == nil) {
        player = [Player new];
        [player getPlayerInfo];
    }
    return player;
}
-(void) getPlayerInfo{
    
    _userAcount = @"0";
    _userPassword = @"0";
    _userNickname = @"0";
    _userToken = @"0";
}
//新增聯絡人
-(void) createUserWithCompletion:(doneBlock)completion{
    
    NSDictionary * jsonObj = @{USERACCOUNT_KEY:_userAcount,
                               USERPASSWORD_KEY:_userPassword,
                               USERNICKNAME_KEY:_userNickname,
                               USERPICTUREBASE64_KEY:_userPicBase64};
    [self doHttpPost:CREATEUSER_URL parameters:jsonObj completion:completion];
}
//使用者登入
-(void) userLoginWithCompletion:(doneBlock)completion{
    
    NSDictionary * jsonObj = @{USERACCOUNT_KEY:_userAcount,
                               USERPASSWORD_KEY:_userPassword};
    
    [self doHttpPost:USERLOGIN_URL parameters:jsonObj completion:completion];
}
//facebook登入
-(void) createUserByFBWithCompletion:(doneBlock)completion{
    
    NSDictionary * jsonObj = @{USERACCOUNT_KEY:_userAcount,
                               USERPASSWORD_KEY:_userPassword,
                               USERNICKNAME_KEY:_userNickname,
                               USERPICTUREBASE64_KEY:_userPicBase64};
    [self doHttpPost:CREATEUSERBYFB_URL parameters:jsonObj completion:completion];
}
//忘記密碼
-(void) forgotPasswordWithCompletion:(doneBlock)completion{
    NSDictionary * jsonObj = @{USERACCOUNT_KEY:_userAcount};
    
    [self doHttpPost:FORGOTPASSWORD_URL parameters:jsonObj completion:completion];
}
//用金幣購買商品
-(void) shopCoinItemparameters:(NSDictionary*)parameters
                    completion:(doneBlock)completion{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:player.userToken forHTTPHeaderField:@"token"];
    
    [manager POST:SHOPCOINITEM_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        NSLog(@"doHttpPost error:%@",error.description);
    }];


}
-(void) doHttpPost:(NSString*)URL
        parameters:(NSDictionary*)parameters
        completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData *data = [NSData dataWithData:responseObject];
//        NSLog(@"doHttpPost Success: %@", data);
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}

@end

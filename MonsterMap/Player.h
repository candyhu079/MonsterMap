//
//  Player.h
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/2.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASE_URL              @"http://api.leolin.me"
//#define BASE_URL              @"http://10.0.1.23:8080"

#define USERLOGIN_URL         [BASE_URL stringByAppendingPathComponent:@"userLogin"]
#define CREATEUSER_URL        [BASE_URL stringByAppendingPathComponent:@"createUser"]
#define CREATEUSERBYFB_URL    [BASE_URL stringByAppendingPathComponent:@"createUserByFB"]
#define FORGOTPASSWORD_URL    [BASE_URL stringByAppendingPathComponent:@"forgetPassword"]
#define FORGOTPASSWORD_URL    [BASE_URL stringByAppendingPathComponent:@"forgetPassword"]
#define SHOPCOINITEM_URL      [BASE_URL stringByAppendingPathComponent:@"shopCoinItem"]

#define USERACCOUNT_KEY       @"account"
#define USERPASSWORD_KEY      @"password"
#define USERNICKNAME_KEY      @"nickname"
#define USERNEWPASSWORD_KEY   @"newPassword"
#define USERPICTUREBASE64_KEY @"pictureBase64"

typedef void (^doneBlock)(NSError * error,id result);

@interface Player : NSObject

@property (nonatomic,strong) NSString * userAcount;
@property (nonatomic,strong) NSString * userPassword;
@property (nonatomic,strong) NSString * userNickname;
@property (nonatomic,strong) NSString * userPicBase64;
@property (nonatomic,strong) NSString * userToken;
@property (nonatomic,strong) NSString * userPicString;
@property (nonatomic,strong) NSNumber * coin;
@property (nonatomic,strong) NSNumber * diamond;

+ (Player *) playerSingleton;

-(void) userLoginWithCompletion:(doneBlock)completion;
-(void) createUserWithCompletion:(doneBlock)completion;
-(void) forgotPasswordWithCompletion:(doneBlock)completion;
-(void) createUserByFBWithCompletion:(doneBlock)completion;
-(void) shopCoinItemparameters:(NSDictionary*)parameters
                    completion:(doneBlock)completion;

-(void) doHttpPost:(NSString*)URL
        parameters:(NSDictionary*)parameters
        completion:(doneBlock)completion;

@end

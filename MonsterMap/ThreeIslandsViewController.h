//
//  ThreeIslandsViewController.h
//  MonsterMap
//
//  Created by 翁心苹 on 2016/1/18.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#define BASE_URL              @"http://api.leolin.me"
//#define BASE_URL              @"http://10.0.1.23:8080"
//#define BASE_URL             @"http://192.168.196.48:8080"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ThreeIslandsViewController : UIViewController

@property (nonatomic, strong) AVAudioPlayer * battleVoicePlayer;
@property (nonatomic, strong) AVAudioPlayer * mapVoicePlayer;

@end

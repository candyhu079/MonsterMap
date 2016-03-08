//
//  Music.h
//  MonsterMap
//
//  Created by Candy on 2016/2/28.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Music : NSObject
@property (nonatomic, strong) NSNumber * isMute;

+(Music *)shareMusic;
-(void)playMusic:(AVAudioPlayer *)voicePlayer;

@end

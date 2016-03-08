//
//  SoundEffect.h
//  MonsterMap
//
//  Created by Candy on 2016/2/28.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundEffect : NSObject
@property (nonatomic, strong) NSNumber * isMute;

+(SoundEffect *)shareSound;
-(void)playSoundEffect:(AVAudioPlayer *)voicePlayer;

@end

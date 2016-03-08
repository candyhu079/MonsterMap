//
//  SoundEffect.m
//  MonsterMap
//
//  Created by Candy on 2016/2/28.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "SoundEffect.h"

@implementation SoundEffect
static SoundEffect * singletonSound = nil;

+(SoundEffect *)shareSound{
    if (singletonSound == nil) {
        singletonSound = [[SoundEffect alloc] init];
    }
    return singletonSound;
}

-(void)playSoundEffect:(AVAudioPlayer *)voicePlayer{
    if ([self.isMute isEqual:@1] ) {
        [voicePlayer stop];
    }else{
        [voicePlayer play];
    }
}


@end

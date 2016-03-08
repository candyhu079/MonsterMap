//
//  Music.m
//  MonsterMap
//
//  Created by Candy on 2016/2/28.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "Music.h"

@interface Music()

@end
@implementation Music
static Music * singletonMusic = nil;

+(Music *)shareMusic{
    if (singletonMusic == nil) {
        singletonMusic = [[Music alloc] init];
    }
    return singletonMusic;
}

-(void)playMusic:(AVAudioPlayer *)voicePlayer{
    if ([self.isMute isEqual:@1] ) {
        [voicePlayer stop];
    }else{
        [voicePlayer play];
    }
}

@end

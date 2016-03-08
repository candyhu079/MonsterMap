//
//  MakeSomeNoise.swift
//  MonsterMap
//
//  Created by 林尚恩 on 2016/3/6.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

import Foundation

class MakeSomeNoise {
    func makeSomeButtonNoise(var buttonVoicePlayer:AVAudioPlayer){
        do{
            let voiceURL = NSBundle.mainBundle().URLForResource("button_press", withExtension: "mp3")
            buttonVoicePlayer = try AVAudioPlayer.init(contentsOfURL: voiceURL!)
            buttonVoicePlayer.prepareToPlay()
            SoundEffect.shareSound().playSoundEffect(buttonVoicePlayer);
        }catch{
            print("AVAudioSession Error")
        }
    }
}
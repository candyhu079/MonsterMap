//
//  ArenaEntranceScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/3/2.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import Foundation
import SpriteKit

class ArenaEntranceScene: SKScene {
    override func didMoveToView(view: SKView) {
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        if nodeTouchedName == "backButton"{
            let tvc = view?.nextResponder()?.nextResponder() as! ThreeIslandsViewController
            let vc = tvc.presentingViewController as! ViewController
            tvc.battleVoicePlayer.stop()
            Music.shareMusic().playMusic(vc.voicePlayer)
            //過場效果
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromBottom
            transition.timingFunction=CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.view!.superview!.layer.addAnimation(transition, forKey: "transition")
            view?.removeFromSuperview()
        }else if nodeTouchedName == "rankModeButton"{
//            let blackBackground=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), size: CGSize(width: 320, height: 568))
//            blackBackground.position=CGPoint(x: 160, y: 284)
//            blackBackground.name="blackBackground"
//            blackBackground.zPosition=4
//            addChild(blackBackground)
            if let scene=ArenaRankEntranceScene(fileNamed: "ArenaRankEntranceScene"){
                scene.scaleMode = .Fill
                scene.userData=NSMutableDictionary()
                scene.userData?.setObject(BirdGameSetting.URL.Arena.rawValue, forKey: "URL")
//                let transition=SKTransition.moveInWithDirection(.Down, duration: 0.4)
                //                view?.ignoresSiblingOrder=true
//                self.view!.presentScene(scene, transition: transition)
                view?.presentScene(scene)
            }
        }else if nodeTouchedName == "practiceModeButton"{
            if let scene=ArenaRankEntranceScene(fileNamed: "ArenaRankEntranceScene"){
//                let blackBackground=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), size: CGSize(width: 320, height: 568))
//                blackBackground.position=CGPoint(x: 160, y: 284)
//                blackBackground.name="blackBackground"
//                blackBackground.zPosition=4
//                addChild(blackBackground)
                scene.scaleMode = .Fill
                scene.userData=NSMutableDictionary()
                scene.userData?.setObject(BirdGameSetting.URL.Practice.rawValue, forKey: "URL")
                view?.presentScene(scene)
            }
        }
    }
}
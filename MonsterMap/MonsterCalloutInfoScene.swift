//
//  MonsterCalloutInfoScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/1/22.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import SpriteKit
class MonsterCalloutInfoScene: SKScene {
    let userPhoneWidth=UIScreen.mainScreen().bounds.width
    let userPhoneHeight=UIScreen.mainScreen().bounds.height
    override func didMoveToView(view: SKView) {
        backgroundColor=UIColor.clearColor()
        (childNodeWithName("monsterImage") as! SKSpriteNode).texture=SKTexture(image: UIImage(data: userData?.objectForKey("image") as! NSData)!)
        
        //如果在範圍外
        if !(userData?.objectForKey("withinRange") as! Bool){
        let monsterCalloutInfoBattle=childNodeWithName("monsterCalloutInfoBattle") as! SKSpriteNode
        monsterCalloutInfoBattle.texture=SKTexture(imageNamed: "monsterCalloutInfoTooFar")
        }
        let monsterType=childNodeWithName("monsterType") as! SKLabelNode
        let monsterName=childNodeWithName("monsterName") as! SKLabelNode
        let monsterLevel=childNodeWithName("monsterLevel") as! SKLabelNode
        monsterType.text="屬性：\(userData?.objectForKey("type") as! String)"
        monsterName.text=userData?.objectForKey("name") as? String
        monsterLevel.text="等級：\(userData?.objectForKey("level") as! String)"
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        if nodeTouchedName == "monsterCalloutInfoBattle"{
            if userData?.objectForKey("withinRange") as! Bool{
            if let scene=MapMonsterBattleScene(fileNamed: "MapMonsterBattleScene"){
                scene.scaleMode = .Fill
                scene.userData=NSMutableDictionary()
                scene.userData?.setObject(userData?.objectForKey("level") as! String, forKey: "level")
                scene.userData?.setObject((userData?.objectForKey("name") as? String)!, forKey: "name")
                scene.userData?.setObject(userData?.objectForKey("image") as! NSData, forKey: "image")
                scene.userData?.setObject((userData?.objectForKey("annotation"))!, forKey: "annotation")

//                view!.frame=CGRect(x: 0, y: 0, width: userPhoneWidth, height: userPhoneHeight)
//                let transition=SKTransition.moveInWithDirection(.Up, duration: 1)
//                view?.ignoresSiblingOrder=true
//                    self.view!.presentScene(scene, transition: transition)
                //過場效果
//                let transition = CATransition()
//                transition.duration = 0.4
//                transition.type = kCATransitionMoveIn
//                transition.subtype = kCATransitionFromTop
//                transition.timingFunction=CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
//                transition.delegate=self
//                transition.fillMode=kCAFillModeForwards
//                self.view!.layer.addAnimation(transition, forKey: "transition")
                view?.presentScene(scene)
            }
            }
        }
        if nodeTouchedName == "monsterCalloutInfoCancel"{
            view?.removeFromSuperview()
        }
    }
}
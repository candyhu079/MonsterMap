//
//  OtherUserCalloutInfoScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/1/22.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import SpriteKit
import Alamofire
import SwiftyJSON

class OtherUserCalloutInfoScene: SKScene {
    let userPhoneWidth=UIScreen.mainScreen().bounds.width
    let userPhoneHeight=UIScreen.mainScreen().bounds.height
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    enum URL:String{
        case AddFriend="http://api.leolin.me/addFriend"
    }
    override func didMoveToView(view: SKView) {
        backgroundColor=UIColor.clearColor()
        headers=["token":token]
        
//        (childNodeWithName("monsterImage") as! SKSpriteNode).texture=SKTexture(image: userData?.objectForKey("image") as! UIImage)
        let userImage=SKShapeNode(circleOfRadius: 50)
        userImage.name="userImage"
        userImage.position=CGPoint(x: 113, y: 190)
        //        userImage.xScale=0.8
        //        userImage.yScale=0.8
        userImage.lineWidth=3
        userImage.fillColor=SKColor.whiteColor()
        addChild(userImage)
        (self.childNodeWithName("userImage") as! SKShapeNode).fillTexture=SKTexture(image: userData?.objectForKey("image") as! UIImage)
        //如果在範圍外
//        if !(userData?.objectForKey("withinRange") as! Bool){
//        let monsterCalloutInfoBattle=childNodeWithName("monsterCalloutInfoBattle") as! SKSpriteNode
//        monsterCalloutInfoBattle.texture=SKTexture(imageNamed: "monsterCalloutInfoTooFar")
//        }
        let monsterName=childNodeWithName("monsterName") as! SKLabelNode
        let monsterLevel=childNodeWithName("monsterLevel") as! SKLabelNode
        monsterName.text=userData?.objectForKey("name") as? String
        monsterLevel.text="\(userData?.objectForKey("level") as! String)"
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        if nodeTouchedName == "monsterCalloutInfoBattle"{
//            if userData?.objectForKey("withinRange") as! Bool{
                if let scene=ArenaMonsterBattleScene(fileNamed: "ArenaMonsterBattleScene"){
                    scene.scaleMode = .Fill
                    scene.userData=NSMutableDictionary()
                    print(userData?.objectForKey("id")?.stringValue)
                    scene.userData?.setObject((userData?.objectForKey("id"))!, forKey: "id")
                    scene.userData?.setObject(userData?.objectForKey("image") as! UIImage, forKey: "image")
                    scene.userData?.setObject("practice", forKey: "arenaType")
                    scene.userData?.setObject("map", forKey: "where")
                    view!.frame=CGRect(x: 0, y: 0, width: userPhoneWidth, height: userPhoneHeight)
                    view?.presentScene(scene)
                }
//            }
        }else if nodeTouchedName == "monsterCalloutInfoCancel"{
            view?.removeFromSuperview()
        }else if nodeTouchedName == "addFriendButton"{
            alamoRequsetUpdate(URL.AddFriend.rawValue, parameter: ["friendId":(userData?.objectForKey("id")?.stringValue)!], completion: { (inner) -> Void in
            })
        }else if nodeTouchedName == "contactButton"{
            
        }
    }
    func alamoRequsetUpdate(URL:String,parameter:[String:AnyObject],completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
        Alamofire.request(.POST, URL,parameters: parameter, headers: headers,encoding:.JSON).responseJSON { (response) -> Void in
            switch response.result{
            case .Success:
                let swiftyJsonVar=JSON(response.result.value!)
                if let jsonResult=swiftyJsonVar["result"].arrayObject{
                    let monsterJSON=jsonResult as! [[String:AnyObject]]
                    completion(inner: {return monsterJSON})
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}
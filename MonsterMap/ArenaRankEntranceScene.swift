//
//  ArenaRankEntranceScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/3/2.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import Foundation
import SpriteKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ArenaRankEntranceScene: SKScene {
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    var otherUserInfo:[[String:AnyObject]]=[]
    var arenaType:String=""
    override func didMoveToView(view: SKView) {
        headers=["token":token]
        if ((userData?.objectForKey("URL"))! as! String).hasSuffix("a"){
            arenaType="arena"
        }else{
            arenaType="practice"
        }
        let userImage=SKShapeNode(circleOfRadius: 50)
        userImage.name="userImage"
        userImage.position=CGPoint(x: 160, y: 463)
//        userImage.xScale=0.8
//        userImage.yScale=0.8
        userImage.lineWidth=3
        userImage.fillColor=SKColor.whiteColor()
        addChild(userImage)
        let enemy1Image=SKShapeNode(circleOfRadius: 50)
        enemy1Image.name="enemy1Image"
        enemy1Image.position=CGPoint(x: 63, y: 253)
        enemy1Image.xScale=0.8
        enemy1Image.yScale=0.8
        enemy1Image.lineWidth=3
        enemy1Image.fillColor=SKColor.whiteColor()
        addChild(enemy1Image)
        let enemy2Image=SKShapeNode(circleOfRadius: 50)
        enemy2Image.name="enemy2Image"
        enemy2Image.position=CGPoint(x: 160, y: 192)
        enemy2Image.xScale=0.8
        enemy2Image.yScale=0.8
        enemy2Image.lineWidth=3
        enemy2Image.fillColor=SKColor.whiteColor()
        addChild(enemy2Image)
        let enemy3Image=SKShapeNode(circleOfRadius: 50)
        enemy3Image.name="enemy3Image"
        enemy3Image.position=CGPoint(x: 257, y: 253)
        enemy3Image.xScale=0.8
        enemy3Image.yScale=0.8
        enemy3Image.lineWidth=3
        enemy3Image.fillColor=SKColor.whiteColor()
        addChild(enemy3Image)
        
        runClearBackgroundAction()
        alamoRequset((userData?.objectForKey("URL"))! as! String) { (inner) -> Void in
            do{
                let result=try inner()
                self.otherUserInfo=result
                var numberArray:[Int]=[]
                var gotThreeNumber=false
                while(!gotThreeNumber){
                    let random:Int=Int(arc4random_uniform(UInt32(result.count)))
                    if !(numberArray.contains(random)){
                        numberArray.append(random)
                        if numberArray.count == 3{
                            gotThreeNumber=true
                        }
                    }
                }
                for i in 1...3{
                    (self.childNodeWithName("enemy\(i)Name") as! SKLabelNode).text=result[numberArray[i-1]]["name"] as? String
                    (self.childNodeWithName("enemy\(i)Rank") as! SKLabelNode).text="排名\((result[numberArray[i-1]]["rank"]?.integerValue)!)"
                    self.alamoImageRequset((result[numberArray[i-1]]["picture"] as? String)!, completion: { (inner) -> Void in
                        do{
                            let image=try inner()
                                (self.childNodeWithName("enemy\(i)Image") as! SKShapeNode).fillTexture=SKTexture(image: image)
//                            (self.childNodeWithName("enemy\(i)Image") as! SKSpriteNode).texture=SKTexture(image: image)
                        }catch let error{
                            print(error)
                        }
                    })
                }
            }catch let error{
                print(error)
            }
        }
        alamoRequsetForUser(BirdGameSetting.URL.UserProfile.rawValue) { (inner) -> Void in
            do{
                let result=try inner()
                (self.childNodeWithName("userName") as! SKLabelNode).text=result["nickname"] as? String
                (self.childNodeWithName("userRank") as! SKLabelNode).text="排名\((result["rank"]?.integerValue)!)"
                self.alamoImageRequset((result["picture"] as? String)!, completion: { (inner) -> Void in
                    do{
                        let image=try inner()
                        (self.childNodeWithName("userImage") as! SKShapeNode).fillTexture=SKTexture(image: image)
//                        (self.childNodeWithName("userImage") as! SKSpriteNode).texture=SKTexture(image: image)
                    }catch let error{
                        print(error)
                    }
                })
            }catch let error{
                print(error)
            }
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        if nodeTouchedName == "cancelButton"{
            if let scene=ArenaEntranceScene(fileNamed: "ArenaEntranceScene"){
                scene.scaleMode = .Fill
                view?.presentScene(scene)
            }
        }else if nodeTouchedName == "switchButton"{
            runClearBackgroundAction()
            var numberArray:[Int]=[]
            var gotThreeNumber=false
            while(!gotThreeNumber){
                let random:Int=Int(arc4random_uniform(UInt32(otherUserInfo.count)))
                if !(numberArray.contains(random)){
                    numberArray.append(random)
                    if numberArray.count == 3{
                        gotThreeNumber=true
                    }
                }
            }
            for i in 1...3{
                (self.childNodeWithName("enemy\(i)Name") as! SKLabelNode).text=otherUserInfo[numberArray[i-1]]["name"] as? String
                (self.childNodeWithName("enemy\(i)Rank") as! SKLabelNode).text="排名\((otherUserInfo[numberArray[i-1]]["rank"]?.integerValue)!)"
                self.alamoImageRequset((otherUserInfo[numberArray[i-1]]["picture"] as? String)!, completion: { (inner) -> Void in
                    do{
                        let image=try inner()
                        (self.childNodeWithName("enemy\(i)Image") as! SKShapeNode).fillTexture=SKTexture(image: image)
                    }catch let error{
                        print(error)
                    }
                })
            }
        }else if nodeTouchedName == "enemy1Image"{
            let rankArray=Array((self.childNodeWithName("enemy1Rank") as! SKLabelNode).text!.characters)
            var rank=""
            for i in 2..<rankArray.count{
                rank += String(rankArray[i])
            }
            for a in otherUserInfo{
                if a["rank"]?.stringValue==rank{
                    if let scene=ArenaMonsterBattleScene(fileNamed: "ArenaMonsterBattleScene"){
                        scene.scaleMode = .Fill
                        scene.userData=NSMutableDictionary()
                        scene.userData?.setObject(a["userId"]!, forKey: "id")
                        scene.userData?.setObject(arenaType, forKey: "arenaType")
                        scene.userData?.setObject("arena", forKey: "where")
                        view?.presentScene(scene)
                    }
                }
            }
        }else if nodeTouchedName == "enemy2Image"{
            let rankArray=Array((self.childNodeWithName("enemy2Rank") as! SKLabelNode).text!.characters)
            var rank=""
            for i in 2..<rankArray.count{
                rank += String(rankArray[i])
            }
            for a in otherUserInfo{
                if a["rank"]?.stringValue==rank{
                    if let scene=ArenaMonsterBattleScene(fileNamed: "ArenaMonsterBattleScene"){
                        scene.scaleMode = .Fill
                        scene.userData=NSMutableDictionary()
                        scene.userData?.setObject(a["userId"]!, forKey: "id")
                        scene.userData?.setObject(arenaType, forKey: "arenaType")
                        scene.userData?.setObject("arena", forKey: "where")
                        view?.presentScene(scene)
                    }
                }
            }
        }else if nodeTouchedName == "enemy3Image"{
            let rankArray=Array((self.childNodeWithName("enemy3Rank") as! SKLabelNode).text!.characters)
            var rank=""
            for i in 2..<rankArray.count{
                rank += String(rankArray[i])
            }
            for a in otherUserInfo{
                if a["rank"]?.stringValue==rank{
                    if let scene=ArenaMonsterBattleScene(fileNamed: "ArenaMonsterBattleScene"){
                        scene.scaleMode = .Fill
                        scene.userData=NSMutableDictionary()
                        scene.userData?.setObject(arenaType, forKey: "arenaType")
                        scene.userData?.setObject(a["userId"]!, forKey: "id")
                        scene.userData?.setObject("arena", forKey: "where")
                        view?.presentScene(scene)
                    }
                }
            }
        }
    }
    func alamoImageRequset(thePicturePath:String,completion: (inner: () throws -> UIImage) -> Void) -> Void {
        let picturePath:String=BirdGameSetting.URL.URLBegining.rawValue+thePicturePath
        let picturePathEncoded=picturePath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        //        Request.addAcceptableImageContentTypes(["image/png"])
        Alamofire.request(.GET, picturePathEncoded, headers: headers).responseImage { (response) -> Void in
            switch response.result{
            case .Success:
                if let image=response.result.value{
                    print("image downloaded: \(image)")
                    completion(inner: {return image})
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    func alamoRequset(URL:String,completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
        Alamofire.request(.POST, URL, headers: headers).responseJSON { (response) -> Void in
            let swiftyJsonVar=JSON(response.result.value!)
            if let jsonResult=swiftyJsonVar["result"].arrayObject{
                let monsterJSON=jsonResult as! [[String:AnyObject]]
                completion(inner: {return monsterJSON})
            }
        }
    }
    func alamoRequsetForUser(URL:String,completion: (inner: () throws -> [String:AnyObject]) -> Void) -> Void {
        Alamofire.request(.POST, URL, headers: headers).responseJSON { (response) -> Void in
            let swiftyJsonVar=JSON(response.result.value!)
            let jsonResult=swiftyJsonVar["result"].dictionaryObject
            completion(inner: {return jsonResult!})
        }
    }
    func createClearBackground(){
        let clearBackground=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 320, height: 568))
        clearBackground.position=CGPoint(x: 160, y: 284)
        clearBackground.name="clearBackground"
        clearBackground.zPosition=9
        addChild(clearBackground)
    }
    func removeClearBackground(){
        print("removeclearbackground")
        if let b=childNodeWithName("clearBackground"){
            b.removeFromParent()
        }
    }
    func runClearBackgroundAction(){
        let runCreateClearBackground=SKAction.runBlock { () -> Void in
            self.createClearBackground()
        }
        let runRemove=SKAction.runBlock { () -> Void in
            self.removeClearBackground()
        }
        let waitDuration1=SKAction.waitForDuration(1)
        runAction(SKAction.sequence([runCreateClearBackground,waitDuration1,runRemove]))
    }
}
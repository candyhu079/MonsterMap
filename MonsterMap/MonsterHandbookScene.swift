//
//  MonsterHandbookScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/1/27.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import UIKit
import SpriteKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import CoreData

//怪獸圖鑑
class MonsterHandbookScene: SKScene {
    var itemFrameNode:SKSpriteNode!
    var monsterHandbookBackground:SKSpriteNode!
    var monsterHandbookItemBackground:SKSpriteNode!
    var scrollBarNode:SKSpriteNode!
    var scrollBarbarNode:SKSpriteNode!
    var monsterName:SKLabelNode!
    var monsterID:SKLabelNode!
    var monsterImageNode:SKSpriteNode!
    var itemFrameOriginalY:CGFloat!
    var handbookOriginalY:CGFloat!
    var touchBeganLocation:CGPoint!
    var monsterCount:Int!
    var monsterNameToDetectRepeat:[String]=["name"]
    let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext:NSManagedObjectContext!
    var monsterImage:[MonsterImage] = []
    var monsterButtonImage:[MonsterButtonImage] = []
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    var voicePlayer:AVAudioPlayer!
    
//    var a=0
    override func didMoveToView(view: SKView) {
        //Candy Add
        do{
            let voiceURL:NSURL = NSBundle.mainBundle().URLForResource("button_press.mp3", withExtension: nil)!
            try voicePlayer = AVAudioPlayer.init(contentsOfURL: voiceURL)
            voicePlayer.numberOfLoops = 0;
            voicePlayer.prepareToPlay()
        }catch{
            print("AVAudioSession Error")
        }
        
        
        managedObjectContext=appDelegate.managedObjectContext
        headers=["token":token]
        itemFrameNode=childNodeWithName("monsterHandbookItemFrame") as! SKSpriteNode
        itemFrameOriginalY=itemFrameNode.position.y
        monsterHandbookItemBackground=childNodeWithName("monsterHandbookItemBackground") as! SKSpriteNode
        monsterHandbookBackground=childNodeWithName("monsterHandbookBackground") as! SKSpriteNode
        for a in monsterHandbookBackground.children{
            a.hidden=true
        }
        scrollBarNode=childNodeWithName("monsterHandbookScrollBar") as! SKSpriteNode
        scrollBarbarNode=childNodeWithName("monsterHandbookScrollBarbar") as! SKSpriteNode
        monsterName=monsterHandbookBackground.childNodeWithName("monsterName") as! SKLabelNode
        monsterID=monsterHandbookBackground.childNodeWithName("monsterID") as!SKLabelNode
        monsterImageNode=monsterHandbookBackground.childNodeWithName("monsterImage") as! SKSpriteNode
        
        //載入怪獸
//        (inner: () throws -> [[String:AnyObject]])
        alamoRequset(BirdGameSetting.URL.Monster.rawValue){ (inner) -> Void in
            do{
                let result=try inner()
                var positionRow=0
                var positionColumn=0
                self.monsterCount=result.count
                for i in 0..<result.count {
                    let monster=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                    let name:String=result[i]["name"]! as! String
                    let picturePath:String=result[i]["picturePath"]! as! String
                    let buttonPicturePath:String=result[i]["buttonPicturePath"]! as! String
                    monster.name="monsterID\(i+1)"
                    monster.position=CGPoint(x: 0+(5+monster.frame.width)*CGFloat(positionColumn), y: 0-(5+monster.frame.height)*CGFloat(positionRow))
                    self.itemFrameNode.addChild(monster)
                    monster.userData=NSMutableDictionary()
                    monster.userData?.setObject(name, forKey: "name")
                    monster.userData?.setObject(result[i]["id"]!, forKey: "id")
                    monster.userData?.setObject(result[i]["description"]!, forKey: "description")
                    monster.userData?.setObject(picturePath, forKey: "picturePath")
                    monster.userData?.setObject(buttonPicturePath, forKey: "buttonPicturePath")
                    self.somethingAboutImage(monster, thePicturePath: buttonPicturePath,thePictureType: "MonsterButtonImage")
                    self.somethingAboutImage(monster,thePicturePath: picturePath,thePictureType: "MonsterImage")

                    if positionColumn==2{
                        positionRow++
                        positionColumn = -1
                    }
                    positionColumn++
                }
                let moc=self.managedObjectContext
                let monsterImageFetch=NSFetchRequest(entityName: "MonsterImage")
                let monsterButtonImageFetch=NSFetchRequest(entityName: "MonsterButtonImage")
                self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
                self.monsterButtonImage=try moc.executeFetchRequest(monsterButtonImageFetch) as! [MonsterButtonImage]

                if result.count>12{
                    let itemFrameRange = 0 - (self.itemFrameNode.childNodeWithName("monsterID\(self.monsterCount)")?.position.y)!
                    self.scrollBarbarNode.size.height = self.scrollBarNode.frame.height * (self.monsterHandbookItemBackground.frame.height/itemFrameRange)
                    self.scrollBarbarNode.position.y = self.scrollBarNode.position.y + (self.scrollBarNode.frame.height/2) - (self.scrollBarbarNode.frame.height/2) - 2
                }
                for a in self.monsterHandbookBackground.children{
                    a.hidden=false
                }
                self.setHandbookInfo("monsterID1")
                
            }catch let error{
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
    func alamoImageRequset(thePicturePath:String,completion: (inner: () throws -> UIImage) -> Void) -> Void {
        let picturePath:String=BirdGameSetting.URL.URLBegining.rawValue+thePicturePath
        let picturePathEncoded=picturePath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
//        Request.addAcceptableImageContentTypes(["image/png"])
        Alamofire.request(.GET, picturePathEncoded, headers: headers).responseImage { (response) -> Void in
            switch response.result{
            case .Success:
                if let image=response.result.value{
            completion(inner: {return image})
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let range=(location?.y)!-touchBeganLocation.y
        let itemFrameMoveRange = 0 - (itemFrameNode.childNodeWithName("monsterID\(monsterCount)")?.position.y)! - 3 * itemFrameNode.frame.height
        let changePositionValue=itemFrameMoveRange / CGFloat(monsterCount) / 2
        if monsterHandbookItemBackground.containsPoint(touchBeganLocation){
        if range > 0{
            if itemFrameNode.position.y < itemFrameOriginalY + itemFrameMoveRange{
                itemFrameNode.position.y += changePositionValue
                scrollBarbarNode.position.y -= (scrollBarNode.frame.height-scrollBarbarNode.frame.height-5) / (itemFrameMoveRange / changePositionValue)
            }else{
                scrollBarbarNode.position.y=scrollBarNode.position.y - (scrollBarNode.frame.height/2) + (scrollBarbarNode.frame.height/2) + 1.5
            }
        }
        if range < 0{
            if itemFrameNode.position.y > itemFrameOriginalY{
                itemFrameNode.position.y -= changePositionValue
                scrollBarbarNode.position.y += (scrollBarNode.frame.height-scrollBarbarNode.frame.height-5) / (itemFrameMoveRange / changePositionValue)
            }else{
                itemFrameNode.position.y=itemFrameOriginalY
                scrollBarbarNode.position.y=scrollBarNode.position.y + (scrollBarNode.frame.height/2) - (scrollBarbarNode.frame.height/2) - 1.5
            }
        }
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchBeganLocation=touches.first?.locationInNode(self)
        
        }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        let locationInItemFrame=touches.first?.locationInNode(itemFrameNode)
        
        if touchBeganLocation == location{
            //Candy Add
            SoundEffect.shareSound().playSoundEffect(voicePlayer)
            
            if nodeTouchedName == "backButton"{
                //過場效果
                let transition = CATransition()
//                transition.delegate=self
                transition.duration = 0.4
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromBottom
                transition.timingFunction=CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.view!.superview!.layer.addAnimation(transition, forKey: "transition")
                view?.removeFromSuperview()
//                if let scene=BackpackScene(fileNamed: "BackpackScene"){
//                    scene.scaleMode = .Fill
//                    view?.presentScene(scene)
//                }
            }
            
            if monsterHandbookItemBackground.containsPoint(touchBeganLocation){
                for a in itemFrameNode.children{
                    if a.containsPoint(locationInItemFrame!){
                        setHandbookInfo(a.name!)
                    }
                }

//        for a:SKNode in self.children{
//            let hasPrefix=a.name?.hasPrefix("monsterID")
//            if ((hasPrefix) == true){
//                if a.containsPoint(location!){
//                    monsterName.text=childNodeWithName(a.name!)?.userData?.objectForKey("name") as? String
//                    monsterID.text=childNodeWithName(a.name!)?.userData?.objectForKey("id")?.stringValue
//                    
//                }
//            }
//        }
            }
        }
    }
    func setHandbookInfo(theNodeName:String){
        //隱藏說明SKLabelNode
        for a in monsterHandbookBackground.children{
            let hasPrefix=a.name?.hasPrefix("monsterDescription")
            if hasPrefix==true{
                a.hidden=true
            }
        }
        
        let id:Int=(itemFrameNode.childNodeWithName(theNodeName)?.userData?.objectForKey("id")?.integerValue)!
        let theMonsterName=itemFrameNode.childNodeWithName(theNodeName)?.userData?.objectForKey("name") as! String
        let thePicturePath=itemFrameNode.childNodeWithName(theNodeName)?.userData?.objectForKey("picturePath") as! String

        monsterName.text=theMonsterName
        monsterID.text="編號  \(id)"
        
        //讀圖
        for b in self.monsterImage{
            if b.name! == theMonsterName && b.picturePath! == thePicturePath{
                monsterImageNode.texture=SKTexture(image: UIImage(data: b.picture!)!)
            }
        }
    
        //把取到的說明轉成陣列
        let descriptionText=Array((itemFrameNode.childNodeWithName(theNodeName)?.userData?.objectForKey("description") as? String)!.characters)
        //把字分給description的node 每個最多分11個字
        let totalLines=(descriptionText.count/11)+1
        var wordCount=0
        
        for i in 0..<totalLines{
            var linesLength=0
            var linesString:String=""
            while linesLength<11{
                if wordCount == descriptionText.count{
                    break
                }
                linesString=linesString+String(descriptionText[wordCount])
                linesLength=linesString.characters.count
                wordCount++
            }
            let label=monsterHandbookBackground.childNodeWithName("monsterDescription\(i)") as! SKLabelNode
            label.hidden=false
            label.text=linesString
        }
    }
    func somethingAboutImage(theNode:SKSpriteNode,thePicturePath:String,thePictureType:String){
        let moc=self.managedObjectContext
        let monsterImageFetch=NSFetchRequest(entityName: thePictureType)
        var coredataHasImage=false
        let theMonsterName=theNode.userData?.objectForKey("name") as! String
        do{
                switch thePictureType {
                    case "MonsterImage":
                        self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
                        for b in self.monsterImage{
                            //delete image
                            if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                                moc.deleteObject(b)
                                do{
                                    try moc.save()
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            }else if b.name! == theMonsterName && b.picturePath! == thePicturePath {
                                coredataHasImage=true
                                break
                            }
                        }
                    break
                    case "MonsterButtonImage":
                        self.monsterButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterButtonImage]
                        for b in self.monsterButtonImage{
                            //delete image
                            if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                                moc.deleteObject(b)
                                do{
                                    try moc.save()
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            }else if b.name! == theMonsterName && b.picturePath! == thePicturePath {
                                    theNode.texture=SKTexture(image: UIImage(data: b.picture!)!)
                                coredataHasImage=true
                                break
                            }
                        }
                    break
                default:
                    break
                }
            if coredataHasImage==false{
                self.alamoImageRequset(thePicturePath, completion: { (inner) -> Void in
                    do{
                        let image = try inner()
                        if thePictureType == "MonsterButtonImage"{
                            theNode.texture=SKTexture(image: image)
                        }
                        if thePicturePath == self.itemFrameNode.childNodeWithName("monsterID1")?.userData?.objectForKey("picturePath") as! String{
                            self.monsterImageNode.texture=SKTexture(image: image)
                        }
                        
                        if self.monsterNameToDetectRepeat.contains(thePicturePath) == false{
                            self.monsterNameToDetectRepeat.append(thePicturePath)
                            switch thePictureType {
                            case "MonsterImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    try moc.save()
                                    self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "MonsterButtonImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterButtonImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    try moc.save()
                                    self.monsterButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterButtonImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                    
                                }
                                break
                            default:
                                break
                            }
                        }
                    }catch let error{
                        print(error)
                    }
                })
            }
        }catch{
            fatalError("Failed to fetch employees: \(error)")
        }
    }
}

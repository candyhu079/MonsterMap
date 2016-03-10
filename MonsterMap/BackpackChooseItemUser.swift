//
//  BackpackChooseItemUser.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/2/27.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import SpriteKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import CoreData

class BackpackChooseItemUser: SKScene {
    var touchBeganLocation:CGPoint!
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    var monsterName:SKLabelNode!
    var whatUserUse:SKLabelNode!
    var howManyLeft:SKLabelNode!
    var monsterNameToDetectRepeat:[String]=["name"]
    let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext:NSManagedObjectContext!
    var monsterImage:[MonsterImage] = []
    var monsterButtonImage:[MonsterButtonImage] = []
    var monsterStatusCount=0
    var monsterItem:SKSpriteNode!
//    var monsterBarNode:SKSpriteNode!
//    var monsterBarbarNode:SKSpriteNode!
//    var monsterCount:Int!
    var itemBackground:SKSpriteNode!
    var itemQuantity:Int!

    override func didMoveToView(view: SKView) {
        managedObjectContext=appDelegate.managedObjectContext
        headers=["token":token]
        monsterName=childNodeWithName("monsterName") as! SKLabelNode
        howManyLeft=childNodeWithName("howManyLeft") as! SKLabelNode
        monsterItem=childNodeWithName("monsterItem") as! SKSpriteNode
        whatUserUseDescription("使用\((userData?.objectForKey("itemName"))!)，可回復\((userData?.objectForKey("enrichBlood"))!)HP")
//        whatUserUse.text="使用\((userData?.objectForKey("itemName"))!)，可回復\((userData?.objectForKey("enrichBlood"))!)HP"
//        monsterBarNode=monsterName.childNodeWithName("monsterScrollBar") as! SKSpriteNode
//        monsterBarbarNode=monsterName.childNodeWithName("monsterScrollBarbar") as! SKSpriteNode
        itemBackground=childNodeWithName("backpackItemAreaBackground") as! SKSpriteNode
        
        itemQuantity=userData?.objectForKey("quantity")?.integerValue
        setItemQuantity()
        monsterName.hidden=true
        monsterItem.hidden=true

        alamoRequset(BirdGameSetting.URL.UserMonster.rawValue) { (inner) -> Void in
            do{
                let result=try inner()
                var positionRow=0
                var positionColumn=0
                
                for i in 0..<result.count {
                    if Int(result[i]["status"]! as! NSNumber)==1{
                        self.monsterStatusCount++

                    let monster=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                    monster.name="monsterID\(self.monsterStatusCount)"
                    monster.position=CGPoint(x: 0+(5+monster.frame.width)*CGFloat(positionColumn), y: 0-(5+monster.frame.height)*CGFloat(positionRow))
                    self.monsterItem.addChild(monster)
                    self.setMonsterUserdata(monster, resultMonster: result, i: i)
                    let picturePath:String=result[i]["picturePath"]! as! String
                    let buttonPicturePath:String=result[i]["buttonPicturePath"]! as! String
                    
                    
                    monster.userData?.setObject(picturePath, forKey: "picturePath")
                    monster.userData?.setObject(buttonPicturePath, forKey: "buttonPicturePath")
                    self.somethingAboutImage(monster,thePicturePath: buttonPicturePath,thePictureType: "MonsterButtonImage")
                    self.somethingAboutImage(monster,thePicturePath: picturePath,thePictureType: "MonsterImage")
                    
                    
                    
                    if positionColumn==2{
                        positionRow++
                        positionColumn = -1
                    }
                    positionColumn++
                        if self.monsterStatusCount==3{
                            break
                        }
                    }
                }
                self.setMonsterInfo("monsterID1")
                self.monsterName.hidden=false
                self.monsterItem.hidden=false
//                if result.count>12{
//                    let itemFrameRange = 0 - (self.monsterItem.childNodeWithName("monsterID\(self.monsterCount)")?.position.y)!
//                    self.monsterBarbarNode.size.height = self.monsterBarNode.frame.height * (self.itemBackground.frame.height/itemFrameRange)
//                    self.monsterBarbarNode.position.y = self.monsterBarNode.position.y + (self.monsterBarNode.frame.height/2) - (self.monsterBarbarNode.frame.height/2) - 2
//                }
            }catch let error{
                print(error)
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
        print(nodeTouchedName)
        if touchBeganLocation==location{
            if nodeTouchedName == "backButton"{
//                view?.removeFromSuperview()
                if let scene=BackpackScene(fileNamed: "BackpackScene"){
                    scene.scaleMode = .Fill
                    view?.presentScene(scene)
                }
                //            NSNotificationCenter.defaultCenter().postNotificationName("monsterCalloutInfoCancel", object: nil)
            
        }else if nodeTouchedName == "useItemButton"{
            let theItemName:String=(userData?.objectForKey("itemName"))! as! String
            var theMonsterID:Int
            let theMonsterName:String=monsterName.text!
                if itemQuantity > 0{
                itemQuantity!--
                setItemQuantity()

            for a in monsterItem.children{
                if a.userData?.objectForKey("name") as! String == theMonsterName{
                    self.setMonsterInfo(a.name!)
                    theMonsterID=(a.userData?.objectForKey("id")?.integerValue)!
                    setMonsterHP(a)
                    alamoRequsetUpdate(BirdGameSetting.URL.UseItem.rawValue, parameter: ["itemName":theItemName,"monsterId":"\(theMonsterID)","monsterName":theMonsterName], completion: { (inner) -> Void in
                        
                    })
                }
            }
                }
        }
        }
        if itemBackground.containsPoint(touchBeganLocation){
            let locationInMonsterFrame=touches.first?.locationInNode(monsterItem)
            for a in monsterItem.children{
                if a.containsPoint(locationInMonsterFrame!){
                    setMonsterInfo(a.name!)
                }
            }
        }
    }
    func alamoRequset(URL:String,completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
        Alamofire.request(.POST, URL, headers: headers).responseJSON { (response) -> Void in
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
    func setMonsterUserdata(monster:SKNode,resultMonster:[[String:AnyObject]],i:Int){
        monster.userData=NSMutableDictionary()
        monster.userData?.setObject(resultMonster[i]["name"]!, forKey: "name")
        monster.userData?.setObject(resultMonster[i]["id"]!, forKey: "id")
        monster.userData?.setObject(resultMonster[i]["type"]!, forKey: "type")
        monster.userData?.setObject(resultMonster[i]["hp"]!, forKey: "hp")
        monster.userData?.setObject(resultMonster[i]["defense"]!, forKey: "defense")
        monster.userData?.setObject(resultMonster[i]["speed"]!, forKey: "speed")
        monster.userData?.setObject(resultMonster[i]["basicDamage"]!, forKey: "basicDamage")
        monster.userData?.setObject(resultMonster[i]["basicDamageLevelUp"]!, forKey: "basicDamageLevelUp")
        monster.userData?.setObject(resultMonster[i]["defenseLevelUp"]!, forKey: "defenseLevelUp")
        monster.userData?.setObject(resultMonster[i]["hpLevelUp"]!, forKey: "hpLevelUp")
        monster.userData?.setObject(resultMonster[i]["speedLevelUp"]!, forKey: "speedLevelUp")
        monster.userData?.setObject(resultMonster[i]["level"]!, forKey: "level")
        monster.userData?.setObject(resultMonster[i]["status"]!, forKey: "status")
        monster.userData?.setObject(resultMonster[i]["experience"]!, forKey: "experience")
        monster.userData?.setObject(resultMonster[i]["monsterBlood"]!, forKey: "monsterBlood")
        monster.userData?.setObject(resultMonster[i]["monsterBloodLimit"]!, forKey: "monsterBloodLimit")
    }
    func somethingAboutImage(theNode:SKSpriteNode,thePicturePath:String,thePictureType:String){
        let moc=self.managedObjectContext
        let monsterImageFetch=NSFetchRequest(entityName: thePictureType)
        var fetchError:NSError?=nil
        var coredataHasImage=false
        let theMonsterName=theNode.userData?.objectForKey("name") as! String
        do{
            let fetchCount=moc.countForFetchRequest(monsterImageFetch, error: &fetchError)
            if fetchCount>0{
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
            }
            if coredataHasImage==false{
                self.alamoImageRequset(thePicturePath, completion: { (inner) -> Void in
                    do{
                        let image = try inner()
                        if thePictureType == "MonsterButtonImage" || thePictureType == "ItemButtonImage" || thePictureType == "DecorationButtonImage"{
                            theNode.texture=SKTexture(image: image)
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
                                    print("儲存\(theMonsterName)的image")
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
                                    print("儲存\(theMonsterName)的image")
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
    func setItemQuantity(){
        howManyLeft.text="數量剩餘:\(itemQuantity)"
    }
    func setMonsterHP(theNode:SKNode){
        var hp:Int=(theNode.userData?.objectForKey("monsterBlood")?.integerValue)!
        let hpMax:Int=(theNode.userData?.objectForKey("monsterBloodLimit")?.integerValue)!
        let enrichBlood:Int=(userData?.objectForKey("enrichBlood")?.integerValue)!
        
        hp=hp+enrichBlood
        if hp > hpMax{
            hp=hpMax
        }
        theNode.userData?.setObject(hp, forKey: "monsterBlood")
        let monsterHp=monsterName.childNodeWithName("hp") as! SKLabelNode
        monsterHp.text="HP \(hp)/\(hpMax)"
        
        
    }
    func setMonsterInfo(theNodeName:String){
        let hp:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("monsterBlood")?.integerValue)!
        let hpMax:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("monsterBloodLimit")?.integerValue)!
        let monsterHp=monsterName.childNodeWithName("hp") as! SKLabelNode

        monsterHp.text="HP \(hp)/\(hpMax)"
        monsterName.text=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("name") as? String
        //讀圖
        let thePicturePath=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("picturePath") as! String
        let theMonsterName=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("name") as! String
        for b in self.monsterImage{
            if b.name! == theMonsterName && b.picturePath! == thePicturePath{
                (monsterName.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: UIImage(data: b.picture!)!)
            }
        }
    }
    func whatUserUseDescription(textToShow:String){
        
        let charactersArray=Array(textToShow.characters)
        let totalLines=(charactersArray.count/7)+1
        var wordCount=0
        
        for i in 0..<totalLines{
            var linesLength=0
            var linesString:String=""
            while linesLength<7{
                if wordCount == charactersArray.count{
                    break
                }
                linesString=linesString+String(charactersArray[wordCount])
                linesLength=linesString.characters.count
                wordCount++
            }
            print(linesString)
            let blackBackgroundText=SKLabelNode(text: linesString)
            blackBackgroundText.name="text\(i)"
            blackBackgroundText.horizontalAlignmentMode = .Left
            blackBackgroundText.position=CGPoint(x: 154, y:491 - i * 20)
            blackBackgroundText.fontName="AvenirNext-Bold"
            blackBackgroundText.fontSize=18
            blackBackgroundText.zPosition=7
            blackBackgroundText.fontColor=UIColor(red: 0.33, green: 0.33, blue: 0.33, alpha: 1)
            self.addChild(blackBackgroundText)
        }
    }
}
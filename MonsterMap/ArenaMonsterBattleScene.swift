//
//  ArenaMonsterBattleScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/1/25.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import SpriteKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import CoreData

class ArenaMonsterBattleScene: SKScene {

    var battleEscapeButton:SKSpriteNode!
    var skillNodeBackground:SKSpriteNode!
    var skill1Node:SKSpriteNode!
    var skill2Node:SKSpriteNode!
    var skill3Node:SKSpriteNode!
    var itemNodeBackground:SKSpriteNode!
    var changeMonsterNodeBackground:SKSpriteNode!
    var statusEnemyFrameNode:SKSpriteNode!
    var touchBeganLocation:CGPoint!
    var monsterItemNode:SKSpriteNode!
    var itemItemNode:SKSpriteNode!
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    var monsterCount:Int!
    var itemCount:Int!
    var monsterNameToDetectRepeat:[String]=["name"]
    let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext:NSManagedObjectContext!
    var monsterImage:[MonsterImage] = []
    var monsterButtonImage:[MonsterButtonImage] = []
    var monsterSkill1Image:[MonsterSkill1Image]=[]
    var monsterSkill2Image:[MonsterSkill2Image]=[]
    var monsterSkill3Image:[MonsterSkill3Image]=[]
    var monsterSkill1ButtonImage:[MonsterSkill1ButtonImage]=[]
    var monsterSkill2ButtonImage:[MonsterSkill2ButtonImage]=[]
    var monsterSkill3ButtonImage:[MonsterSkill3ButtonImage]=[]
    var itemButtonImage:[ItemButtonImage]=[]
    var itemImage:[ItemImage]=[]
    var statusUserFrameNode:SKSpriteNode!
    var userFightMonsterNodeName:String!
    var enemyFightMonsterNodeName:String="enemyMonsterID1"
    var userMonsterStatusCount=0
    var enemyMonsterStatusCount=0
    var enemyTotalMonsterCount=0
    var enemyTakeDamage:Int=0
    var userChangeDefense:Int=0
    var enemyChangeDefense:Int=0
    var userMonsterBePause:Int=0
    var enemyMonsterBePause:Int=0
    var userChangeBasicDamage:Int=0
    var enemyChangeBasicDamage:Int=0
    var userChangeSpeed:Int=0
    var enemyChangeSpeed:Int=0
//    var enemySkill1CD:Int=0
//    var enemySkill2CD:Int=0
//    var enemySkill3CD:Int=0
    var enemyLeftHP:Int=10
    var userCauseDamgeLabel:SKLabelNode!
    var enemyCauseDamgeLabel:SKLabelNode!
    var userHaveADeadMonster=false
    var buttonVoicePlayer:AVAudioPlayer!
    var skillVoicePlayer:AVAudioPlayer!
    override func didMoveToView(view: SKView) {
    
        managedObjectContext=appDelegate.managedObjectContext

        headers=["token":token]
        createBlackBackground("選擇出戰寵物")
        userCauseDamgeLabel=childNodeWithName("userCauseDamageLabel") as! SKLabelNode
        enemyCauseDamgeLabel=childNodeWithName("enemyCauseDamageLabel") as! SKLabelNode
        battleEscapeButton=childNodeWithName("battleEscapeButton") as! SKSpriteNode
            itemNodeBackground=childNodeWithName("itemBackground") as! SKSpriteNode
    changeMonsterNodeBackground=childNodeWithName("changeMonsterBackground") as! SKSpriteNode
        monsterItemNode=changeMonsterNodeBackground.childNodeWithName("monsterItem") as! SKSpriteNode
        itemItemNode=itemNodeBackground.childNodeWithName("itemItem") as! SKSpriteNode
        skillNodeBackground=childNodeWithName("skillBackground") as! SKSpriteNode
        skill1Node=skillNodeBackground.childNodeWithName("skillID1") as! SKSpriteNode
        skill2Node=skillNodeBackground.childNodeWithName("skillID2") as! SKSpriteNode
        skill3Node=skillNodeBackground.childNodeWithName("skillID3") as! SKSpriteNode
        statusUserFrameNode=childNodeWithName("statusUserFrame") as! SKSpriteNode
        statusUserFrameNode.userData=NSMutableDictionary()
        statusEnemyFrameNode=childNodeWithName("statusEnemyFrame") as! SKSpriteNode
        statusUserFrameNode.childNodeWithName("image")?.xScale = -1
        
        alamoRequset(BirdGameSetting.URL.MyMonsterForFighting.rawValue){ (inner) -> Void in
            do{
                let result=try inner()
                var monsterPositionColumn=0
                var itemPositionColumn=0
                let resultMonster=result["monsters"].arrayObject as! [[String:AnyObject]]
                let resultItem=result["items"].arrayObject as! [[String:AnyObject]]
                self.itemCount=resultItem.count
                self.monsterCount=resultMonster.count
                self.userMonsterStatusCount=resultMonster.count
                for i in 0..<resultMonster.count {
                        let monster=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                        monster.name="monsterID\(i+1)"
                        monster.position=CGPoint(x: 0 + 100*monsterPositionColumn, y: 0)
                        self.monsterItemNode.addChild(monster)
                    self.setMonsterUserdata(monster, resultMonster: resultMonster,i: i)

                    monsterPositionColumn++
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["buttonPicturePath"]! as! String,thePictureType: "MonsterButtonImage")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["picturePath"]! as! String,thePictureType: "MonsterImage")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["damageCommonImage"]! as! String,thePictureType: "MonsterSkill1Image")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["damageCommon2Image"]! as! String,thePictureType: "MonsterSkill2Image")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["damageSpecialImage"]! as! String,thePictureType: "MonsterSkill3Image")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["buttonDamageCommonImage"]! as! String,thePictureType: "MonsterSkill1ButtonImage")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["buttonDamageCommon2Image"]! as! String,thePictureType: "MonsterSkill2ButtonImage")
                    self.somethingAboutImage(monster,thePicturePath: resultMonster[i]["buttonDamageSpecialImage"]! as! String,thePictureType: "MonsterSkill3ButtonImage")
                }
                for i in 0..<resultItem.count{
                    let item=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                    item.name="itemID\(i+1)"
                    item.position=CGPoint(x: 0 + 100*itemPositionColumn, y: 0)
                    self.itemItemNode.addChild(item)
                    item.userData=NSMutableDictionary()
                    item.userData?.setObject(resultItem[i]["itemName"]!, forKey: "itemName")
                    item.userData?.setObject(resultItem[i]["quantity"]!, forKey: "quantity")
                    let itemQuantity=SKLabelNode(text: resultItem[i]["quantity"]?.stringValue)
                    itemQuantity.name="quantity"
                    itemQuantity.fontSize=18
                    itemQuantity.fontName="AvenirNext-Bold"
                    itemQuantity.fontColor=UIColor(red: 1, green: 0, blue: 1, alpha: 1)
                    itemQuantity.horizontalAlignmentMode = .Right
                    item.addChild(itemQuantity)
                    itemQuantity.position=CGPointMake(35, -34)
                    
                    let picturePath:String=resultItem[i]["picturePath"]! as! String
                    let buttonPicturePath:String=resultItem[i]["buttonPicturePath"]! as! String
                    item.userData?.setObject(picturePath, forKey: "picturePath")
                    item.userData?.setObject(buttonPicturePath, forKey: "buttonPicturePath")
                    self.somethingAboutImage(item,thePicturePath: buttonPicturePath,thePictureType: "ItemButtonImage")
                    self.somethingAboutImage(item,thePicturePath: picturePath,thePictureType: "ItemImage")
                    itemPositionColumn++
                }
            }catch let error{
                print(error)
            }
        }
        alamoRequsetUpdate(BirdGameSetting.URL.PracticeWithSomeoneKnow.rawValue,parameter: ["userId":(userData?.objectForKey("id")?.stringValue)!]) { (inner) -> Void in
            do{
                let result=try inner()
                self.enemyMonsterStatusCount=result.count
                self.enemyTotalMonsterCount=result.count
                for i in 0..<result.count{
                    
                        let monster=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 0, height: 0))
                        monster.name="enemyMonsterID\(i+1)"
                        self.statusEnemyFrameNode.addChild(monster)
                        self.setMonsterUserdata(monster, resultMonster: result, i: i)
                    
                    self.somethingAboutImage(monster,thePicturePath: result[i]["picturePath"]! as! String,thePictureType: "MonsterImage")
                        self.somethingAboutImage(monster,thePicturePath: result[i]["damageCommonImage"]! as! String,thePictureType: "MonsterSkill1Image")
                        self.somethingAboutImage(monster,thePicturePath: result[i]["damageCommon2Image"]! as! String,thePictureType: "MonsterSkill2Image")
                        self.somethingAboutImage(monster,thePicturePath: result[i]["damageSpecialImage"]! as! String,thePictureType: "MonsterSkill3Image")
                }
                self.setEnemyMonsterInfo(self.statusEnemyFrameNode.childNodeWithName("enemyMonsterID1")!, parentNode: self.statusEnemyFrameNode)
            }catch let error{
                print(error)
            }
        }

        skillNodeBackground.hidden=true
        itemNodeBackground.hidden=true
        statusUserFrameNode.hidden=true
        statusEnemyFrameNode.hidden=true
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let range=(location?.x)!-touchBeganLocation.x
        
        var itemFrameMoveRange = 0 + (monsterItemNode.childNodeWithName("monsterID\(monsterCount)")?.position.x)! - 2 * monsterItemNode.frame.width
        var changePositionValue=itemFrameMoveRange / CGFloat(monsterCount) / 3
        var itemFrameNode=monsterItemNode
        if itemNodeBackground.hidden==false{
            itemFrameNode=itemItemNode
            itemFrameMoveRange = 0 + (itemItemNode.childNodeWithName("itemID\(itemCount)")?.position.x)! - 2 * itemItemNode.frame.width
            changePositionValue=itemFrameMoveRange / CGFloat(itemCount) / 3
        }
        if changeMonsterNodeBackground.containsPoint(touchBeganLocation){
            if range > 0{
                if itemFrameNode.position.x < -100{
                    itemFrameNode.position.x += changePositionValue
                }else{
                    itemFrameNode.position.x = -100
                }
            }
            if range < 0{
                if itemFrameNode.position.x > -100-itemFrameMoveRange{
                    itemFrameNode.position.x -= changePositionValue
                }
            }
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchBeganLocation=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(touchBeganLocation)
        let nodeTouchedName=nodeTouched.name
        let locationInMonsterItemNode=touches.first?.locationInNode(monsterItemNode)
        let locationInSkillBackgroundNode=touches.first?.locationInNode(skillNodeBackground)
        let locationInItemBackgroundNode=touches.first?.locationInNode(itemItemNode)
        if nodeTouchedName == "battleEscapeButton"{
            makeSomeButtonNoise()
        }else if nodeTouchedName == "battleChangeMonsterButton"{
            makeSomeButtonNoise()
        }else if nodeTouchedName == "battleSkillButton"{
            makeSomeButtonNoise()
        }else if nodeTouchedName == "battleItemButton"{
            makeSomeButtonNoise()
        }else if nodeTouchedName == "winExitButton"{
            makeSomeButtonNoise()
        }else if nodeTouchedName=="loseExitButton"{
            makeSomeButtonNoise()
        }else if nodeTouchedName == "changeMonsterFrame"{
            for a:SKNode in monsterItemNode.children{
                if (a.name!.hasPrefix("monsterID")){
                    if a.containsPoint(locationInMonsterItemNode!){
                        makeSomeButtonNoise()
                        break
                    }
                }
            }
        }else if nodeTouchedName == "skillFrame"{
            for a:SKNode in skillNodeBackground.children{
                if (a.name!.hasPrefix("skillID")){
                    if a.containsPoint(locationInSkillBackgroundNode!){
                        makeSomeButtonNoise()
                        break
                    }
                }
            }
        }else if nodeTouchedName == "blackBackground"{
            randomChangeBlackBackgroundText()
        }else if nodeTouchedName == "itemFrame"{
            for a in itemItemNode.children{
                if a.containsPoint(locationInItemBackgroundNode!){
                    makeSomeButtonNoise()
                    break
                }
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        print(nodeTouchedName)
        let locationInMonsterItemNode=touches.first?.locationInNode(monsterItemNode)
        let locationInSkillBackgroundNode=touches.first?.locationInNode(skillNodeBackground)
//        let locationInItemBackgroundNode=touches.first?.locationInNode(itemItemNode)
        if touchBeganLocation==location{
        if nodeTouchedName == "battleEscapeButton"{
            if (userData?.objectForKey("arenaType") as! String) == "arena"{
                alamoRequsetUpdate(BirdGameSetting.URL.ArenaGameOver.rawValue, parameter: ["opponentId":(userData?.objectForKey("id")?.stringValue)!,"winOrNot":"0"], completion: { (inner) -> Void in
                })
            }
//            reportUserMonsterHP()
//            view?.removeFromSuperview()
            whereToGo()
        }else if nodeTouchedName == "battleChangeMonsterButton"{
            if changeMonsterNodeBackground.hidden == true{
                changeMonsterNodeBackground.hidden=false
                skillNodeBackground.hidden=true
                itemNodeBackground.hidden=true
            }else{
                changeMonsterNodeBackground.hidden=true
            }
        }else if nodeTouchedName == "battleSkillButton"{
            if skillNodeBackground.hidden==true{
                skillNodeBackground.hidden=false
                changeMonsterNodeBackground.hidden=true
                itemNodeBackground.hidden=true
            }else{
                skillNodeBackground.hidden=true
            }
        }else if nodeTouchedName == "battleItemButton"{
            if itemNodeBackground.hidden==true{
                itemNodeBackground.hidden=false
                changeMonsterNodeBackground.hidden=true
                skillNodeBackground.hidden=true
            }else{
                itemNodeBackground.hidden=true
            }
        }else if nodeTouchedName == "changeMonsterFrame"{
            userTouchedChangeMonsterFrame(locationInMonsterItemNode!)
        }else if nodeTouchedName == "skillFrame"{
            userTouchedSkillFrame(locationInSkillBackgroundNode!)
        }else if nodeTouchedName == "blackBackground"{
//            randomChangeBlackBackgroundText()
        }else if nodeTouchedName == "itemFrame"{
//            userTouchedItemFrame(locationInItemBackgroundNode!)
        }else if nodeTouchedName == "winExitButton"{
//            view?.removeFromSuperview()
            whereToGo()
        }else if nodeTouchedName=="loseExitButton"{
//            view?.removeFromSuperview()
            whereToGo()
            }
        }
    }
    
    func alamoRequset(URL:String,completion: (inner: () throws -> JSON) -> Void) -> Void {
        Alamofire.request(.POST, URL, headers: headers).responseJSON { (response) -> Void in
            let swiftyJsonVar=JSON(response.result.value!)
            let jsonResult=swiftyJsonVar["result"]
                completion(inner: {return jsonResult})
            
        }
    }
    func alamoRequset2(URL:String,completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
        Alamofire.request(.POST, URL, headers: headers).responseJSON { (response) -> Void in
            let swiftyJsonVar=JSON(response.result.value!)
            if let jsonResult=swiftyJsonVar["result"].arrayObject{
                let monsterJSON=jsonResult as! [[String:AnyObject]]
                completion(inner: {return monsterJSON})
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
//    func setEnemyUserInfo(monsterNode:SKNode,parentNode:SKSpriteNode){
//        let level:Int=(monsterNode.userData?.objectForKey("level")?.integerValue)!
//        let hpBase:Int=(monsterNode.userData?.objectForKey("hp")?.integerValue)!
//        let hpUp:Int=(monsterNode.userData?.objectForKey("hpLevelUp")?.integerValue)!
//        let hp:Int=hpBase+level*hpUp
//        let nameLabel=parentNode.childNodeWithName("name") as! SKLabelNode
//        let levelLabel=parentNode.childNodeWithName("level") as! SKLabelNode
//        let hpLabel=parentNode.childNodeWithName("hp") as! SKLabelNode
//        let imageNode=parentNode.childNodeWithName("image") as!SKSpriteNode
//        nameLabel.text=monsterNode.userData?.objectForKey("name")! as? String
//        levelLabel.text="LV  \(level)"
//        hpLabel.text="HP：\(hp)/\(hp)"
//        imageNode.texture=SKTexture(image: UIImage(data: userData?.objectForKey("image") as! NSData)!)
//        
//        parentNode.hidden=false
//
//    }
    func setEnemyMonsterInfo(monsterNode:SKNode,parentNode:SKSpriteNode){
        let level:Int=(monsterNode.userData?.objectForKey("level")?.integerValue)!
        let hpBase:Int=(monsterNode.userData?.objectForKey("hp")?.integerValue)!
        let hpUp:Int=(monsterNode.userData?.objectForKey("hpLevelUp")?.integerValue)!
        let hp:Int=hpBase+level*hpUp
        let nameLabel=parentNode.childNodeWithName("name") as! SKLabelNode
        let levelLabel=parentNode.childNodeWithName("level") as! SKLabelNode
        let hpLabel=parentNode.childNodeWithName("hp") as! SKLabelNode
        let imageNode=parentNode.childNodeWithName("image") as!SKSpriteNode
        nameLabel.text=monsterNode.userData?.objectForKey("name")! as? String
        levelLabel.text="LV  \(level)"
        hpLabel.text="HP \(hp)/\(hp)"
        for a in monsterImage{
            if a.name! == monsterNode.userData?.objectForKey("name") as! String{
                imageNode.texture=SKTexture(image: UIImage(data: a.picture!)!)
                break
            }
        }
        parentNode.hidden=false
    }
    func setUserMonsterInfo(monsterNode:SKNode,parentNode:SKSpriteNode){
        let nameLabel=parentNode.childNodeWithName("name") as! SKLabelNode
        let levelLabel=parentNode.childNodeWithName("level") as! SKLabelNode
        let hpLabel=parentNode.childNodeWithName("hp") as! SKLabelNode
        let imageNode=parentNode.childNodeWithName("image") as!SKSpriteNode
        nameLabel.text=monsterNode.userData?.objectForKey("name")! as? String
        levelLabel.text="LV  \((monsterNode.userData?.objectForKey("level")?.stringValue)!)"
        hpLabel.text="HP \((monsterNode.userData?.objectForKey("monsterBlood")?.stringValue)!)/\((monsterNode.userData?.objectForKey("monsterBloodLimit")?.stringValue)!)"
        for a in monsterImage{
            if a.name! == monsterNode.userData?.objectForKey("name") as! String{
                imageNode.texture=SKTexture(image: UIImage(data: a.picture!)!)
                break
            }
        }
        for a in monsterSkill1ButtonImage{
            if a.name! == monsterNode.userData?.objectForKey("name") as! String{
                skill1Node.texture=SKTexture(image: UIImage(data: a.picture!)!)
                break
            }
        }
        for a in monsterSkill2ButtonImage{
            if a.name! == monsterNode.userData?.objectForKey("name") as! String{
                skill2Node.texture=SKTexture(image: UIImage(data: a.picture!)!)
                break
            }
        }
        for a in monsterSkill3ButtonImage{
            if a.name! == monsterNode.userData?.objectForKey("name") as! String{
                skill3Node.texture=SKTexture(image: UIImage(data: a.picture!)!)
                break
            }
        }
        parentNode.userData?.setObject((monsterNode.userData?.objectForKey("id"))!, forKey: "id")
        parentNode.hidden=false
        changeMonsterNodeBackground.hidden=true
    }
    func setEnemyMonsterInfoHP(hp:Int,maxhp:Int){
        let hpLabel=statusEnemyFrameNode.childNodeWithName("hp") as! SKLabelNode
        hpLabel.text="HP \(hp)/\(maxhp)"
    }
    func setUserMonsterInfoHP(hp:Int,maxhp:Int){
        let hpLabel=statusUserFrameNode.childNodeWithName("hp") as! SKLabelNode
        hpLabel.text="HP \(hp)/\(maxhp)"
    }
    func somethingAboutImage(theNode:SKSpriteNode,thePicturePath:String,thePictureType:String){
        let moc=self.managedObjectContext
        let monsterImageFetch=NSFetchRequest(entityName: thePictureType)
        var fetchError:NSError?=nil
        var coredataHasImage=false
        var theMonsterName=""
        if theNode.name!.hasPrefix("monster"){
            theMonsterName=theNode.userData?.objectForKey("name") as! String
        }else if theNode.name!.hasPrefix("enemy"){
            theMonsterName=theNode.userData?.objectForKey("name") as! String
        }else{
            theMonsterName=theNode.userData?.objectForKey("itemName") as! String
        }
        do{
            let fetchCount=moc.countForFetchRequest(monsterImageFetch, error: &fetchError)
            if fetchCount>0{
                switch thePictureType {
                case "MonsterImage":
                    self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
                    for b in self.monsterImage{
                        if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                            moc.deleteObject(b)
                            do{
                                print("delete \(b.name) picture")
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
                case "MonsterSkill1Image":
                    self.monsterSkill1Image=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill1Image]
                    for b in self.monsterSkill1Image{
                        //delete image
                        if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                            moc.deleteObject(b)
                            do{
                                print("delete \(b.name) picture")
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
                case "MonsterSkill1ButtonImage":
                    self.monsterSkill1ButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill1ButtonImage]
                    for b in self.monsterSkill1ButtonImage{
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
                case "MonsterSkill2Image":
                    self.monsterSkill2Image=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill2Image]
                    for b in self.monsterSkill2Image{
                        //delete image
                        if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                            moc.deleteObject(b)
                            do{
                                print("delete \(b.name) picture")
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
                case "MonsterSkill2ButtonImage":
                    self.monsterSkill2ButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill2ButtonImage]
                    for b in self.monsterSkill2ButtonImage{
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
                case "MonsterSkill3Image":
                    self.monsterSkill3Image=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill3Image]
                    for b in self.monsterSkill3Image{
                        //delete image
                        if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                            moc.deleteObject(b)
                            do{
                                print("delete \(b.name) picture")
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
                case "MonsterSkill3ButtonImage":
                    self.monsterSkill3ButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill3ButtonImage]
                    for b in self.monsterSkill3ButtonImage{
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
                case "ItemImage":
                    self.itemImage=try moc.executeFetchRequest(monsterImageFetch) as! [ItemImage]
                    for b in self.itemImage{
                        if b.name! == theMonsterName && b.picturePath! != thePicturePath{
                            moc.deleteObject(b)
                            do{
                                print("delete \(b.name) picture")
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
                case "ItemButtonImage":
                    self.itemButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [ItemButtonImage]
                    for b in self.itemButtonImage{
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
                        if thePictureType == "MonsterButtonImage" || thePictureType == "ItemButtonImage"{
                            theNode.texture=SKTexture(image: image)
                        }
                        if theNode.name!=="enemyMonsterID1" && thePictureType=="MonsterImage"{
                            (self.statusEnemyFrameNode.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: image)
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
                            case "MonsterSkill1Image":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterSkill1Image
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.monsterSkill1Image=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill1Image]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "MonsterSkill1ButtonImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterSkill1ButtonImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.monsterSkill1ButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill1ButtonImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "MonsterSkill2Image":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterSkill2Image
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.monsterSkill2Image=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill2Image]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "MonsterSkill2ButtonImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterSkill2ButtonImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.monsterSkill2ButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill2ButtonImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "MonsterSkill3Image":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterSkill3Image
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.monsterSkill3Image=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill3Image]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "MonsterSkill3ButtonImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! MonsterSkill3ButtonImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.monsterSkill3ButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterSkill3ButtonImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "ItemImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! ItemImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.itemImage=try moc.executeFetchRequest(monsterImageFetch) as! [ItemImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                }
                                break
                            case "ItemButtonImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! ItemButtonImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.itemButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [ItemButtonImage]
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
    
    func fight(userMonsterSkillNumber:Int,enemyMonsterSkillNumber:Int){
        for a in monsterItemNode.children{
            a.userData?.setObject((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill1CD")?.integerValue)!-1, forKey: "skill1CD")
            a.userData?.setObject((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill2CD")?.integerValue)!-1, forKey: "skill2CD")
            a.userData?.setObject((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill3CD")?.integerValue)!-1, forKey: "skill3CD")
        }
        for a in statusEnemyFrameNode.children{
            if a.name!.hasPrefix("enemyMonsterID"){
            a.userData?.setObject((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill1CD")?.integerValue)!-1, forKey: "skill1CD")
            a.userData?.setObject((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill2CD")?.integerValue)!-1, forKey: "skill2CD")
            a.userData?.setObject((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill3CD")?.integerValue)!-1, forKey: "skill3CD")
            }
        }

        skillNodeBackground.hidden=true
        let userTypeRatio:Float!
        let enemyTypeRatio:Float!
        let userMonsterName:String=monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("name") as! String
        let enemyMonsterName:String=statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("name") as! String
        //level
        let userMonsterLevel:Float=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("level")?.floatValue)!
        let enemyMonsterLevel:Float=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("level")?.floatValue)!
        //type
        let userMonsterType:String=monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("type") as! String
        let enemyMonsterType:String=statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("type") as! String
        //hp
        let userMonsterHP:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("monsterBlood")?.integerValue)!
        let userMonsterMaxHP:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("monsterBloodLimit")?.integerValue)!
        let enemyMonsterHPBase:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("hp")?.integerValue)!
        let enemyMonsterHPUp:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("hpLevelUp")?.integerValue)!
        let enemyMonsterHP:Int=Int(enemyMonsterLevel) * enemyMonsterHPUp + enemyMonsterHPBase - enemyTakeDamage
        let enemyMonsterMaxHP:Int=Int(enemyMonsterLevel) * enemyMonsterHPUp + enemyMonsterHPBase
        //defense

        let userMonsterDefenseBase:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("defense")?.integerValue)!
        let userMonsterDefenseUp:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("defenseLevelUp")?.integerValue)!
        let userMonsterDefense:Float=Float(Int(userMonsterLevel) * userMonsterDefenseUp + userMonsterDefenseBase + userChangeDefense)

        let enemyMonsterDefenseBase:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("defense")?.integerValue)!
        let enemyMonsterDefenseUp:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("defenseLevelUp")?.integerValue)!
        let enemyMonsterDefense:Float=Float(Int(enemyMonsterLevel) * enemyMonsterDefenseUp + enemyMonsterDefenseBase + enemyChangeDefense)
        userChangeDefense=0
        enemyChangeDefense=0
        //basicdamage
        let userMonsterBasicDamageBase:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("basicDamage")?.integerValue)!
        let userMonsterBasicDamageUp:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("basicDamageLevelUp")?.integerValue)!
        let userMonsterBasicDamage:Float=Float(Int(userMonsterLevel) * userMonsterBasicDamageUp + userMonsterBasicDamageBase + userChangeBasicDamage)
        let enemyMonsterBasicDamageBase:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("basicDamage")?.integerValue)!
        let enemyMonsterBasicDamageUp:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("basicDamageLevelUp")?.integerValue)!
        let enemyMonsterBasicDamage:Float=Float(Int(enemyMonsterLevel) * enemyMonsterBasicDamageUp + enemyMonsterBasicDamageBase + enemyChangeBasicDamage)
        userChangeBasicDamage=0
        enemyChangeBasicDamage=0
        //speed
        let userMonsterSpeedBase:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("speed")?.integerValue)!
        let userMonsterSpeedUp:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("speedLevelUp")?.integerValue)!
        let userMonsterSpeed:Float=Float(Int(userMonsterLevel) * userMonsterSpeedUp + userMonsterSpeedBase + userChangeSpeed)
        let enemyMonsterSpeedBase:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("speed")?.integerValue)!
        let enemyMonsterSpeedUp:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("speedLevelUp")?.integerValue)!
        let enemyMonsterSpeed:Float=Float(Int(enemyMonsterLevel) * enemyMonsterSpeedUp + enemyMonsterSpeedBase + enemyChangeSpeed)
        userChangeSpeed=0
        enemyChangeSpeed=0
        //cd
        let userMonsterSkill1CD:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCD1")?.integerValue)!
        let userMonsterSkill2CD:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCD2")?.integerValue)!
        let userMonsterSkill3CD:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCD3")?.integerValue)!
        let enemyMonsterSkill1CD:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCD1")?.integerValue)!
        let enemyMonsterSkill2CD:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCD2")?.integerValue)!
        let enemyMonsterSkill3CD:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCD3")?.integerValue)!
        
        //屬性相剋
        if (userMonsterType=="火" && enemyMonsterType=="風") || (userMonsterType=="風" && enemyMonsterType=="地") || (userMonsterType=="地" && enemyMonsterType=="水") || (userMonsterType=="水" && enemyMonsterType=="火"){
            userTypeRatio=1.1
            enemyTypeRatio=0.9
        }else if (enemyMonsterType=="火" && userMonsterType=="風") || (enemyMonsterType=="風" && userMonsterType=="地") || (enemyMonsterType=="地" && userMonsterType=="水") || (enemyMonsterType=="水" && userMonsterType=="火"){
            userTypeRatio=0.9
            enemyTypeRatio=1.1
        }else{
            userTypeRatio=1
            enemyTypeRatio=1
        }
        let userMonsterSkillType:String=monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageType\(userMonsterSkillNumber)") as! String
        let enemyMonsterSkillType:String=statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageType\(enemyMonsterSkillNumber)") as! String
//        let userMonsterCauseDamage:Int!
//        let skillEffectRatio:Float!
//        let skillDamageRatio:Float!
        //user use skill
        let runUserUseSkill=SKAction.runBlock { () -> Void in
            if !(self.userMonsterBePause > 0) && self.monsterItemNode.childNodeWithName(self.userFightMonsterNodeName)?.userData?.objectForKey("monsterBlood")?.integerValue > 0{
            self.userUseSkill(userMonsterName,monsterSkillType:userMonsterSkillType, monsterSkillNumber: userMonsterSkillNumber, userMonsterLevel: userMonsterLevel, userTypeRatio: userTypeRatio, userMonsterHP: userMonsterHP, userMonsterMaxHP: userMonsterMaxHP, userMonsterBasicDamage: userMonsterBasicDamage, userMonsterDefense: userMonsterDefense,userMonsterSpeed:userMonsterSpeed , enemyMonsterHP: enemyMonsterHP, enemyMonsterMaxHP: enemyMonsterMaxHP, enemyMonsterDefense: enemyMonsterDefense,enemyMonsterSpeed:enemyMonsterSpeed,enemyMonsterBasicDamage:enemyMonsterBasicDamage  )
                let emitter=SKEmitterNode(fileNamed: "PresentUserSkillParticle")
                emitter?.name="userEmitter"
                emitter?.position=CGPoint(x: self.statusUserFrameNode.position.x+(self.statusUserFrameNode.frame.width/2), y: self.statusUserFrameNode.position.y+self.statusUserFrameNode.frame.height*3/2)
                emitter?.particleSize=CGSize(width: 100, height: 100)
            switch userMonsterSkillNumber{
            case 1:
                for b in self.monsterSkill1Image{
                    if b.name == (self.statusUserFrameNode.childNodeWithName("name") as! SKLabelNode).text{
                        emitter?.particleTexture=SKTexture(image: UIImage(data: b.picture!)!)
                        break
                    }
                }
                self.monsterItemNode.childNodeWithName(self.userFightMonsterNodeName)?.userData?.setObject(userMonsterSkill1CD, forKey: "skill1CD")
                break
            case 2:
                for b in self.monsterSkill2Image{
                    if b.name == (self.statusUserFrameNode.childNodeWithName("name") as! SKLabelNode).text{
                        emitter?.particleTexture=SKTexture(image: UIImage(data: b.picture!)!)
                        break
                    }
                }
                self.monsterItemNode.childNodeWithName(self.userFightMonsterNodeName)?.userData?.setObject(userMonsterSkill2CD, forKey: "skill2CD")
                break
            case 3:
                for b in self.monsterSkill3Image{
                    if b.name == (self.statusUserFrameNode.childNodeWithName("name") as! SKLabelNode).text{
                        emitter?.particleTexture=SKTexture(image: UIImage(data: b.picture!)!)
                        break
                    }
                }
                self.monsterItemNode.childNodeWithName(self.userFightMonsterNodeName)?.userData?.setObject(userMonsterSkill3CD, forKey: "skill3CD")
                break
            default:
                break
            }
                self.addChild(emitter!)
                switch userMonsterType{
                case "水":
                    self.makeSomeWaterNoise()
                    break
                case "火":
                    self.makeSomeFireNoise()
                    break
                case "風":
                    self.makeSomeWindNoise()
                    break
                case "地":
                    self.makeSomeEarthNoise()
                    break
                default:
                    break
                }
            }else{
                self.userCauseDamgeLabel.text=""
                self.userMonsterBePause=0
            }
        }
        let runEnemyUseSkill=SKAction.runBlock{ () -> Void in
            if !(self.enemyMonsterBePause > 0) && self.enemyLeftHP > 0{
                self.enemyUseSkill(enemyMonsterName,monsterSkillType:enemyMonsterSkillType, monsterSkillNumber: enemyMonsterSkillNumber, enemyMonsterLevel: enemyMonsterLevel, enemyTypeRatio: enemyTypeRatio, enemyMonsterHP: enemyMonsterHP, enemyMonsterMaxHP: enemyMonsterMaxHP, enemyMonsterBasicDamage: enemyMonsterBasicDamage, enemyMonsterDefense: enemyMonsterDefense, enemyMonsterSpeed: enemyMonsterSpeed, userMonsterHP: userMonsterHP, userMonsterMaxHP: userMonsterMaxHP, userMonsterDefense: userMonsterDefense, userMonsterSpeed: userMonsterSpeed, userMonsterBasicDamage: userMonsterBasicDamage)
                let emitter=SKEmitterNode(fileNamed: "PresentEnemySkillParticle")
                emitter?.name="enemyEmitter"
                emitter?.position=CGPoint(x: self.statusEnemyFrameNode.position.x-(self.statusEnemyFrameNode.frame.width/2), y: self.statusEnemyFrameNode.position.y+self.statusEnemyFrameNode.frame.height)
                emitter?.particleSize=CGSize(width: 100, height: 100)
            switch enemyMonsterSkillNumber{
            case 1:
                for b in self.monsterSkill1Image{
                    if b.name == (self.statusEnemyFrameNode.childNodeWithName("name") as! SKLabelNode).text{
                        emitter?.particleTexture=SKTexture(image: UIImage(data: b.picture!)!)
                        break
                    }
                }
                self.statusEnemyFrameNode.childNodeWithName(self.enemyFightMonsterNodeName)?.userData?.setObject(enemyMonsterSkill1CD, forKey: "skill1CD")
                break
            case 2:
                for b in self.monsterSkill2Image{
                    if b.name == (self.statusEnemyFrameNode.childNodeWithName("name") as! SKLabelNode).text{
                        emitter?.particleTexture=SKTexture(image: UIImage(data: b.picture!)!)
                        break
                    }
                }
                self.statusEnemyFrameNode.childNodeWithName(self.enemyFightMonsterNodeName)?.userData?.setObject(enemyMonsterSkill2CD, forKey: "skill2CD")
                break
            case 3:
                for b in self.monsterSkill3Image{
                    if b.name == (self.statusEnemyFrameNode.childNodeWithName("name") as! SKLabelNode).text{
                        emitter?.particleTexture=SKTexture(image: UIImage(data: b.picture!)!)
                        break
                    }
                }
                self.statusEnemyFrameNode.childNodeWithName(self.enemyFightMonsterNodeName)?.userData?.setObject(enemyMonsterSkill3CD, forKey: "skill3CD")
                break
            default:
                break
            }
                self.addChild(emitter!)
                switch enemyMonsterType{
                case "水":
                    self.makeSomeWaterNoise()
                    break
                case "火":
                    self.makeSomeFireNoise()
                    break
                case "風":
                    self.makeSomeWindNoise()
                    break
                case "地":
                    self.makeSomeEarthNoise()
                    break
                default:
                    break
                }
            }else{
                self.enemyCauseDamgeLabel.text=""
                self.enemyMonsterBePause=0
            }
        }
        let runCreateClearBackground=SKAction.runBlock { () -> Void in
            self.createClearBackground()
        }
        let runRemove=SKAction.runBlock { () -> Void in
            self.removeClearBackground()
            for a in self.children{
                if a.name!.hasSuffix("Emitter"){
                    a.removeFromParent()
                }
            }
            self.skillVoicePlayer.stop()
            //避免後面怪物不會攻擊
            if self.enemyLeftHP<0{
                self.enemyLeftHP=10
            }
        }
        let waitDuration1=SKAction.waitForDuration(1)
        let waitDuration3half=SKAction.waitForDuration(1.5)
        if userMonsterSpeed >= enemyMonsterSpeed{
            runAction(SKAction.sequence([runCreateClearBackground,waitDuration1,runUserUseSkill,waitDuration3half,runEnemyUseSkill,waitDuration3half,runRemove]))
        }else{
            runAction(SKAction.sequence([runCreateClearBackground,waitDuration1,runEnemyUseSkill,waitDuration3half,runUserUseSkill,waitDuration3half,runRemove]))
        }
        
    }
    func userUseSkill(monsterName:String,monsterSkillType:String,monsterSkillNumber:Int,userMonsterLevel:Float,userTypeRatio:Float,var userMonsterHP:Int,userMonsterMaxHP:Int,userMonsterBasicDamage:Float,userMonsterDefense:Float,userMonsterSpeed:Float, enemyMonsterHP:Int,enemyMonsterMaxHP:Int,enemyMonsterDefense:Float,enemyMonsterSpeed:Float,enemyMonsterBasicDamage:Float){
        var userMonsterCauseDamage:Float!
        let skillEffectRatio:Float!
        let skillDamageRatio:Float!
        switch monsterSkillType {
        case "reduceDefense\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("reduceDefense\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，降低對方\(Int(skillEffectRatio*100))％防禦"
            if enemyLeftHP <= 0{
                whenUserWin()
            }else if enemyLeftHP > 0{
                enemyChangeDefense = 0-Int(enemyMonsterDefense * skillEffectRatio)
            }
            break
        case "general\(monsterSkillNumber)":
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害"
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        case "pauseAttack\(monsterSkillNumber)":
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，使對方暫停一回合"
            if enemyLeftHP <= 0{
                whenUserWin()
            }else if enemyLeftHP > 0{
                enemyMonsterBePause=1
            }
            
            break
        case "bloodsuck\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("bloodsuck\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=Float(enemyMonsterHP) * skillEffectRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            //吸血
            userMonsterHP=userMonsterHP+Int(userMonsterCauseDamage)
            if userMonsterHP > userMonsterMaxHP{
                userMonsterHP=userMonsterMaxHP
            }
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，吸收同等血量"
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        case "selfBlew\(monsterSkillNumber)":
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("selfBlew\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=Float(userMonsterHP) * skillDamageRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            //自損
            userMonsterHP=userMonsterHP-Int(userMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage * userTypeRatio)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage * userTypeRatio))傷害，自損\(Int(userMonsterCauseDamage))％生命"
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        case "random\(monsterSkillNumber)":
            let randomLower:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("random\(monsterSkillNumber)Lower")?.integerValue)!
            let randomUpper:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("random\(monsterSkillNumber)Upper")?.integerValue)!
            let randomNumber:UInt32=UInt32(randomUpper-randomLower+1)
            let hits:Int=Int(arc4random_uniform(randomNumber))+randomLower
            
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * Float(hits) * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            
                enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
                enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
                setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
                if enemyLeftHP <= 0{
                    whenUserWin()
                }
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害"
            break
        case "batter\(monsterSkillNumber)":
            let hits:Int=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("batter\(monsterSkillNumber)")?.integerValue)!
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * Float(hits) * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
                enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
                enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
                setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害"
                if enemyLeftHP <= 0{
                    whenUserWin()
                }
            break
        case "enhanceAttack\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("enhanceAttack\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％攻擊"
            userChangeBasicDamage=0+Int(Float(userMonsterBasicDamage) * skillEffectRatio)
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        case "enhanceDefense\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("enhanceDefense\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％防禦"
            userChangeDefense=0+Int(userMonsterDefense * skillEffectRatio)
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        case "reduceAllAbility\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("reduceAllAbility\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，降低對方\(Int(skillEffectRatio*100))％全能力"
            if enemyLeftHP <= 0{
                whenUserWin()
            }else if enemyLeftHP > 0{
                enemyChangeDefense = 0-Int(enemyMonsterDefense * skillEffectRatio)
                enemyChangeSpeed = 0-Int(enemyMonsterSpeed * skillEffectRatio)
                enemyChangeBasicDamage = 0-Int(enemyMonsterBasicDamage * skillEffectRatio)
            }
            break
        case "enhanceAllAbility\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("enhanceAllAbility\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％全能力"
            userChangeSpeed=0+Int(userMonsterSpeed * skillEffectRatio)
            userChangeDefense=0+Int(userMonsterDefense * skillEffectRatio)
            userChangeBasicDamage=0+Int(userMonsterBasicDamage * skillEffectRatio)
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        case "recoveryHp\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("recoveryHp\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=Float(userMonsterMaxHP) * skillEffectRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP+Int(userMonsterCauseDamage)
            if userMonsterHP > userMonsterMaxHP{
                userMonsterHP=userMonsterMaxHP
            }
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)回復了\(Int(userMonsterCauseDamage))血"
            break
        case "reduceAttack\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("reduceAttack\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，降低對方\(Int(skillEffectRatio*100))％攻擊"
            if enemyLeftHP <= 0{
                whenUserWin()
            }else if enemyLeftHP > 0{
                enemyChangeBasicDamage = 0-Int(enemyMonsterBasicDamage * skillEffectRatio)
            }
            break
        case "reduceSpeed\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("reduceSpeed\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，降低對方\(Int(skillEffectRatio*100))％速度"
            if enemyLeftHP <= 0{
                whenUserWin()
            }else if enemyLeftHP > 0{
                enemyChangeSpeed = 0-Int(Float(enemyMonsterSpeed) * skillEffectRatio)
            }
            break
        case "enhanceSpeed\(monsterSkillNumber)":
            skillEffectRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("enhanceSpeed\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            userMonsterCauseDamage=userMonsterLevel * userMonsterBasicDamage / enemyMonsterDefense * skillDamageRatio * userTypeRatio
            if userMonsterCauseDamage<1 && userMonsterCauseDamage>0{
                userMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage+Int(userMonsterCauseDamage)
            enemyLeftHP=enemyMonsterMaxHP-enemyTakeDamage
            setEnemyMonsterInfoHP(enemyLeftHP, maxhp: enemyMonsterMaxHP)
            userCauseDamgeLabel.text="\(monsterName)造成了\(Int(userMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％速度"
            userChangeSpeed=0+Int(Float(userMonsterSpeed) * skillEffectRatio)
            if enemyLeftHP <= 0{
                whenUserWin()
            }
            break
        default:
            break
        }
    }
    func enemyUseSkill(monsterName:String,monsterSkillType:String,monsterSkillNumber:Int,enemyMonsterLevel:Float,enemyTypeRatio:Float,var enemyMonsterHP:Int,enemyMonsterMaxHP:Int,enemyMonsterBasicDamage:Float,enemyMonsterDefense:Float,enemyMonsterSpeed:Float,var userMonsterHP:Int,userMonsterMaxHP:Int,userMonsterDefense:Float,userMonsterSpeed:Float,userMonsterBasicDamage:Float){
        var enemyMonsterCauseDamage:Float!
        let skillEffectRatio:Float!
        let skillDamageRatio:Float!
        switch monsterSkillType {
        case "reduceDefense\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("reduceDefense\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，降低你\(Int(skillEffectRatio*100))％防禦"
            if userMonsterHP <= 0{
                whenUserLose()
            }else if userMonsterHP > 0{
                userChangeDefense = 0-Int(Float(userMonsterDefense) * skillEffectRatio)
            }
            break
        case "general\(monsterSkillNumber)":
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害"
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        case "pauseAttack\(monsterSkillNumber)":
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，讓你暫停一回合"
            if userMonsterHP <= 0{
                whenUserLose()
            }else if userMonsterHP > 0{
                userMonsterBePause++
            }
            break
        case "bloodsuck\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("bloodsuck\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=Float(userMonsterHP) * skillEffectRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            //吸血
            enemyTakeDamage=enemyTakeDamage-Int(enemyMonsterCauseDamage)
            if enemyTakeDamage<0{
                enemyTakeDamage=0
            }
            enemyMonsterHP=enemyMonsterHP+Int(enemyMonsterCauseDamage)
            if enemyMonsterHP > enemyMonsterMaxHP{
                enemyMonsterHP=enemyMonsterMaxHP
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            setEnemyMonsterInfoHP(enemyMonsterHP, maxhp: enemyMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，並吸取\(Int(enemyMonsterCauseDamage))血"
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        case "selfBlew\(monsterSkillNumber)":
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("selfBlew\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=Float(enemyMonsterHP) * skillDamageRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            //自損
            enemyTakeDamage=enemyTakeDamage+Int(enemyMonsterCauseDamage)
            enemyMonsterHP=enemyMonsterHP-Int(enemyMonsterCauseDamage)
            
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage * enemyTypeRatio)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            setEnemyMonsterInfoHP(enemyMonsterHP, maxhp: enemyMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage * enemyTypeRatio))傷害，自損\(Int(enemyMonsterCauseDamage))"
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        case "random\(monsterSkillNumber)":
            let randomLower:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("random\(monsterSkillNumber)Lower")?.integerValue)!
            let randomUpper:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("random\(monsterSkillNumber)Upper")?.integerValue)!
            let randomNumber:UInt32=UInt32(randomUpper-randomLower+1)
            let hits:Int=Int(arc4random_uniform(randomNumber))+randomLower
            
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * Float(hits) * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
                userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
                monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
                setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害"
                if userMonsterHP <= 0{
                    whenUserLose()
                    break
                }
            break
        case "batter\(monsterSkillNumber)":
            let hits:Int=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("batter\(monsterSkillNumber)")?.integerValue)!
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * Float(hits) * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
                userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
                monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
                setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害"
                if userMonsterHP <= 0{
                    whenUserLose()
                    break
                }
            break
        case "enhanceAttack\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("enhanceAttack\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％攻擊"
            enemyChangeBasicDamage=0+Int(Float(enemyMonsterBasicDamage) * skillEffectRatio)
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        case "enhanceDefense\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("enhanceDefense\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％防禦"
            enemyChangeDefense=0+Int(Float(enemyMonsterDefense) * skillEffectRatio)
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        case "reduceAllAbility\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("reduceAllAbility\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，降低你\(Int(skillEffectRatio*100))％全能力"
            if userMonsterHP <= 0{
                whenUserLose()
            }else if userMonsterHP > 0{
                userChangeDefense = 0-Int(Float(enemyMonsterDefense) * skillEffectRatio)
                userChangeSpeed = 0-Int(Float(enemyMonsterSpeed) * skillEffectRatio)
                userChangeBasicDamage = 0-Int(Float(enemyMonsterBasicDamage) * skillEffectRatio)
            }
            break
        case "enhanceAllAbility\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("enhanceAllAbility\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％全能力"
            enemyChangeSpeed=0+Int(Float(userMonsterSpeed) * skillEffectRatio)
            enemyChangeDefense=0+Int(Float(userMonsterDefense) * skillEffectRatio)
            enemyChangeBasicDamage=0+Int(Float(userMonsterBasicDamage) * skillEffectRatio)
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        case "recoveryHp\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("recoveryHp\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=Float(userMonsterMaxHP) * skillEffectRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            enemyTakeDamage=enemyTakeDamage-Int(enemyMonsterCauseDamage)
            if enemyTakeDamage<0{
                enemyTakeDamage=0
            }
            enemyMonsterHP=enemyMonsterHP+Int(enemyMonsterCauseDamage)
            if enemyMonsterHP > enemyMonsterMaxHP{
                enemyMonsterHP=enemyMonsterMaxHP
            }
            setEnemyMonsterInfoHP(enemyMonsterHP, maxhp: enemyMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)回復了\(Int(enemyMonsterCauseDamage))血"
            break
        case "reduceAttack\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("reduceAttack\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，降低你\(Int(skillEffectRatio*100))％攻擊"
            if userMonsterHP <= 0{
                whenUserLose()
            }else if userMonsterHP > 0{
                userChangeBasicDamage = 0-Int(Float(userMonsterBasicDamage) * skillEffectRatio)
            }
            break
        case "reduceSpeed\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("reduceSpeed\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，降低你\(Int(skillEffectRatio*100))％速度"
            if userMonsterHP <= 0{
                whenUserLose()
            }else if userMonsterHP > 0{
                userChangeSpeed = 0-Int(Float(userMonsterSpeed) * skillEffectRatio)
            }
            break
        case "enhanceSpeed\(monsterSkillNumber)":
            skillEffectRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("enhanceSpeed\(monsterSkillNumber)")?.floatValue)!/100
            skillDamageRatio=(statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("damageCommon\(monsterSkillNumber)")?.floatValue)!/100
            enemyMonsterCauseDamage=enemyMonsterLevel * enemyMonsterBasicDamage / userMonsterDefense * skillDamageRatio * enemyTypeRatio
            if enemyMonsterCauseDamage<1 && enemyMonsterCauseDamage>0{
                enemyMonsterCauseDamage=1
            }
            userMonsterHP=userMonsterHP-Int(enemyMonsterCauseDamage)
            monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(userMonsterHP, forKey: "monsterBlood")
            setUserMonsterInfoHP(userMonsterHP, maxhp: userMonsterMaxHP)
            enemyCauseDamgeLabel.text="\(monsterName)造成了\(Int(enemyMonsterCauseDamage))傷害，提升\(Int(skillEffectRatio*100))％速度"
            enemyChangeSpeed=0+Int(Float(enemyMonsterSpeed) * skillEffectRatio)
            if userMonsterHP <= 0{
                whenUserLose()
            }
            break
        default:
            break
        }
    }

    func setMonsterUserdata(monster:SKNode,resultMonster:[[String:AnyObject]],i:Int){
        monster.userData=NSMutableDictionary()
        monster.userData?.setObject(resultMonster[i]["name"]!, forKey: "name")
        monster.userData?.setObject(resultMonster[i]["speed"]!, forKey: "speed")
        monster.userData?.setObject(resultMonster[i]["type"]!, forKey: "type")
        monster.userData?.setObject(resultMonster[i]["damageCommonName"]!, forKey: "damageCommonName")
        monster.userData?.setObject(resultMonster[i]["damageCommon2Name"]!, forKey: "damageCommon2Name")
        monster.userData?.setObject(resultMonster[i]["damageSpecialName"]!, forKey: "damageSpecialName")
        monster.userData?.setObject(resultMonster[i]["damageCommonImage"]!, forKey: "damageCommonImage")
        monster.userData?.setObject(resultMonster[i]["damageCommon2Image"]!, forKey: "damageCommon2Image")
        monster.userData?.setObject(resultMonster[i]["damageSpecialImage"]!, forKey: "damageSpecialImage")
        monster.userData?.setObject(resultMonster[i]["damageType1"]!, forKey: "damageType1")
        monster.userData?.setObject(resultMonster[i]["damageType2"]!, forKey: "damageType2")
        monster.userData?.setObject(resultMonster[i]["damageType3"]!, forKey: "damageType3")
        monster.userData?.setObject(resultMonster[i]["id"]!, forKey: "id")
        monster.userData?.setObject(resultMonster[i]["defense"]!, forKey: "defense")
        monster.userData?.setObject(resultMonster[i]["damageCommon1"]!, forKey: "damageCommon1")
        monster.userData?.setObject(resultMonster[i]["damageCommon2"]!, forKey: "damageCommon2")
        monster.userData?.setObject(resultMonster[i]["damageCommon3"]!, forKey: "damageCommon3")
        monster.userData?.setObject(resultMonster[i]["basicDamage"]!, forKey: "basicDamage")
        monster.userData?.setObject(resultMonster[i]["basicDamageLevelUp"]!, forKey: "basicDamageLevelUp")
        monster.userData?.setObject(resultMonster[i]["defenseLevelUp"]!, forKey: "defenseLevelUp")
        monster.userData?.setObject(resultMonster[i]["speedLevelUp"]!, forKey: "speedLevelUp")
        monster.userData?.setObject(resultMonster[i]["batter1"]!, forKey: "batter1")
        monster.userData?.setObject(resultMonster[i]["batter2"]!, forKey: "batter2")
        monster.userData?.setObject(resultMonster[i]["batter3"]!, forKey: "batter3")
        monster.userData?.setObject(resultMonster[i]["random1Lower"]!, forKey: "random1Lower")
        monster.userData?.setObject(resultMonster[i]["random1Upper"]!, forKey: "random1Upper")
        monster.userData?.setObject(resultMonster[i]["random2Lower"]!, forKey: "random2Lower")
        monster.userData?.setObject(resultMonster[i]["random2Upper"]!, forKey: "random2Upper")
        monster.userData?.setObject(resultMonster[i]["random3Lower"]!, forKey: "random3Lower")
        monster.userData?.setObject(resultMonster[i]["random3Upper"]!, forKey: "random3Upper")
        monster.userData?.setObject(resultMonster[i]["pauseAttack1"]!, forKey: "pauseAttack1")
        monster.userData?.setObject(resultMonster[i]["pauseAttack2"]!, forKey: "pauseAttack2")
        monster.userData?.setObject(resultMonster[i]["pauseAttack3"]!, forKey: "pauseAttack3")
        monster.userData?.setObject(resultMonster[i]["enhanceDefense1"]!, forKey: "enhanceDefense1")
        monster.userData?.setObject(resultMonster[i]["enhanceDefense2"]!, forKey: "enhanceDefense2")
        monster.userData?.setObject(resultMonster[i]["enhanceDefense3"]!, forKey: "enhanceDefense3")
        monster.userData?.setObject(resultMonster[i]["bloodsuck1"]!, forKey: "bloodsuck1")
        monster.userData?.setObject(resultMonster[i]["bloodsuck2"]!, forKey: "bloodsuck2")
        monster.userData?.setObject(resultMonster[i]["bloodsuck3"]!, forKey: "bloodsuck3")
        monster.userData?.setObject(resultMonster[i]["selfBlew1"]!, forKey: "selfBlew1")
        monster.userData?.setObject(resultMonster[i]["selfBlew2"]!, forKey: "selfBlew2")
        monster.userData?.setObject(resultMonster[i]["selfBlew3"]!, forKey: "selfBlew3")
        monster.userData?.setObject(resultMonster[i]["enhanceAttack1"]!, forKey: "enhanceAttack1")
        monster.userData?.setObject(resultMonster[i]["enhanceAttack2"]!, forKey: "enhanceAttack2")
        monster.userData?.setObject(resultMonster[i]["enhanceAttack3"]!, forKey: "enhanceAttack3")
        monster.userData?.setObject(resultMonster[i]["reduceDefense1"]!, forKey: "reduceDefense1")
        monster.userData?.setObject(resultMonster[i]["reduceDefense2"]!, forKey: "reduceDefense2")
        monster.userData?.setObject(resultMonster[i]["reduceDefense3"]!, forKey: "reduceDefense3")
        //set full hp?
        monster.userData?.setObject(resultMonster[i]["monsterBloodLimit"]!, forKey: "monsterBlood")
        monster.userData?.setObject(resultMonster[i]["monsterBloodLimit"]!, forKey: "monsterBloodLimit")
        monster.userData?.setObject(resultMonster[i]["hp"]!, forKey: "hp")
        monster.userData?.setObject(resultMonster[i]["hpLevelUp"]!, forKey: "hpLevelUp")
//        if (monster.name!.hasPrefix("monsterID")){
            monster.userData?.setObject(resultMonster[i]["level"]!, forKey: "level")
//        }else{
//            monster.userData?.setObject((userData?.objectForKey("level"))!, forKey: "level")
//            enemySkill1CD=(resultMonster[i]["damageCD1"]?.integerValue)!
//            enemySkill2CD=(resultMonster[i]["damageCD2"]?.integerValue)!
//            enemySkill3CD=(resultMonster[i]["damageCD3"]?.integerValue)!
//        }
//        monster.userData?.setObject(resultMonster[i]["picturePath"]! as! String, forKey: "picturePath")
//        monster.userData?.setObject(resultMonster[i]["buttonPicturePath"]! as! String, forKey: "buttonPicturePath")
        monster.userData?.setObject(resultMonster[i]["damageCD1"]!, forKey: "damageCD1")
        monster.userData?.setObject(resultMonster[i]["damageCD2"]!, forKey: "damageCD2")
        monster.userData?.setObject(resultMonster[i]["damageCD3"]!, forKey: "damageCD3")
        monster.userData?.setObject(resultMonster[i]["damageCD1"]!, forKey: "skill1CD")
        monster.userData?.setObject(resultMonster[i]["damageCD2"]!, forKey: "skill2CD")
        monster.userData?.setObject(resultMonster[i]["damageCD3"]!, forKey: "skill3CD")
        monster.userData?.setObject(resultMonster[i]["reduceAllAbility2"]!, forKey: "reduceAllAbility2")
        monster.userData?.setObject(resultMonster[i]["enhanceAllAbility3"]!, forKey: "enhanceAllAbility3")
        monster.userData?.setObject(resultMonster[i]["recoveryHp3"]!, forKey: "recoveryHp3")
        monster.userData?.setObject(resultMonster[i]["reduceAttack2"]!, forKey: "reduceAttack2")
        monster.userData?.setObject(resultMonster[i]["reduceAttack3"]!, forKey: "reduceAttack3")
        monster.userData?.setObject(resultMonster[i]["reduceSpeed2"]!, forKey: "reduceSpeed2")
        monster.userData?.setObject(resultMonster[i]["reduceSpeed3"]!, forKey: "reduceSpeed3")
        monster.userData?.setObject(resultMonster[i]["enhanceSpeed2"]!, forKey: "enhanceSpeed2")
    }
    func createClearBackground(){
        let clearBackground=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 320, height: 568))
        clearBackground.position=CGPoint(x: 160, y: 284)
        clearBackground.name="clearBackground"
        clearBackground.zPosition=9
        addChild(clearBackground)
    }
    func removeClearBackground(){
        if let b=childNodeWithName("clearBackground"){
            b.removeFromParent()
        }
    }
    func createBlackBackground(textToShow:String){
        let blackBackground=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), size: CGSize(width: 320, height: 568))
        blackBackground.position=CGPoint(x: 160, y: 284)
        blackBackground.name="blackBackground"
        blackBackground.zPosition=4
        addChild(blackBackground)
        let charactersArray=Array(textToShow.characters)
        let totalLines=(charactersArray.count/9)+1
        var wordCount=0
        
        for i in 0..<totalLines{
            var linesLength=0
            var linesString:String=""
            while linesLength<9{
                if wordCount == charactersArray.count{
                    break
                }
                linesString=linesString+String(charactersArray[wordCount])
                linesLength=linesString.characters.count
                wordCount++
            }
            let blackBackgroundText=SKLabelNode(text: linesString)
            blackBackgroundText.horizontalAlignmentMode = .Center
            blackBackgroundText.position=CGPoint(x: 0, y:0 - i * 33)
            blackBackgroundText.fontName="AvenirNext-Bold"
            blackBackgroundText.fontColor=UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            blackBackground.addChild(blackBackgroundText)
        }
    }
    func removeBlackBackground(){
        if let b=childNodeWithName("blackBackground"){
            b.removeFromParent()
        }
    }
    func whenUserLose(){
        userMonsterStatusCount--
        monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(0, forKey: "monsterBlood")
        let ripPicture=SKSpriteNode(imageNamed: "battleRipPicture")
        monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.addChild(ripPicture)
        if userMonsterStatusCount>0{
            userHaveADeadMonster=true
            createBlackBackground("寵物死啦，選別隻吧")
            changeMonsterNodeBackground.hidden=false
            userMonsterBePause=0
            userChangeBasicDamage=0
            userChangeDefense=0
            userChangeSpeed=0
        }else{
            createBlackBackground("你被打爆囉！！")
//            reportUserMonsterHP()
            if (userData?.objectForKey("arenaType") as! String) == "arena"{
                alamoRequsetUpdate(BirdGameSetting.URL.ArenaGameOver.rawValue, parameter: ["opponentId":(userData?.objectForKey("id")?.stringValue)!,"winOrNot":"0"], completion: { (inner) -> Void in
                })
            }
            let exit=SKSpriteNode(imageNamed: "exitButton")
            exit.name="loseExitButton"
            addChild(exit)
            exit.position=CGPoint(x: battleEscapeButton.position.x, y: battleEscapeButton.position.y)
            exit.zPosition=20
        }
    }
    func whenUserWin(){
        enemyMonsterStatusCount--
//        monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.setObject(0, forKey: "monsterBlood")
//        let ripPicture=SKSpriteNode(imageNamed: "battleRipPicture")
//        monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.addChild(ripPicture)
        if enemyMonsterStatusCount>0{
//            userHaveADeadMonster=true
//            createBlackBackground("寵物死啦，選別隻吧")
//            changeMonsterNodeBackground.hidden=false
//            userMonsterBePause=0-1
            enemyChangeBasicDamage=0
            enemyChangeDefense=0
            enemyChangeSpeed=0
            enemyTakeDamage=0
            enemyFightMonsterNodeName="enemyMonsterID\(enemyTotalMonsterCount-(enemyMonsterStatusCount-1))"
            setEnemyMonsterInfo(statusEnemyFrameNode.childNodeWithName("enemyMonsterID\(enemyTotalMonsterCount-(enemyMonsterStatusCount-1))")!, parentNode: statusEnemyFrameNode)
        }else{
        createBlackBackground("贏咧！！贏咧！！贏咧！！贏咧！！贏咧！！贏咧！！")

        if (userData?.objectForKey("arenaType") as! String) == "arena"{
            alamoRequsetUpdate(BirdGameSetting.URL.ArenaGameOver.rawValue, parameter: ["opponentId":(userData?.objectForKey("id")?.stringValue)!,"winOrNot":"1"], completion: { (inner) -> Void in
            })
        }
        let exit=SKSpriteNode(imageNamed: "exitButton")
        exit.name="winExitButton"
        addChild(exit)
        exit.position=CGPoint(x: battleEscapeButton.position.x, y: battleEscapeButton.position.y)
        exit.zPosition=20
        }
    }
    func userTouchedChangeMonsterFrame(locationInMonsterItemNode:CGPoint){
        for a:SKNode in monsterItemNode.children{
            if (a.name!.hasPrefix("monsterID")){
                if a.containsPoint(locationInMonsterItemNode){
                if a.userData?.objectForKey("id")?.integerValue != statusUserFrameNode.userData?.objectForKey("id")?.integerValue{
                    if a.userData?.objectForKey("monsterBlood")?.integerValue>0{
                        removeBlackBackground()
                        if userHaveADeadMonster{
                            userHaveADeadMonster=false
                        }else if userFightMonsterNodeName != nil{
                            userFightMonsterNodeName=a.name!
                            setUserMonsterInfo(a,parentNode: statusUserFrameNode)
                            userMonsterBePause=1
                            decideEnemySkillAndGoFight(1)
                        }
                        userFightMonsterNodeName=a.name!
                        setUserMonsterInfo(a,parentNode: statusUserFrameNode)
                    }else{
                        showSomeWordForOneSec("\(a.userData?.objectForKey("name") as! String)已經死啦選別隻吧")
                    }
                    break
                }else{
                    if a.userData?.objectForKey("monsterBlood")?.integerValue>0{
                        showSomeWordForOneSec("換角不能選同一隻啦")
                    }else{
                        showSomeWordForOneSec("\(a.userData?.objectForKey("name") as! String)已經死啦選別隻吧")
                    }
                    break
                    }
                }
            }
        }
    }
    func userTouchedSkillFrame(locationInSkillBackgroundNode:CGPoint){
        for a:SKNode in skillNodeBackground.children{
            if (a.name!.hasPrefix("skillID")){
                if a.containsPoint(locationInSkillBackgroundNode){
                    removeBlackBackground()
                    if a.name!.hasSuffix("1"){
                        if monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill1CD")?.integerValue<1{
                            decideEnemySkillAndGoFight(1)
                        }else{
                            showSomeWordForOneSec("技能一CD還有\((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill1CD")?.integerValue)!)回合")
                        }
                    }else if a.name!.hasSuffix("2"){
                        if monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill2CD")?.integerValue<1{
                            decideEnemySkillAndGoFight(2)
                        }else{
                            showSomeWordForOneSec("技能二CD還有\((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill2CD")?.integerValue)!)回合")
                        }
                    }else if a.name!.hasSuffix("3"){
                        if monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill3CD")?.integerValue<1{
                            decideEnemySkillAndGoFight(3)
                        }else{
                            showSomeWordForOneSec("技能三CD還有\((monsterItemNode.childNodeWithName(userFightMonsterNodeName)?.userData?.objectForKey("skill3CD")?.integerValue)!)回合")
                        }
                    }
                    break
                }
            }
        }
    }
    func randomChangeBlackBackgroundText(){
        var textToShow:String!
        let blackBackground=childNodeWithName("blackBackground")!
        for a in blackBackground.children{
            a.removeFromParent()
        }
        let randomNumber:Int=Int(arc4random_uniform(5))
        switch randomNumber{
        case 0:
            textToShow="我可以跟你分享，花錢是對變強很有用的"
            break
        case 1:
            textToShow="不要亂點啦"
            break
        case 2:
            textToShow="你試過多點幾下會出現什麼嗎"
            break
        case 3:
            textToShow="今天天氣真好"
            break
        case 4:
            textToShow="出口在右下角呦"
            break
        default:
            break
        }
        let charactersArray=Array(textToShow.characters)
        let totalLines=(charactersArray.count/9)+1
        var wordCount=0
        for i in 0..<totalLines{
            var linesLength=0
            var linesString:String=""
            while linesLength<9{
                if wordCount == charactersArray.count{
                    break
                }
                linesString=linesString+String(charactersArray[wordCount])
                linesLength=linesString.characters.count
                wordCount++
            }
            let blackBackgroundText=SKLabelNode(text: linesString)
            blackBackgroundText.horizontalAlignmentMode = .Left
            blackBackgroundText.position=CGPoint(x: -150, y:0 - i * 33)
            blackBackgroundText.fontName="AvenirNext-Bold"
            blackBackgroundText.fontColor=UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            blackBackground.addChild(blackBackgroundText)
        }
    }
    func showSomeWordForOneSec(whatYouWannaShow:String){
        let showSomeWord=SKAction.runBlock { () -> Void in
            if let a:SKSpriteNode = self.childNodeWithName("showSomeWord") as? SKSpriteNode{
                a.removeFromParent()
            }
            let a=SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 0, height: 0))
            a.name="showSomeWord"
            a.position=CGPoint(x: 160, y: 400)
            a.zPosition=30
            self.addChild(a)
                let charactersArray=Array(whatYouWannaShow.characters)
                let totalLines=(charactersArray.count/9)+1
                var wordCount=0
                for i in 0..<totalLines{
                    var linesLength=0
                    var linesString:String=""
                    while linesLength<9{
                        if wordCount == charactersArray.count{
                            break
                        }
                        linesString=linesString+String(charactersArray[wordCount])
                        linesLength=linesString.characters.count
                        wordCount++
                    }
                    let blackBackgroundText=SKLabelNode(text: linesString)
                    blackBackgroundText.horizontalAlignmentMode = .Left
                    blackBackgroundText.position=CGPoint(x: -150, y:0 - i * 33)
                    blackBackgroundText.fontName="AvenirNext-Bold"
                    blackBackgroundText.fontColor=UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                    a.addChild(blackBackgroundText)
            }
        }
        let forOneSec=SKAction.waitForDuration(1)
        let byeShowSomeWord=SKAction.runBlock { () -> Void in
            if let a:SKNode=self.childNodeWithName("showSomeWord"){
                a.removeFromParent()
            }
        }
        runAction(SKAction.sequence([showSomeWord,forOneSec,byeShowSomeWord]))
    }
    func decideEnemySkillAndGoFight(userSkillNumber:Int){
        
        if statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("skill3CD")?.integerValue<1{
            fight(userSkillNumber, enemyMonsterSkillNumber: 3)
        }else if statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("skill2CD")?.integerValue<1{
            fight(userSkillNumber, enemyMonsterSkillNumber: 2)
        }else if statusEnemyFrameNode.childNodeWithName(enemyFightMonsterNodeName)?.userData?.objectForKey("skill1CD")?.integerValue<1{
            fight(userSkillNumber, enemyMonsterSkillNumber: 1)
        }
    }
    func setQuantity(URL:String,theNode:SKNode,quantity:Int){
        let quantityLabel=theNode.childNodeWithName("quantity") as! SKLabelNode
        quantityLabel.text="\(quantity-1)"
        theNode.userData?.setObject(quantity-1, forKey: "quantity")
        let theDecorationName:String=theNode.userData?.objectForKey("itemName") as! String
        alamoRequsetUpdate(URL, parameter: ["itemName":theDecorationName]) { (inner) -> Void in
            
        }
    }
    func userEmitter(imageData:NSData){
        //宣告動畫
        let emitter=SKEmitterNode(fileNamed: "PresentUserSkillParticle")
        emitter?.name="userEmitter"
        emitter?.position=CGPoint(x: self.statusUserFrameNode.position.x+(self.statusUserFrameNode.frame.width/2), y: self.statusUserFrameNode.position.y+self.statusUserFrameNode.frame.height*3/2)
        emitter?.particleSize=CGSize(width: 100, height: 100)
        emitter?.particleTexture=SKTexture(image: UIImage(data: imageData)!)
        addChild(emitter!)
    }
    func whereToGo(){
        if userData?.objectForKey("where") as! String == "map"{
            view?.removeFromSuperview()
        }else if userData?.objectForKey("where") as! String == "arena"{
            if let scene=ArenaEntranceScene(fileNamed: "ArenaEntranceScene"){
                scene.scaleMode = .Fill
                view?.presentScene(scene)
            }
        }else if userData?.objectForKey("where") as! String == "friend"{
                if let scene=SocialScene(fileNamed: "SocialScene"){
                    scene.scaleMode = .Fill
                    scene.userData=NSMutableDictionary()
                    scene.userData?.setObject("friendButtonPressed", forKey: "fromWhere")
                    view?.presentScene(scene)
                }
            }
        }
    func makeSomeButtonNoise(){
        do{
            let voiceURL = NSBundle.mainBundle().URLForResource("button_press", withExtension: "mp3")
            buttonVoicePlayer = try AVAudioPlayer.init(contentsOfURL: voiceURL!)
            buttonVoicePlayer.prepareToPlay()
            SoundEffect.shareSound().playSoundEffect(buttonVoicePlayer);
        }catch{
            print("AVAudioSession Error")
        }
    }
    func makeSomeWaterNoise(){
        do{
            let voiceURL = NSBundle.mainBundle().URLForResource("water_attack", withExtension: "mp3")
            skillVoicePlayer = try AVAudioPlayer.init(contentsOfURL: voiceURL!)
            skillVoicePlayer.prepareToPlay()
            SoundEffect.shareSound().playSoundEffect(skillVoicePlayer);
        }catch{
            print("AVAudioSession Error")
        }
    }
    func makeSomeFireNoise(){
        do{
            let voiceURL = NSBundle.mainBundle().URLForResource("fire_attack", withExtension: "mp3")
            skillVoicePlayer = try AVAudioPlayer.init(contentsOfURL: voiceURL!)
            skillVoicePlayer.prepareToPlay()
            SoundEffect.shareSound().playSoundEffect(skillVoicePlayer);
        }catch{
            print("AVAudioSession Error")
        }
    }
    func makeSomeWindNoise(){
        do{
            let voiceURL = NSBundle.mainBundle().URLForResource("wind_attack", withExtension: "mp3")
            skillVoicePlayer = try AVAudioPlayer.init(contentsOfURL: voiceURL!)
            skillVoicePlayer.prepareToPlay()
            SoundEffect.shareSound().playSoundEffect(skillVoicePlayer);
        }catch{
            print("AVAudioSession Error")
        }
    }
    func makeSomeEarthNoise(){
        do{
            let voiceURL = NSBundle.mainBundle().URLForResource("earth_attack", withExtension: "mp3")
            skillVoicePlayer = try AVAudioPlayer.init(contentsOfURL: voiceURL!)
            skillVoicePlayer.prepareToPlay()
            SoundEffect.shareSound().playSoundEffect(skillVoicePlayer);
        }catch{
            print("AVAudioSession Error")
        }
    }
}


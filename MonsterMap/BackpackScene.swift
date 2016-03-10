//
//  BackpackScene.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/2/23.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import SpriteKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import CoreData
@objc protocol BackpackSceneDelegate{
    func passCoin(coin:Int)
}
class BackpackScene: SKScene {
    let userPhoneWidth=UIScreen.mainScreen().bounds.width
    let userPhoneHeight=UIScreen.mainScreen().bounds.height
    var monsterOn=true
    var itemOn=false
    var decorationOn=false
    var monsterBarNode:SKSpriteNode!
    var monsterBarbarNode:SKSpriteNode!
    var itemBarNode:SKSpriteNode!
    var itemBarbarNode:SKSpriteNode!
    var decorationBarNode:SKSpriteNode!
    var decorationBarbarNode:SKSpriteNode!
    var monsterFrame:SKSpriteNode!
    var itemFrame:SKSpriteNode!
    var decorationFrame:SKSpriteNode!
    var monsterItem:SKSpriteNode!
    var itemItem:SKSpriteNode!
    var decorationItem:SKSpriteNode!
    var itemBackground:SKSpriteNode!
    
    var monsterName:SKLabelNode!
    var monsterLevel:SKLabelNode!
    var monsterExp:SKLabelNode!
    var monsterHp:SKLabelNode!
    var monsterAtk:SKLabelNode!
    var monsterDef:SKLabelNode!
    var monsterSpeed:SKLabelNode!
    var monsterType:SKSpriteNode!
    var monsterFightSet:SKSpriteNode!
    var itemName:SKLabelNode!
    var decorationName:SKLabelNode!
    
    var headers:[String:String]!
    var oldMonsterCount:Int!
    var newMonsterCount:Int!
    var itemCount:Int!
    var decorationCount:Int!
    var monsterStatusCount=0
    var itemOriginalY:CGFloat!
    var touchBeganLocation:CGPoint!
    var monsterNameToDetectRepeat:[String]=["name"]
    let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext:NSManagedObjectContext!
    var monsterImage:[MonsterImage] = []
    var monsterButtonImage:[MonsterButtonImage] = []
    var itemImage:[ItemImage] = []
    var itemButtonImage:[ItemButtonImage] = []
    var decorationImage:[DecorationImage] = []
    var decorationButtonImage:[DecorationButtonImage] = []
    var fightMonsterData:[[String:AnyObject]]!
    var monsterID:Int=0
    var itemFirstShow=true
    var decorationFirstShow=true
    let token = Player.playerSingleton().userToken
    enum URL:String{
        case URLBegining="http://api.leolin.me"
        case UserMonster="http://api.leolin.me/userMonster"
        case InventoryItem="http://api.leolin.me/inventoryItem"
        case InventoryDecorationForBackpack="http://api.leolin.me/inventoryDecorationForBackpack"
        case SellItem="http://api.leolin.me/sellItem"
        case SellDecoration="http://api.leolin.me/sellDecoration"
        case SellMonster="http://api.leolin.me/sellMonster"
        case SettingUserMonster="http://api.leolin.me/settingUserMonster"
    }
    weak var backPackDelegate:BackpackSceneDelegate?
    
    override func didMoveToView(view: SKView) {
        managedObjectContext=appDelegate.managedObjectContext
        headers=["token":token]
        
        monsterFrame=childNodeWithName("backpackMonsterFrame") as! SKSpriteNode
        itemFrame=childNodeWithName("backpackItemFrame") as! SKSpriteNode
        decorationFrame=childNodeWithName("backpackDecorationFrame") as! SKSpriteNode
        itemBackground=childNodeWithName("backpackItemAreaBackground") as! SKSpriteNode

        monsterItem=childNodeWithName("monsterItem") as! SKSpriteNode
        itemItem=childNodeWithName("itemItem") as! SKSpriteNode
        decorationItem=childNodeWithName("decorationItem") as! SKSpriteNode
        monsterName=childNodeWithName("monsterName") as! SKLabelNode
        itemName=childNodeWithName("itemName") as! SKLabelNode
        decorationName=childNodeWithName("decorationName") as! SKLabelNode
        monsterBarNode=monsterName.childNodeWithName("scrollBar") as! SKSpriteNode
        monsterBarbarNode=monsterName.childNodeWithName("scrollBarbar") as! SKSpriteNode
        itemBarNode=itemName.childNodeWithName("scrollBar") as! SKSpriteNode
        itemBarbarNode=itemName.childNodeWithName("scrollBarbar") as! SKSpriteNode
        decorationBarNode=decorationName.childNodeWithName("scrollBar") as! SKSpriteNode
        decorationBarbarNode=decorationName.childNodeWithName("scrollBarbar") as! SKSpriteNode
        monsterLevel=monsterName.childNodeWithName("monsterLevel") as! SKLabelNode
        monsterExp=monsterName.childNodeWithName("monsterExp") as! SKLabelNode
        monsterHp=monsterName.childNodeWithName("monsterHp") as! SKLabelNode
        monsterAtk=monsterName.childNodeWithName("monsterAtk") as! SKLabelNode
        monsterDef=monsterName.childNodeWithName("monsterDef") as! SKLabelNode
        monsterSpeed=monsterName.childNodeWithName("monsterSpeed") as! SKLabelNode
        monsterType=monsterName.childNodeWithName("monsterType") as! SKSpriteNode
        monsterFightSet=monsterName.childNodeWithName("monsterFightSet") as! SKSpriteNode
        monsterFightSet.userData=NSMutableDictionary()
        
        

        itemOriginalY=monsterItem.position.y
        itemItem.hidden=true
        itemName.hidden=true
        
        decorationItem.hidden=true
        decorationName.hidden=true
        
        monsterName.hidden=true
        monsterItem.hidden=true
        
        alamoRequset(URL.UserMonster.rawValue) { (inner) -> Void in
            do{
                let result=try inner()
                var positionRow=0
                var positionColumn=0
                self.oldMonsterCount=result.count
                self.newMonsterCount=result.count
                
                for i in 0..<result.count {
                    let monster=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                    monster.name="monsterID\(i+1)"
                    monster.position=CGPoint(x: 0+(5+monster.frame.width)*CGFloat(positionColumn), y: 0-(5+monster.frame.height)*CGFloat(positionRow))
                    self.monsterItem.addChild(monster)
                    self.setMonsterUserdata(monster, resultMonster: result, i: i)
                    let picturePath:String=result[i]["picturePath"]! as! String
                    let buttonPicturePath:String=result[i]["buttonPicturePath"]! as! String
                    
                    if Int(result[i]["status"]! as! NSNumber)==1{
                        self.monsterStatusCount++
                        let fightOn=SKSpriteNode(imageNamed: "backpackMonsterFightOn")
                        fightOn.name="fightOn"
                        monster.addChild(fightOn)
                    }
                    monster.userData?.setObject(picturePath, forKey: "picturePath")
                    monster.userData?.setObject(buttonPicturePath, forKey: "buttonPicturePath")
                    self.somethingAboutImage(monster,thePicturePath: buttonPicturePath,thePictureType: "MonsterButtonImage")
                    self.somethingAboutImage(monster,thePicturePath: picturePath,thePictureType: "MonsterImage")
                    
                    if positionColumn==2{
                        positionRow++
                        positionColumn = -1
                    }
                    positionColumn++
                }
                self.setMonsterInfo("monsterID1")
                self.monsterName.hidden=false
                self.monsterItem.hidden=false
                if result.count>9{
                    let itemFrameRange = 0 - (self.monsterItem.childNodeWithName("monsterID\(self.oldMonsterCount)")?.position.y)!
                    self.monsterBarbarNode.size.height = self.monsterBarNode.frame.height * (3*self.monsterItem.frame.height/itemFrameRange)
                    self.monsterBarbarNode.position.y = self.monsterBarNode.position.y + (self.monsterBarNode.frame.height/2) - (self.monsterBarbarNode.frame.height/2) - 2
                }
            }catch let error{
                print(error)
            }
        }
        alamoRequset(URL.InventoryItem.rawValue) { (inner) -> Void in
            do{
                let result=try inner()
                var positionRow=0
                var positionColumn=0
                self.itemCount=result.count
                
                for i in 0..<result.count {
                    let item=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                    item.name="itemID\(i+1)"
                    item.position=CGPoint(x: 0+(5+item.frame.width)*CGFloat(positionColumn), y: 0-(5+item.frame.height)*CGFloat(positionRow))
                    self.itemItem.addChild(item)
                    item.userData=NSMutableDictionary()
                    item.userData?.setObject(result[i]["itemName"]!, forKey: "itemName")
                    item.userData?.setObject(result[i]["description"]!, forKey: "description")
                    item.userData?.setObject(result[i]["quantity"]!, forKey: "quantity")
                    item.userData?.setObject(result[i]["enrichBlood"]!, forKey: "enrichBlood")
                    item.userData?.setObject(result[i]["sellPrice"]!, forKey: "sellPrice")
                    let itemQuantity=SKLabelNode(text: result[i]["quantity"]?.stringValue)
                    itemQuantity.name="quantity"
                    itemQuantity.fontSize=18
                    itemQuantity.fontName="AvenirNext-Bold"
                    itemQuantity.fontColor=UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    itemQuantity.horizontalAlignmentMode = .Right
                    item.addChild(itemQuantity)
                    itemQuantity.position=CGPointMake(35, -34)
                    
                    let picturePath:String=result[i]["picturePath"]! as! String
                    let buttonPicturePath:String=result[i]["buttonPicturePath"]! as! String
                    item.userData?.setObject(picturePath, forKey: "picturePath")
                    item.userData?.setObject(buttonPicturePath, forKey: "buttonPicturePath")
                    self.somethingAboutImage(item,thePicturePath: buttonPicturePath,thePictureType: "ItemButtonImage")
                    self.somethingAboutImage(item,thePicturePath: picturePath,thePictureType: "ItemImage")
                    
                    if positionColumn==2{
                        positionRow++
                        positionColumn = -1
                    }
                    positionColumn++
                }
                if result.count>9{
                    let itemFrameRange = 0 - (self.itemItem.childNodeWithName("itemID\(self.itemCount)")?.position.y)!
                    self.itemBarbarNode.size.height = self.itemBarNode.frame.height * (3*self.itemItem.frame.height/itemFrameRange)
                    self.itemBarbarNode.position.y = self.itemBarNode.position.y + (self.itemBarNode.frame.height/2) - (self.itemBarbarNode.frame.height/2) - 2
                }
            }catch let error{
                print(error)
            }
        }
        alamoRequset(URL.InventoryDecorationForBackpack.rawValue) { (inner) -> Void in
            do{
                let result=try inner()
                var positionRow=0
                var positionColumn=0
                self.decorationCount=result.count
                
                for i in 0..<result.count {
                    let decoration=SKSpriteNode(imageNamed: "monsterHandbookItemFrame")
                    decoration.name="decorationID\(i+1)"
                    decoration.position=CGPoint(x: 0+(5+decoration.frame.width)*CGFloat(positionColumn), y: 0-(5+decoration.frame.height)*CGFloat(positionRow))
                    self.decorationItem.addChild(decoration)
                    decoration.userData=NSMutableDictionary()
                    decoration.userData?.setObject(result[i]["itemName"]!, forKey: "itemName")
                    decoration.userData?.setObject(result[i]["description"]!, forKey: "description")
                    decoration.userData?.setObject(result[i]["quantity"]!, forKey: "quantity")
                    let decorationQuantity=SKLabelNode(text: result[i]["quantity"]?.stringValue)
                    decoration.userData?.setObject(result[i]["sellPrice"]!, forKey: "sellPrice")
                    decorationQuantity.name="quantity"
                    decorationQuantity.fontSize=18
                    decorationQuantity.fontName="AvenirNext-Bold"
                    decorationQuantity.fontColor=UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    decorationQuantity.horizontalAlignmentMode = .Right
                    decoration.addChild(decorationQuantity)
                    decorationQuantity.position=CGPointMake(35, -34)
                    let picturePath:String=result[i]["picturePath"]! as! String
                    let buttonPicturePath:String=result[i]["buttonPicturePath"]! as! String
                    decoration.userData?.setObject(picturePath, forKey: "picturePath")
                    decoration.userData?.setObject(buttonPicturePath, forKey: "buttonPicturePath")
                    self.somethingAboutImage(decoration,thePicturePath: buttonPicturePath,thePictureType: "DecorationButtonImage")
                    self.somethingAboutImage(decoration,thePicturePath: picturePath,thePictureType: "DecorationImage")
                    
                    if positionColumn==2{
                        positionRow++
                        positionColumn = -1
                    }
                    positionColumn++
                }
                if result.count>9{
                    let itemFrameRange = 0 - (self.decorationItem.childNodeWithName("decorationID\(self.decorationCount)")?.position.y)!
                    self.decorationBarbarNode.size.height = self.decorationBarNode.frame.height * (3*self.decorationItem.frame.height/itemFrameRange)
                    self.decorationBarbarNode.position.y = self.decorationBarNode.position.y + (self.decorationBarNode.frame.height/2) - (self.decorationBarbarNode.frame.height/2) - 2
                                }
            }catch let error{
                print(error)
            }
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let range=(location?.y)!-touchBeganLocation.y
        var itemFrameMoveRange = 0 - (monsterItem.childNodeWithName("monsterID\(oldMonsterCount)")?.position.y)! - 2 * monsterItem.frame.height
        var changePositionValue=itemFrameMoveRange / CGFloat(newMonsterCount) / 2
        var itemFrameNode=monsterItem
        var scrollBarNode=monsterBarNode
        var scrollBarbarNode=monsterBarbarNode
        if itemItem.hidden==false && itemCount>0{
            itemFrameNode=itemItem
            scrollBarNode=itemBarNode
            scrollBarbarNode=itemBarbarNode
            itemFrameMoveRange = 0 - (itemItem.childNodeWithName("itemID\(itemCount)")?.position.y)! - 2 * itemItem.frame.height
            changePositionValue=itemFrameMoveRange / CGFloat(itemCount) / 2
            touchesMoved(range, itemFrameMoveRange: itemFrameMoveRange, changePositionValue: changePositionValue, scrollBarNode: scrollBarNode, scrollBarbarNode: scrollBarbarNode, itemFrameNode: itemFrameNode)
        }else if decorationItem.hidden==false && decorationCount>0{
            itemFrameNode=decorationItem
            scrollBarNode=decorationBarNode
            scrollBarbarNode=decorationBarbarNode
            itemFrameMoveRange = 0 - (decorationItem.childNodeWithName("decorationID\(decorationCount)")?.position.y)! - 2 * decorationItem.frame.height
            changePositionValue=itemFrameMoveRange / CGFloat(decorationCount) / 2
            touchesMoved(range, itemFrameMoveRange: itemFrameMoveRange, changePositionValue: changePositionValue, scrollBarNode: scrollBarNode, scrollBarbarNode: scrollBarbarNode, itemFrameNode: itemFrameNode)
        }else if monsterItem.hidden==false{
            touchesMoved(range, itemFrameMoveRange: itemFrameMoveRange, changePositionValue: changePositionValue, scrollBarNode: scrollBarNode, scrollBarbarNode: scrollBarbarNode, itemFrameNode: itemFrameNode)
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchBeganLocation=touches.first?.locationInNode(self)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        
        if touchBeganLocation == location{
            if nodeTouchedName == "backButton"{
                //過場效果
                self.backPackDelegate?.passCoin(NSInteger(Player.playerSingleton().coin))
                let transition = CATransition()
                transition.duration = 0.4
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromBottom
                transition.timingFunction=CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.view!.superview!.layer.addAnimation(transition, forKey: "transition")
                view?.removeFromSuperview()
//                if let scene=ArenaEntranceScene(fileNamed: "ArenaEntranceScene"){
//                    scene.scaleMode = .Fill
//                    view?.presentScene(scene)
//                }
            }else if nodeTouchedName == "monsterFrameShow"{
                monsterItem.hidden=false
                itemItem.hidden=true
                decorationItem.hidden=true
                monsterFrame.zPosition=20
                itemFrame.zPosition=15
                decorationFrame.zPosition=10
                monsterName.hidden=false
                itemName.hidden=true
                decorationName.hidden=true
            }else if nodeTouchedName == "itemFrameShow"{
                monsterItem.hidden=true
                itemItem.hidden=false
                decorationItem.hidden=true
                monsterFrame.zPosition=15
                itemFrame.zPosition=20
                decorationFrame.zPosition=10
                monsterName.hidden=true
                decorationName.hidden=true
                itemName.hidden=false
                if itemFirstShow{
                    if itemCount>0{
                        setItemInfo("itemID1")
                        itemFirstShow=false
                    }else{
                        itemName.hidden=true
                        showSomeWordForOneSec("你沒有任何消耗品")
                    }
                }
            }else if nodeTouchedName == "decorationFrameShow"{
                monsterItem.hidden=true
                itemItem.hidden=true
                decorationItem.hidden=false
                monsterFrame.zPosition=10
                itemFrame.zPosition=15
                decorationFrame.zPosition=20
                monsterName.hidden=true
                itemName.hidden=true
                decorationName.hidden=false
                if decorationFirstShow{
                    if decorationCount>0{
                        setDecorationInfo("decorationID1")
                        decorationFirstShow=false
                    }else{
                        decorationName.hidden=true
                        showSomeWordForOneSec("你沒有任何裝飾品")
                    }
                }
            }else if nodeTouchedName == "useItemButton"{
                if itemName.text!.hasSuffix("色藥水"){
                for a in itemItem.children{
                    if a.userData?.objectForKey("itemName") as! String == itemName.text!{
                        goToBackpackChooseItemUserScene(a.userData?.objectForKey("itemName") as! String,theEnrichBloodAmount: (a.userData?.objectForKey("enrichBlood")?.integerValue)!,theQuantity: (a.userData?.objectForKey("quantity")?.integerValue)!)
                        break
                    }
                }
                }else if itemName.text!.hasSuffix("加倍藥水"){
                    for a in itemItem.children{
                        if a.userData?.objectForKey("itemName") as! String == itemName.text!{
                            
                            break
                        }
                    }
                }
            }else if nodeTouchedName == "sellItemButton"{
                for a in itemItem.children{
                    let theItemName:String=a.userData?.objectForKey("itemName") as! String
                    if theItemName == itemName.text!{
                        let theItemQuantity:Int=(a.userData?.objectForKey("quantity")?.integerValue)!
                        if theItemQuantity > 0{
                            showSomeWordForOneSec("賣出\(itemName.text!)")
                            Player.playerSingleton().coin=Int(Player.playerSingleton().coin)+(a.userData?.objectForKey("sellPrice")?.integerValue)!
                        setQuantity(URL.SellItem.rawValue,theNode: a, quantity: theItemQuantity)
                        }
                        break
                    }
                }
            }else if nodeTouchedName == "sellDecorationButton"{
                for a in decorationItem.children{
                    let theItemName:String=a.userData?.objectForKey("itemName") as! String
                    if theItemName == decorationName.text!{
                        let theItemQuantity:Int=(a.userData?.objectForKey("quantity")?.integerValue)!
                        if theItemQuantity > 0{
                            showSomeWordForOneSec("賣出\(decorationName.text!)")
                            Player.playerSingleton().coin=Int(Player.playerSingleton().coin)+(a.userData?.objectForKey("sellPrice")?.integerValue)!
                        setQuantity(URL.SellDecoration.rawValue,theNode: a, quantity: theItemQuantity)
                        }
                        break
                    }
                }
            }else if nodeTouchedName == "monsterFightSet"{
                userTouchedFightSet()
            }else if nodeTouchedName == "sellMonsterButton"{
                for a in monsterItem.children{
                    if a.userData?.objectForKey("status")?.integerValue == 0{
                    if a.userData?.objectForKey("id")?.integerValue == monsterID{
                        let theMonsterName:String=a.userData?.objectForKey("name") as! String
                        Player.playerSingleton().coin=Int(Player.playerSingleton().coin)+(a.userData?.objectForKey("sellPrice")?.integerValue)!
                        alamoRequsetUpdate(URL.SellMonster.rawValue, parameter: ["monsterName":theMonsterName,"monsterId":monsterID], completion: { (inner) -> Void in
                        })
                        print(a.name!.hasSuffix("\(oldMonsterCount)"))
                        print("\(oldMonsterCount)")
                        if a.name!.hasSuffix("\(oldMonsterCount)"){
                            oldMonsterCount!--
                        }
                        newMonsterCount!--
                        a.removeFromParent()
                        monsterItem.position.y=itemOriginalY
                        var positionRow=0
                        var positionColumn=0
                        
                        for i in 0..<oldMonsterCount {
                            if let monster:SKNode=monsterItem.childNodeWithName("monsterID\(i+1)"){
                                monster.position=CGPoint(x: 0+(5+monster.frame.width)*CGFloat(positionColumn), y: 0-(5+monster.frame.height)*CGFloat(positionRow))
                                if positionColumn==2{
                                    positionRow++
                                    positionColumn = -1
                                }
                                positionColumn++
                            }
                        }
                        if newMonsterCount>9{
                            let itemFrameRange = 0 - (self.monsterItem.childNodeWithName("monsterID\(self.oldMonsterCount)")?.position.y)!
                            self.monsterBarbarNode.size.height = self.monsterBarNode.frame.height * (3*self.monsterItem.frame.height/itemFrameRange)
                            self.monsterBarbarNode.position.y = self.monsterBarNode.position.y + (self.monsterBarNode.frame.height/2) - (self.monsterBarbarNode.frame.height/2) - 2
                        }else{
                            self.monsterBarbarNode.size.height=self.monsterBarNode.frame.height - 4
                            self.monsterBarbarNode.position.y=self.monsterBarNode.position.y
                        }
                        for i in 1...oldMonsterCount{
                            if let b:SKNode=monsterItem.childNodeWithName("monsterID\(i)"){
                                setMonsterInfo(b.name!)
                                break
                            }
                        }
                        break
                    }
                    }
                }
            }else if nodeTouchedName == "confirmSellButton"{
                
            }
            
            if itemBackground.containsPoint(touchBeganLocation){
                if monsterName.hidden==false{
                    let locationInMonsterFrame=touches.first?.locationInNode(monsterItem)
                for a in monsterItem.children{
                    if a.containsPoint(locationInMonsterFrame!){
                        setMonsterInfo(a.name!)
                        break
                    }
                }
                }else if itemName.hidden==false{
                    let locationInItemFrame=touches.first?.locationInNode(itemItem)
                    for a in itemItem.children{
                        if a.containsPoint(locationInItemFrame!){
                            setItemInfo(a.name!)
                            break
                        }
                    }
                }else if decorationItem.hidden==false{
                    let locationInDecorationFrame=touches.first?.locationInNode(decorationItem)
                    for a in decorationItem.children{
                        if a.containsPoint(locationInDecorationFrame!){
                            setDecorationInfo(a.name!)
                            break
                        }
                    }
                }
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
        let picturePath:String=URL.URLBegining.rawValue+thePicturePath
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
    func setQuantity(URL:String,theNode:SKNode,quantity:Int){
        let quantityLabel=theNode.childNodeWithName("quantity") as! SKLabelNode
        quantityLabel.text="\(quantity-1)"
        theNode.userData?.setObject(quantity-1, forKey: "quantity")
        let theDecorationName:String=theNode.userData?.objectForKey("itemName") as! String
        alamoRequsetUpdate(URL, parameter: ["itemName":theDecorationName]) { (inner) -> Void in
            
        }
    }
    func setDecorationInfo(theNodeName:String){
        for a in decorationName.children{
            let hasPrefix=a.name?.hasPrefix("decorationDescription")
            if hasPrefix==true{
                a.hidden=true
            }
        }
        let descriptionText=Array((decorationItem.childNodeWithName(theNodeName)?.userData?.objectForKey("description") as? String)!.characters)
        decorationName.text=decorationItem.childNodeWithName(theNodeName)?.userData?.objectForKey("itemName") as? String
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
            let label=decorationName.childNodeWithName("decorationDescription\(i)") as! SKLabelNode
            label.hidden=false
            label.text=linesString
        }
        //price
        (decorationName.childNodeWithName("price") as! SKLabelNode).text="售價：\((decorationItem.childNodeWithName(theNodeName)?.userData?.objectForKey("sellPrice")?.stringValue)!)"
        //讀圖
        let thePicturePath=decorationItem.childNodeWithName(theNodeName)?.userData?.objectForKey("picturePath") as! String
        let theMonsterName=decorationItem.childNodeWithName(theNodeName)?.userData?.objectForKey("itemName") as! String
        for b in self.decorationImage{
            if b.name! == theMonsterName && b.picturePath! == thePicturePath{
                (decorationName.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: UIImage(data: b.picture!)!)
            }
        }
    }
    func setItemInfo(theNodeName:String){
        //隱藏說明SKLabelNode
        for a in itemName.children{
            if a.name!.hasPrefix("itemDescription"){
                a.hidden=true
            }
        }
        //把取到的說明轉成陣列
        let descriptionText=Array((itemItem.childNodeWithName(theNodeName)?.userData?.objectForKey("description") as? String)!.characters)
        //設定物品名字到node
        itemName.text=itemItem.childNodeWithName(theNodeName)?.userData?.objectForKey("itemName") as? String
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
            let label=itemName.childNodeWithName("itemDescription\(i)") as! SKLabelNode
            label.hidden=false
            label.text=linesString
        }
        //price
        (itemName.childNodeWithName("price") as! SKLabelNode).text="售價：\((itemItem.childNodeWithName(theNodeName)?.userData?.objectForKey("sellPrice")?.stringValue)!)"
        //讀圖
        let thePicturePath=itemItem.childNodeWithName(theNodeName)?.userData?.objectForKey("picturePath") as! String
        let theMonsterName=itemItem.childNodeWithName(theNodeName)?.userData?.objectForKey("itemName") as! String
        for b in self.itemImage{
            if b.name! == theMonsterName && b.picturePath! == thePicturePath{
                (itemName.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: UIImage(data: b.picture!)!)
            }
        }
        if itemName.text!.hasSuffix("藥水"){
        itemName.childNodeWithName("useItemButton")?.hidden=false
        }else{
            itemName.childNodeWithName("useItemButton")?.hidden=true
        }
    }
    func setMonsterInfo(theNodeName:String){
        monsterID=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("id")?.integerValue)!
        let level:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("level")?.integerValue)!
        let hp:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("monsterBlood")?.integerValue)!
        let hpMax:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("monsterBloodLimit")?.integerValue)!
        let atk:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("basicDamage")?.integerValue)!
        let atkUp:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("basicDamageLevelUp")?.integerValue)!
        let def:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("defense")?.integerValue)!
        let defUp:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("defenseLevelUp")?.integerValue)!
        let speed:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("speed")?.integerValue)!
        let speedUp:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("speedLevelUp")?.integerValue)!
        let type:String=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("type") as! String
        let status:Int=(monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("status")?.integerValue)!
        monsterName.text=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("name") as? String
        monsterLevel.text="等級    \(level)"
        monsterExp.text="經驗    \((monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("experience")?.stringValue)!)"
        monsterHp.text="血量    \(hp)/\(hpMax)"
        monsterAtk.text="攻擊    \(atk+(level*atkUp))"
        monsterDef.text="防禦    \(def+(level*defUp))"
        monsterSpeed.text="速度    \(speed+(level*speedUp))"
        //price
        (monsterName.childNodeWithName("price") as! SKLabelNode).text="售價：\((monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("sellPrice")?.stringValue)!)"
        
        if status==1{
            monsterFightSet.texture=SKTexture(imageNamed: "backpackButtonFightOff")
            monsterFightSet.userData?.setObject(1, forKey: "status")
        }else{
            monsterFightSet.texture=SKTexture(imageNamed: "backpackButtonFightOn")
            monsterFightSet.userData?.setObject(0, forKey: "status")
        }
        //讀圖
        let thePicturePath=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("picturePath") as! String
        let theMonsterName=monsterItem.childNodeWithName(theNodeName)?.userData?.objectForKey("name") as! String
        for b in self.monsterImage{
            if b.name! == theMonsterName && b.picturePath! == thePicturePath{
                (monsterName.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: UIImage(data: b.picture!)!)
                break
            }
        }
        
        switch type{
        case "火":
            monsterType.texture=SKTexture(imageNamed: "backpackMonsterElementFire")
            break
        case "風":
            monsterType.texture=SKTexture(imageNamed: "backpackMonsterElementWind")
            break
        case "地":
            monsterType.texture=SKTexture(imageNamed: "backpackMonsterElementEarth")
            break
        case "水":
            monsterType.texture=SKTexture(imageNamed: "backpackMonsterElementWater")
            break
        default:
            break
        }
    }
    func somethingAboutImage(theNode:SKSpriteNode,thePicturePath:String,thePictureType:String){
        let moc=self.managedObjectContext
        let monsterImageFetch=NSFetchRequest(entityName: thePictureType)
        var fetchError:NSError?=nil
        var coredataHasImage=false
        var theMonsterName=""
        
        if theNode.name!.hasPrefix("monster"){
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
                            if thePicturePath == self.monsterItem.childNodeWithName("monsterID1")?.userData?.objectForKey("picturePath") as! String{
                                (self.monsterName.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: UIImage(data: b.picture!)!)
                            }
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
//                                print("\(b.name)的image使用coredata")
                                theNode.texture=SKTexture(image: UIImage(data: b.picture!)!)
                            coredataHasImage=true
                            break
                        }
                    }
                    break
                case "ItemImage":
                    self.itemImage=try moc.executeFetchRequest(monsterImageFetch) as! [ItemImage]
                    for b in self.itemImage{
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
                case "ItemButtonImage":
                    self.itemButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [ItemButtonImage]
                    for b in self.itemButtonImage{
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
//                            print("\(b.name)的image使用coredata")
                            theNode.texture=SKTexture(image: UIImage(data: b.picture!)!)
                            coredataHasImage=true
                            break
                        }
                    }
                    break
                case "DecorationImage":
                    self.decorationImage=try moc.executeFetchRequest(monsterImageFetch) as! [DecorationImage]
                    for b in self.decorationImage{
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
                case "DecorationButtonImage":
                    self.decorationButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [DecorationButtonImage]
                    for b in self.decorationButtonImage{
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
//                            print("\(b.name)的image使用coredata")
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
                        if thePicturePath == self.monsterItem.childNodeWithName("monsterID1")?.userData?.objectForKey("picturePath") as! String{
                            (self.monsterName.childNodeWithName("image") as! SKSpriteNode).texture=SKTexture(image: image)
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
                            case "DecorationImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! DecorationImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.decorationImage=try moc.executeFetchRequest(monsterImageFetch) as! [DecorationImage]
                                }catch{
                                    fatalError("Failure to save context: \(error)")
                                    
                                }
                                break
                            case "DecorationButtonImage":
                                let saveImage=NSEntityDescription.insertNewObjectForEntityForName(thePictureType, inManagedObjectContext: moc) as! DecorationButtonImage
                                saveImage.name=theMonsterName
                                saveImage.picture=UIImagePNGRepresentation(image)
                                saveImage.picturePath=thePicturePath
                                do{
                                    print("儲存\(theMonsterName)的image")
                                    try moc.save()
                                    self.decorationButtonImage=try moc.executeFetchRequest(monsterImageFetch) as! [DecorationButtonImage]
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
        monster.userData?.setObject(resultMonster[i]["sellPrice"]!, forKey: "sellPrice")
    }
    func goToBackpackChooseItemUserScene(theItemName:String,theEnrichBloodAmount:Int,theQuantity:Int){
        if let scene=BackpackChooseItemUser(fileNamed: "BackpackChooseItemUser"){
//            let addSubView:SKView=SKView(frame: CGRect(x: 0, y: 0, width: userPhoneWidth, height: userPhoneHeight))
//            addSubView.backgroundColor=UIColor(white: 1, alpha: 1)
//            self.view!.addSubview(addSubView)
            scene.scaleMode = .Fill
            scene.userData=NSMutableDictionary()
            scene.userData?.setObject(theEnrichBloodAmount, forKey: "enrichBlood")
            scene.userData?.setObject(theItemName, forKey: "itemName")
            scene.userData?.setObject(theQuantity, forKey: "quantity")

//            addSubView.presentScene(scene)
            view!.presentScene(scene)
        }
    }
    func userTouchedFightSet(){
        for a in monsterItem.children{
            if a.userData?.objectForKey("id")?.integerValue == monsterID{
                var status:Int=(a.userData?.objectForKey("status")?.integerValue)!
                let theMonsterName:String=a.userData?.objectForKey("name") as! String
                let theMonsterID:Int=(a.userData?.objectForKey("id")?.integerValue)!
                
                if status==1{
                    if monsterStatusCount>1{
                        status=0
                        monsterStatusCount--
                        monsterFightSet.texture=SKTexture(imageNamed: "backpackButtonFightOn")
                        monsterFightSet.userData?.setObject(0, forKey: "status")
                        a.childNodeWithName("fightOn")?.removeFromParent()
                        a.userData?.setObject(status, forKey: "status")
                        alamoRequsetUpdate(URL.SettingUserMonster.rawValue, parameter: ["monsterName":theMonsterName,"monsterId":theMonsterID], completion: { (inner) -> Void in
                            
                        })
                    }
                }else{
                    if monsterStatusCount < 3{
                        status=1
                        monsterStatusCount++
                        monsterFightSet.texture=SKTexture(imageNamed: "backpackButtonFightOff")
                        monsterFightSet.userData?.setObject(1, forKey: "status")
                        let fightOn=SKSpriteNode(imageNamed: "backpackMonsterFightOn")
                        fightOn.name="fightOn"
                        a.addChild(fightOn)
                        a.userData?.setObject(status, forKey: "status")
                        alamoRequsetUpdate(URL.SettingUserMonster.rawValue, parameter: ["monsterName":theMonsterName,"monsterId":theMonsterID], completion: { (inner) -> Void in
                            
                        })
                    }
                }
                break
            }
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
                blackBackgroundText.horizontalAlignmentMode = .Center
                blackBackgroundText.position=CGPoint(x: 0, y:0 - i * 33)
                blackBackgroundText.fontName="AvenirNext-Bold"
                blackBackgroundText.fontSize=20
                blackBackgroundText.fontColor=UIColor(red: 0, green: 0, blue: 0, alpha: 1)
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
            blackBackgroundText.fontSize=25
            blackBackgroundText.fontName="AvenirNext-Bold"
            blackBackgroundText.fontColor=UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            blackBackground.addChild(blackBackgroundText)
        }
        let confirmSellButton=SKSpriteNode(imageNamed: "backpackButtonSell")
        confirmSellButton.name="confirmSellButton"
        confirmSellButton.position=CGPoint(x: confirmSellButton.frame.width, y: confirmSellButton.frame.height)
        blackBackground.addChild(confirmSellButton)
//        let cancelSellButton=SKSpriteNode(imageNamed: <#T##String#>)
    }
    func removeBlackBackground(){
        if let b=childNodeWithName("blackBackground"){
            b.removeFromParent()
        }
    }
    func touchesMoved(range:CGFloat,itemFrameMoveRange:CGFloat,changePositionValue:CGFloat,scrollBarNode:SKSpriteNode,scrollBarbarNode:SKSpriteNode,itemFrameNode:SKSpriteNode){
        if itemBackground.containsPoint(touchBeganLocation){
            if range > 0{
                if itemFrameNode.position.y < itemOriginalY + itemFrameMoveRange{
                    itemFrameNode.position.y += changePositionValue
                    scrollBarbarNode.position.y -= (scrollBarNode.frame.height-scrollBarbarNode.frame.height-5) / (itemFrameMoveRange / changePositionValue)
                }else{
                    scrollBarbarNode.position.y=scrollBarNode.position.y - (scrollBarNode.frame.height/2) + (scrollBarbarNode.frame.height/2) + 1.5
                }
            }
            if range < 0{
                if itemFrameNode.position.y > itemOriginalY{
                    itemFrameNode.position.y -= changePositionValue
                    scrollBarbarNode.position.y += (scrollBarNode.frame.height-scrollBarbarNode.frame.height-5) / (itemFrameMoveRange / changePositionValue)
                }else{
                    itemFrameNode.position.y=itemOriginalY
                    scrollBarbarNode.position.y=scrollBarNode.position.y + (scrollBarNode.frame.height/2) - (scrollBarbarNode.frame.height/2) - 1.5
                }
            }
        }
    }
}
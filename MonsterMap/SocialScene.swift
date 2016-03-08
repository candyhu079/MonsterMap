//
//  SocialScene.swift
//  MonsterMap
//
//  Created by 羅崇寧 on 2016/2/25.
//  Copyright © 2016年 Charlie Luo. All rights reserved.
//

import Foundation
import SpriteKit
//import UIKit

import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreData
/*,UITextViewDelegate*/
class SocialScene: SKScene {
    
    //資料庫連結
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    let friendListURL = "http://api.leolin.me/friendList"
    let mailListURL = "http://api.leolin.me/receiveMail"
    let inviteListURL = "http://api.leolin.me/beInvitedList"
    let deleteFriendURL = "http://api.leolin.me/deleteFriend"
    let confirmInvitedURL = "http://api.leolin.me/confirmInvited"
    
    //社群系統主畫面按鈕
    var returnBtn:SKSpriteNode!
    var friendListBtn:SKSpriteNode!
    var messagePageBtn:SKSpriteNode!
    var invitePageBtn:SKSpriteNode!
    
    //各種分頁
    var background:SKSpriteNode!
    var friendListPage:SKSpriteNode!
    var messagePage:SKSpriteNode!
    var invitePage:SKSpriteNode!
    
    //好友列表物件
    var friendCount:Int!
    var friendCell:SKSpriteNode!
    var touchBeganLocation:CGPoint!
    var touchEndedLocation:CGPoint!
    
    var friendNameLabel:String!
    var friendRankLabel:String!
    var friendPicture:SKSpriteNode!
    
    var friendDetailWindow:SKSpriteNode!
    var friendDetailPicture:SKSpriteNode!
    var friendDeleteBtn:SKSpriteNode!
    var friendDetailMessageBtn:SKSpriteNode!
    var friendDetailCancelBtn:SKSpriteNode!
    var friendDetailNameLabel:SKLabelNode!
    var friendDetailRankLabel:SKLabelNode!
    
    //訊息物件
    var messageCount:Int!
    var messageCell:SKSpriteNode!
    var messageInfo:String!
    var sendMailPage:SKSpriteNode!
    var sendMailPageSendBtn:SKSpriteNode!
    var sendMailPageCancelBtn:SKSpriteNode!
    var readMailPage:SKSpriteNode!
    var readMailPageCloseBtn:SKSpriteNode!
    var readMailPageSendFromLabel:SKLabelNode!
    var readMailPageMessageLabel:SKLabelNode!
    
    //做一個TextField在Scene裡面，輸入訊息用
//    var mailTextView:UITextView!
//    var mailTextField:UITextField = UITextField(frame: CGRect(x: 160, y: 250, width: 180.00, height: 280.00))
    
    //交友邀請物件
    var inviteCount:Int!
    var inviteCell:SKSpriteNode!
    var inviteAcceptBtn:SKSpriteNode!
    var inviteCancelBtn:SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        //self.view!.addSubview(textField)
        //textField.placeholder = "在此輸入訊息"
        //textField.hidden = true
        // Close keyboard
//        backgroundColor = SKColor.redColor()
        
//        let mailTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 330.0, height: 330.0))
//        mailTextView.center = CGPointMake(200.0, 300.0)
//        mailTextView.backgroundColor = UIColor.whiteColor()
//        mailTextView.translatesAutoresizingMaskIntoConstraints = false
//        self.view?.addSubview(mailTextView)
//        mailTextView.hidden = true
//        self.view!.backgroundColor = UIColor.redColor()
//        self.view!.layer.borderWidth = 10;
//        self.view!.layer.borderColor =  UIColor.redColor().CGColor
        
//        mailTextView.delegate = self
        
//        func yourTextView(textView: UITextView!, shouldChangeTextInRange: NSRange, replacementText: NSString!) -> Bool {
//            if (replacementText == "\n")  {
//                mailTextView.resignFirstResponder()
//                return false
//            }
//            return true
//        }
        headers=["token":token]
        //社群系統主畫面按鈕
        returnBtn = childNodeWithName("returnBtn") as! SKSpriteNode
        
        friendListBtn = childNodeWithName("friendListBtn") as! SKSpriteNode
        messagePageBtn = childNodeWithName("messagePageBtn") as! SKSpriteNode
        invitePageBtn = childNodeWithName("invitePageBtn") as! SKSpriteNode
        
        //各種分頁
        background = childNodeWithName("background") as! SKSpriteNode
        friendListPage = childNodeWithName("friendListPage") as! SKSpriteNode
        messagePage = childNodeWithName("messagePage") as! SKSpriteNode
        invitePage = childNodeWithName("invitePage") as! SKSpriteNode
        
        //好友列表物件
        friendCell = childNodeWithName("friendCell") as! SKSpriteNode
//        friendPicture = friendCell.childNodeWithName("friendPicture") as! SKSpriteNode
        self.friendCell.hidden = true
        
        //點擊好友資訊視窗
        friendDetailWindow = childNodeWithName("friendDetailWindow") as! SKSpriteNode
        friendDetailPicture = friendDetailWindow.childNodeWithName("friendDetailPicture") as! SKSpriteNode
        friendDeleteBtn = friendDetailWindow.childNodeWithName("friendDeleteBtn") as! SKSpriteNode
        friendDetailMessageBtn = friendDetailWindow.childNodeWithName("friendDetailMessageBtn") as! SKSpriteNode
        friendDetailCancelBtn = friendDetailWindow.childNodeWithName("friendDetailCancelBtn") as! SKSpriteNode
        friendDetailNameLabel = friendDetailWindow.childNodeWithName("friendDetailNameLabel") as! SKLabelNode
        friendDetailRankLabel = friendDetailWindow.childNodeWithName("friendDetailRankLabel") as! SKLabelNode
        self.friendDetailWindow.hidden = true
        
        //訊息物件
        messageCell = childNodeWithName("messageCell") as! SKSpriteNode
        self.messageCell.hidden = true

        sendMailPage = childNodeWithName("sendMailPage") as! SKSpriteNode
        sendMailPageSendBtn = sendMailPage.childNodeWithName("sendMailPageSendBtn") as! SKSpriteNode
        sendMailPageCancelBtn = sendMailPage.childNodeWithName("sendMailPageCancelBtn") as! SKSpriteNode
        self.sendMailPage.hidden = true
        
        readMailPage = childNodeWithName("readMailPage") as! SKSpriteNode
        readMailPageCloseBtn = readMailPage.childNodeWithName("readMailPageCloseBtn") as! SKSpriteNode
        readMailPageSendFromLabel = readMailPage.childNodeWithName("readMailPageSendFromLabel") as! SKLabelNode
        readMailPageMessageLabel = readMailPage.childNodeWithName("readMailPageMessageLabel") as! SKLabelNode

        self.readMailPage.hidden = true

        //做一個TextField在Scene裡面，輸入訊息用
//        mailTextField = UITextField(frame: CGRect(x: 160, y: 250, width: 180.00, height: 280.00))
//        mailTextField.backgroundColor = UIColor.redColor()
//        self.view?.addSubview(mailTextField)
//        mailTextField.hidden = true

        //交友邀請物件
        inviteCell = childNodeWithName("inviteCell") as! SKSpriteNode
//        inviteAcceptBtn = inviteCell.childNodeWithName("inviteAcceptBtn") as! SKSpriteNode
//        inviteCancelBtn = inviteCell.childNodeWithName("inviteCancelBtn") as! SKSpriteNode
        self.inviteCell.hidden = true
        
        //抓取伺服器好友資料列表
        alamoRequset(friendListURL, headers: headers) { (inner) -> Void in
            do{
                var positionRow = 0
                let result=try inner()
                self.friendCount = result.count
                for i in 0..<result.count {
                    
                    //建立朋友底框
                    let friendCellNew = SKSpriteNode(imageNamed: "friendCell")
                    self.friendCell.addChild(friendCellNew)
                    friendCellNew.name = ("friendCellNew\(i)")
                    friendCellNew.position = CGPoint(x:0, y: 0-(5+friendCellNew.frame.height)*CGFloat(positionRow))
                    friendCellNew.userData = NSMutableDictionary()
                    friendCellNew.userData?.setObject(result[i]["friendId"]!, forKey: "friendId")

                    //朋友大頭貼
                    let friendPictureString = "http://api.leolin.me" + (result[i]["friendPicturePath"]! as! String)
//                    print(friendPictureString)
                    let url = NSURL(string:friendPictureString)
                    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let picData = NSData(contentsOfURL:url!)
                        let picImage = UIImage(data: picData!)
                        if picImage != nil{
                            let picTexture = SKTexture(image: picImage!)
                            let friendPictureNew = SKSpriteNode(texture: picTexture, size: CGSize(width: 80, height: 80))
//                            print(friendCellNew.description)
//                            print(friendPictureNew.description)
                            
                            friendCellNew.addChild(friendPictureNew)
                            friendPictureNew.name = ("friendPictureNew\(i)")
                            friendPictureNew.position = CGPoint(x:-76, y:-2)
                            friendPictureNew.zPosition = -1
                            friendCellNew.userData?.setObject(picImage!, forKey: "friendPicture")
                        }
                        else{
                            //dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            let friendPictureNew = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 1), size: CGSize(width: 80, height: 80))
                            friendCellNew.addChild(friendPictureNew)
                            friendPictureNew.name = ("friendPictureNew\(i)")
                            friendPictureNew.position = CGPoint(x:-76, y:-2)
                            friendPictureNew.zPosition = -1
                            //     })
                        }
//                    })

                    //朋友的暱稱
                    let friendNameLabelNew = SKLabelNode(text: result[i]["friendNickname"]! as? String)
                    
                    friendCellNew.addChild(friendNameLabelNew)
                    friendNameLabelNew.name = ("friendNameLabelNew\(i)")
                    friendNameLabelNew.position = CGPoint(x:50, y: 10)
                    friendNameLabelNew.fontName = (name: "Helvetica Bold")
                    friendNameLabelNew.fontSize = 18.0
                    friendNameLabelNew.fontColor = UIColor.blackColor()
                    friendCellNew.userData?.setObject(result[i]["friendNickname"]!, forKey: "friendNickname")

                    //朋友的排行
                    let friendRankLabelNew = SKLabelNode(text: "排名：" + result[i]["friendRank"]!.stringValue)
                    friendCellNew.addChild(friendRankLabelNew)
                    friendRankLabelNew.name = ("friendRankLabelNew\(i)")
                    friendRankLabelNew.position = CGPoint(x:45, y: -25)
                    friendRankLabelNew.fontName = (name: "Helvetica Bold")
                    friendRankLabelNew.fontSize = 15.0
                    friendRankLabelNew.fontColor = UIColor.grayColor()
                    friendCellNew.userData?.setObject(result[i]["friendRank"]!, forKey: "friendRank")
                    
                    positionRow++
                    if self.friendCount != 0 {
                        self.friendCell.hidden = false
                    }
                }
            }catch let error{
                print(error)
            }
        }
        
        //抓取訊息匣
        alamoRequset(mailListURL,headers: headers){ (inner) -> Void in
            do{
                var positionRow = 0
                let result=try inner()
                self.messageCount = result.count
                for i in 0..<result.count {
                    
                    //建立訊息底框
                    let messageCellNew = SKSpriteNode(imageNamed: "messageCell")
                    self.messageCell.addChild(messageCellNew)
                    
                    messageCellNew.name = ("messageCellNew\(i)")
                    messageCellNew.position = CGPoint(x:0, y: 0-(5+messageCellNew.frame.height)*CGFloat(positionRow))
                    messageCellNew.userData = NSMutableDictionary()
                    messageCellNew.userData?.setObject(result[i]["mailContent"]!, forKey: "mailContent")
                    //寄件人
                    let messageInfo = SKLabelNode(text: "From：" + (result[i]["whoSendYou"]! as? String)!)
                    messageCellNew.addChild(messageInfo)
                    messageInfo.name = ("messageInfo\(i)")
                    messageInfo.position = CGPoint(x:25, y: -8)
                    messageInfo.fontName = (name: "Helvetica Bold")
                    messageInfo.fontSize = 15.0
                    messageInfo.fontColor = UIColor.blackColor()
                    messageCellNew.userData?.setObject(result[i]["whoSendYou"]!, forKey: "whoSendYou")
                    
                    positionRow++
                    self.messageCell.hidden = true
                }
            }catch let error{
                print(error)
            }
        }

        //抓取朋友邀請清單
        alamoRequset(inviteListURL,headers: headers){ (inner) -> Void in
            do{
                var positionRow = 0
                let result=try inner()
                self.inviteCount = result.count
                for i in 0..<result.count {
                    
                    //建立邀請底框
                    let inviteCellNew = SKSpriteNode(imageNamed: "inviteCell")
                    self.inviteCell.addChild(inviteCellNew)
                    
                    inviteCellNew.name = ("inviteCellNew\(i)")
                    inviteCellNew.position = CGPoint(x:0, y: 0-(5+inviteCellNew.frame.height)*CGFloat(positionRow))
                    inviteCellNew.userData = NSMutableDictionary()
                    
                    //邀請人
                    let inviteInfo = SKLabelNode(text: result[i]["friendNickname"]! as? String)
                    inviteCellNew.addChild(inviteInfo)
                    inviteInfo.name = ("inviteInfo\(i)")
                    inviteInfo.position = CGPoint(x:-75, y: 5)
                    inviteInfo.fontName = (name: "Helvetica Bold")
                    inviteInfo.fontSize = 15.0
                    inviteInfo.fontColor = UIColor.blackColor()
                    inviteCellNew.userData?.setObject(result[i]["friendNickname"]!, forKey: "friendNickname")
                    
                    //確認按鈕
                    let inviteAcceptBtn = SKSpriteNode(imageNamed: "inviteAcceptBtn")
                    inviteCellNew.addChild(inviteAcceptBtn)
                    inviteAcceptBtn.name = ("inviteAcceptBtn\(i)")
                    print("inviteacbtn:\(inviteAcceptBtn.name)")
                    inviteAcceptBtn.position = CGPoint(x:35, y:1)
                    inviteAcceptBtn.userData = NSMutableDictionary()
                    print("result\(result[i]["friendId"])")
                    inviteAcceptBtn.userData?.setObject(result[i]["friendId"]!, forKey: "friendId")
                    print(inviteAcceptBtn.userData)
                    
                    positionRow++
                    self.inviteCell.hidden = true
                }
            }catch let error{
                print(error)
            }
        }

    }
    
    //各種觸碰指令
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first
        touchBeganLocation = touch?.locationInNode(self)
        
        if returnBtn.containsPoint(touchBeganLocation!){
            backToMainPage()
        }
        if friendListBtn.containsPoint(touchBeganLocation!){
            showFriendList()
        }
        if messagePageBtn.containsPoint(touchBeganLocation!){
            showMessagePage()
        }
        if invitePageBtn.containsPoint(touchBeganLocation!){
            showInvitePage()
        }
            }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        touchEndedLocation = touch?.locationInNode(self)
        //bird
        let location=touches.first?.locationInNode(self)
        let nodeTouched=nodeAtPoint(location!)
        let nodeTouchedName=nodeTouched.name
        //
        let touchLocationForFriendList = touch?.locationInNode(friendCell)
        let touchLocationForFriendDetailList = touch?.locationInNode(friendDetailWindow)
        let touchLocationForMailList = touch?.locationInNode(messageCell)
        let touchLocationForReadMailPage = touch?.locationInNode(readMailPage)
        let touchLocationForConfirmInvite = touch?.locationInNode(inviteCell)
        //點擊退出好友詳細資訊視窗
        if touchBeganLocation == touchEndedLocation {
            if nodeTouchedName == "friendBattleBtn"{
                if let scene=ArenaMonsterBattleScene(fileNamed: "ArenaMonsterBattleScene"){
                    scene.scaleMode = .Fill
                    scene.userData=NSMutableDictionary()
                scene.userData?.setObject((friendDeleteBtn.userData?.objectForKey("friendId")!)!, forKey: "id")
//                    scene.userData?.setObject(userData?.objectForKey("image") as! UIImage, forKey: "image")
                    scene.userData?.setObject("practice", forKey: "arenaType")
                    scene.userData?.setObject("firend", forKey: "where")
                    view?.presentScene(scene)
                }
            }
            if friendDetailCancelBtn.containsPoint(touchLocationForFriendDetailList!) {
                hideFriendDetail()
        //點擊傳送信件給好友
            }else if friendDetailMessageBtn.containsPoint(touchLocationForFriendDetailList!){
                showSendMailPage(friendDetailMessageBtn)
            }else if sendMailPageCancelBtn.containsPoint(touchLocationForFriendDetailList!){
                hideSendMailPage()
        //點擊刪除好友
            }else if friendDeleteBtn.containsPoint(touchLocationForFriendDetailList!){
                deleteFriend(friendDeleteBtn)
        //點擊好友彈出好友詳細資訊視窗
            }else{
                if background.containsPoint(touchEndedLocation!){
                    for i in friendCell.children {
                        if i.name!.hasPrefix("friendCellNew"){
                            if i.containsPoint(touchLocationForFriendList!) {
                                if self.friendCell.hidden == false {
                                    showFriendDetail(i)
                                }
                            }
                        }
                    }
                }
            }
        }
        //點擊信件彈出信件內容
        if touchBeganLocation == touchEndedLocation {
            if readMailPageCloseBtn.containsPoint(touchLocationForReadMailPage!) {
                hideReadMailPage()
            }else{
                if background.containsPoint(touchEndedLocation!){
                    for i in messageCell.children {
                        if i.name!.hasPrefix("messageCellNew"){
                            if i.containsPoint(touchLocationForMailList!) {
                                if self.messageCell.hidden == false {
                                    showReadMailPage(i)
                                }
                            }
                        }
                    }
                }
            }
        }
        //點擊回應交友邀請
        if touchBeganLocation == touchEndedLocation {
            if inviteCell.hidden == false {
                print(111)
                if background.containsPoint(touchEndedLocation!) {
                    print(222)
//                    if background.containsPoint(touchEndedLocation!){
                        for a in inviteCell.children {
                            if ((a.name?.hasPrefix("inviteCellNew")) != nil) {
                                for b in a.children {
                                   print("b:\(b.name)")
                                    print(333)
                                    if b.name!.hasPrefix("inviteAcceptBtn0") {
                                        if b.containsPoint(touchLocationForConfirmInvite!){
                                            print(b.userData?.objectForKey("friendId"))
                                            friendInviteConfirmYes(b)
                                    }
                                }
                            }
                        }
                    }
                }
//            }else if inviteCancelBtn.containsPoint(touchLocationForConfirmInvite!) {
//                friendInviteConfirmNo()
            }
        }
    }
    
    //滑動改變物件位置
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location=touches.first?.locationInNode(self)
        let range=(location?.y)! - touchBeganLocation.y
        
        //朋友列表滑動捲軸
        if friendCell.hidden == false{
            let objectMoveRange = 0 - (friendCell.childNodeWithName("friendCellNew\(friendCount-1)")?.position.y)! - 3 * friendCell.frame.height
            let changePositionValue = objectMoveRange / CGFloat(friendCount) / 2
            if background.containsPoint(touchBeganLocation) {
                if self.friendCell.hidden == false{
                    if range > 0 {
                        if friendCell.position.y < 440 + objectMoveRange {
                            if friendCount >= 5 {
                                friendCell.position.y += changePositionValue
                            }
                        }
                    }
                    if range < 0 {
                        if friendCell.position.y > 440 {
                            friendCell.position.y -= changePositionValue
                        }else{
                            friendCell.position.y = 440
                        }
                    }
                }
            }
            
        //信件匣滑動捲軸
        }else if messageCell.hidden == false{
            let objectMoveRange = 0 - (messageCell.childNodeWithName("messageCellNew\(messageCount-1)")?.position.y)! - 3 * messageCell.frame.height
            let changePositionValue = objectMoveRange / CGFloat(messageCount) / 2
            if background.containsPoint(touchBeganLocation) {
                if self.messageCell.hidden == false{
                    if range > 0 {
                        if messageCell.position.y < 455 + objectMoveRange {
                            messageCell.position.y += changePositionValue
                        }
                    }
                    if range < 0 {
                        if messageCell.position.y > 455 {
                            messageCell.position.y -= changePositionValue
                        }else{
                            messageCell.position.y=455
                        }
                    }
                }
            }
            
        //邀請列表滑動捲軸
        }else if inviteCell.hidden == false{
            let objectMoveRange = 0 - (inviteCell.childNodeWithName("inviteCellNew\(inviteCount-1)")?.position.y)! - 3 * inviteCell.frame.height
            let changePositionValue = objectMoveRange / CGFloat(inviteCount-1) / 2
            if background.containsPoint(touchBeganLocation) {
                if self.inviteCell.hidden == false{
                    if range > 0 {
                        if inviteCell.position.y < 455 + objectMoveRange {
                            inviteCell.position.y += changePositionValue
                        }
                    }
                    if range < 0 {
                        if inviteCell.position.y > 455 {
                            inviteCell.position.y -= changePositionValue
                        }else{
                            inviteCell.position.y=455
                        }
                    }
                }
            }
        }
    }

    //回到主頁大廳
    func backToMainPage(){
        //print("Btn Clicked!(For test)")
//        if let scene = GameScene(fileNamed: "GameScene") {
//            scene.scaleMode = .Fill
//            let myTransition = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.1)
//            view?.presentScene(scene,transition: myTransition)
//        }
        view?.removeFromSuperview()
    }
    
    //切換至好友列表
    func showFriendList() {
        //print("showFriendList!(For test)")
        friendListPage.zPosition = 3
        messagePage.zPosition = 2
        invitePage.zPosition = 2
        if friendCount != 0 {
            self.friendCell.hidden = false
        }
        self.messageCell.hidden = true
        self.inviteCell.hidden = true
        friendCell.position.y = 440
        messageCell.position.y = 455
        inviteCell.position.y = 455
    }
    
    //切換至訊息頁面
    func showMessagePage() {
        //print("showMessagePage!(For test)")
        friendListPage.zPosition = 2
        messagePage.zPosition = 3
        invitePage.zPosition = 2
        if messageCount != 0 {
            self.messageCell.hidden = false
        }
        self.inviteCell.hidden = true
        self.friendCell.hidden = true
        friendCell.position.y = 440
        messageCell.position.y = 455
        inviteCell.position.y = 455
    }
    
    //切換至交友邀請頁面
    func showInvitePage() {
        //print("showInvitePage!(For test)")
        friendListPage.zPosition = 2
        messagePage.zPosition = 2
        invitePage.zPosition = 3
        if inviteCount != 0 {
            self.inviteCell.hidden = false
        }
        self.friendCell.hidden = true
        self.messageCell.hidden = true
        friendCell.position.y = 440
        messageCell.position.y=455
        inviteCell.position.y=455
        //friendCell.position = CGPoint(x: 160, y: 440)
    }

    //彈出好友資訊視窗方法
    func showFriendDetail(node:SKNode) {
        self.friendDetailWindow.hidden = false
        friendDetailWindow.position = CGPoint(x: 160, y: 285)
        friendDetailPicture.texture = SKTexture(image: (node.userData?.objectForKey("friendPicture"))! as! UIImage)
        friendDetailNameLabel.text = (node.userData?.objectForKey("friendNickname")) as? String
        friendDetailRankLabel.text = "排名：" + ((node.userData?.objectForKey("friendRank"))!.stringValue)
        friendDeleteBtn.userData = NSMutableDictionary()
        friendDeleteBtn.userData?.setObject((node.userData?.objectForKey("friendId"))!, forKey: "friendId")
    }
    func hideFriendDetail() {
        self.friendDetailWindow.hidden = true
        friendDetailWindow.position = CGPoint(x: 450, y: 650)
        
    }
    
    //刪除好友方法
    func deleteConfirm(node:SKNode){
    }
    func deleteFriend(node:SKNode) {
        let id = node.userData?.objectForKey("friendId")?.stringValue
        alamoRequsetUpdate(deleteFriendURL, parameter: ["friendId":id!]) { (inner) -> Void in
        }
        if let scene = SocialScene(fileNamed: "SocialScene") {
            scene.scaleMode = .Fill
            let myTransition = SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 0.1)
            view?.presentScene(scene,transition: myTransition)
        }
    }
    
    //彈出編寫信件頁方法
    func showSendMailPage(node:SKNode) {
        sendMailPage.hidden = false
        sendMailPage.position = CGPoint(x: 160, y: 265)
        //mailTextView.center = CGPointMake(200.0, 300.0)
//        mailTextView.hidden = false
//        let mailTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 330.0, height: 330.0))
        //        CGRect(x: 0, y: 0, width: 330.0, height: 330.0)
//        mailTextView.center = CGPointMake(200.0, 300.0)
        //        CGPointMake(200.0, 300.0)
//        mailTextView.backgroundColor = UIColor.whiteColor()
//        mailTextView.translatesAutoresizingMaskIntoConstraints = false
//        self.view?.addSubview(mailTextView)
        //        mailTextView.hidden = true
        //        self.view!.backgroundColor = UIColor.redColor()
        //        self.view!.layer.borderWidth = 10;
        //        self.view!.layer.borderColor =  UIColor.redColor().CGColor
        
//        mailTextView.delegate = self
        
//        func yourTextView(textView: UITextView!, shouldChangeTextInRange: NSRange, replacementText: NSString!) -> Bool {
//            if (replacementText == "\n")  {
//                mailTextView.resignFirstResponder()
//                return false
//            }
//            return true
//        }
    }
    func hideSendMailPage() {
        sendMailPage.hidden = true
        sendMailPage.position = CGPoint(x: 450, y: 265)
//        mailTextView.hidden = true
//        mailTextView.center = CGPointMake(-300, 265)
    }
    
    //彈出信件內容方法
    func showReadMailPage(node:SKNode) {
        readMailPage.hidden = false
        readMailPage.position = CGPoint(x: 160, y: 265)
        readMailPageSendFromLabel.text = "From：" + ((node.userData?.objectForKey("whoSendYou"))! as! String)
        readMailPageMessageLabel.text = (node.userData?.objectForKey("mailContent"))! as? String
    }
    func hideReadMailPage() {
        readMailPage.hidden = true
        readMailPage.position = CGPoint(x: -135, y: 265)
    }

    //回應交友邀請
    func friendInviteConfirmYes(node:SKNode) {
        let id = (node.userData?.objectForKey("friendId"))?.stringValue
        print(id)
        print(node.userData?.objectForKey("friendId"))
        alamoRequsetUpdate(confirmInvitedURL, parameter: ["friendId":id!]) { (inner) -> Void in
        }
        if let scene = SocialScene(fileNamed: "SocialScene") {
            scene.scaleMode = .Fill
            let myTransition = SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 0.1)
            view?.presentScene(scene,transition: myTransition)
        }
    }
    func friendInviteConfirmNo() {
        
    }

    //第三方存取伺服器資料方法
    func alamoRequset(URL:String,headers:[String:String],completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
        Alamofire.request(.POST, URL, headers: headers).responseJSON { (response) -> Void in
            let swiftyJsonVar=JSON(response.result.value!)
            print(swiftyJsonVar)
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
    
}
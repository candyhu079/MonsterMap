//
//  SocialScene.swift
//  MonsterMap
//
//  Created by 羅崇寧 on 2016/2/25.
//  Copyright © 2016年 Charlie Luo. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

import Alamofire
import AlamofireImage
import SwiftyJSON
class SocialScene: SKScene {
    
    //資料庫連結
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
//    let headers = ["token":"5566"]
    let friendListURL = "http://api.leolin.me/friendList"
    let mailListURL = "http://api.leolin.me/receiveMail"
    let inviteListURL = "http://api.leolin.me/beInvitedList"
    let deleteFriendURL = "http://api.leolin.me/deleteFriend"
    let confirmInvitedURL = "http://api.leolin.me/confirmInvited"
    let sendMailURL = "http://api.leolin.me/sendMail"
    
//    let friendListURL = "http://192.168.196.48:8080/friendList"
//    let mailListURL = "http://192.168.196.48:8080/receiveMail"
//    let inviteListURL = "http://192.168.196.48:8080/beInvitedList"
//    let deleteFriendURL = "http://192.168.196.48:8080/deleteFriend"
//    let confirmInvitedURL = "http://192.168.196.48:8080/confirmInvited"
//    let sendMailURL = "http://192.168.196.48:8080/sendMail"
    
    
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
    var sendMailToLabel:SKLabelNode!
    var sendMailPageSendBtn:SKSpriteNode!
    var sendMailPageCancelBtn:SKSpriteNode!
    var readMailPage:SKSpriteNode!
    var readMailPageCloseBtn:SKSpriteNode!
    var readMailPageSendFromLabel:SKLabelNode!
    var readMailPageMessageLabel:SKLabelNode!
    
    //做一個TextView，輸入訊息傳信用
    var mailTextView:UITextView!
    
    //交友邀請物件
    var inviteCount:Int!
    var inviteCell:SKSpriteNode!
    
    var timer = NSTimer()
    
    var voicePlayer:AVAudioPlayer!
    
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
        friendCell.position.y = 440 //加了這行位置之後解決了第一次進好友列表畫面滾動指令錯亂的情況
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
        sendMailToLabel = sendMailPage.childNodeWithName("sendMailToLabel") as! SKLabelNode
        sendMailPageSendBtn = sendMailPage.childNodeWithName("sendMailPageSendBtn") as! SKSpriteNode
        sendMailPageCancelBtn = sendMailPage.childNodeWithName("sendMailPageCancelBtn") as! SKSpriteNode
        self.sendMailPage.hidden = true
        
        readMailPage = childNodeWithName("readMailPage") as! SKSpriteNode
        readMailPageCloseBtn = readMailPage.childNodeWithName("readMailPageCloseBtn") as! SKSpriteNode
        readMailPageSendFromLabel = readMailPage.childNodeWithName("readMailPageSendFromLabel") as! SKLabelNode

        self.readMailPage.hidden = true

        //交友邀請物件
        inviteCell = childNodeWithName("inviteCell") as! SKSpriteNode
        self.inviteCell.hidden = true
        
        //Loading Animate
        let loadingAnimate = childNodeWithName("loadingImage") as! SKSpriteNode
        let step1 = SKTexture(imageNamed: "loadingImage")
        let step2 = SKTexture(imageNamed: "loadingImage2")
        let step3 = SKTexture(imageNamed: "loadingImage3")
        let step4 = SKTexture(imageNamed: "loadingImage4")
        let action1 = SKAction.animateWithTextures([step1,step2,step3,step4], timePerFrame: 0.2)
        let loadAction = SKAction.repeatActionForever(action1)
        loadingAnimate.runAction(loadAction)
        
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

        //抓取伺服器好友資料列表
        self.alamoRequset(self.friendListURL, headers: self.headers) { (inner) -> Void in
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
                    let url = NSURL(string:friendPictureString)
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let picData = NSData(contentsOfURL:url!)
                        let picImage = UIImage(data: picData!)
                        if picImage != nil{
                            let picTexture = SKTexture(image: picImage!)
                            let friendPictureNew = SKSpriteNode(texture: picTexture, size: CGSize(width: 80, height: 80))
                            
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
                    //if friend button pressed
                    if self.userData?.objectForKey("fromWhere") as! String == "friendButtonPressed"{
                    if self.friendCount != 0 {
                        self.friendCell.hidden = false
                        loadingAnimate.hidden = true
                    }
                    }
                }
            }catch let error{
                print(error)
            }
        }
        
        //抓取訊息匣
        self.alamoRequset(self.mailListURL,headers: self.headers){ (inner) -> Void in
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
                //if mail button pressed
                if self.userData?.objectForKey("fromWhere") as! String == "mailButtonPressed"{
                    self.showMessagePage()
                    loadingAnimate.hidden = true
                }
            }catch let error{
                print(error)
            }
        }

        //抓取朋友邀請清單
        self.alamoRequset(self.inviteListURL,headers: self.headers){ (inner) -> Void in
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
                    inviteAcceptBtn.position = CGPoint(x:35, y:1)
                    inviteAcceptBtn.userData = NSMutableDictionary()
                    inviteAcceptBtn.userData?.setObject(result[i]["friendId"]!, forKey: "friendId")
                    print(inviteAcceptBtn.frame)
                    
                    //取消按鈕
                    let inviteCancelBtn = SKSpriteNode(imageNamed: "inviteCancelBtn")
                    inviteCellNew.addChild(inviteCancelBtn)
                    inviteCancelBtn.name = ("inviteCancelBtn\(i)")
                    inviteCancelBtn.position = CGPoint(x:104, y:1)
                    inviteCancelBtn.userData = NSMutableDictionary()
                    inviteCancelBtn.userData?.setObject(result[i]["friendId"]!, forKey: "friendId")
                    
                    positionRow++
                    self.inviteCell.hidden = true
                }
            }catch let error{
                print(error)
            }
        }
//        })
//                loadingAnimate.hidden = true
    }
    
    //各種觸碰指令
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Candy Add
        SoundEffect.shareSound().playSoundEffect(voicePlayer)
        
        /* Called when a touch begins */
        self.view!.endEditing(true)
        if sendMailPage.hidden == false {
            self.view!.endEditing(true)
        }
        let touch = touches.first
        touchBeganLocation = touch?.locationInNode(self)
        
        if returnBtn.containsPoint(touchBeganLocation!){
            if friendDetailWindow.hidden == true {
                if readMailPage.hidden == true {
                    backToMainPage()
                }
            }
        }
        if friendListBtn.containsPoint(touchBeganLocation!){
            if readMailPage.hidden == true {
                showFriendList()
            }
        }
        if messagePageBtn.containsPoint(touchBeganLocation!){
            if friendDetailWindow.hidden == true {
                showMessagePage()
            }
        }
        if invitePageBtn.containsPoint(touchBeganLocation!){
            if friendDetailWindow.hidden == true {
                if readMailPage.hidden == true {
                    showInvitePage()
                }
            }
        }
            }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        touchEndedLocation = touch?.locationInNode(self)
        let touchLocationForFriendList = touch?.locationInNode(friendCell)
        let touchLocationForFriendDetailList = touch?.locationInNode(friendDetailWindow)
        let touchLocationForMailList = touch?.locationInNode(messageCell)
        let touchLocationForReadMailPage = touch?.locationInNode(readMailPage)
        let touchLocationForConfirmInvite = touch?.locationInNode(inviteCell)
        let nodeTouched=nodeAtPoint(touchEndedLocation)
        let nodeTouchedName=nodeTouched.name
        //點擊退出好友詳細資訊視窗
        if touchBeganLocation == touchEndedLocation {
            if nodeTouchedName == "friendBattleBtn"{
                if let scene=ArenaMonsterBattleScene(fileNamed: "ArenaMonsterBattleScene"){
                    scene.scaleMode = .Fill
                    scene.userData=NSMutableDictionary()
                    scene.userData?.setObject((friendDeleteBtn.userData?.objectForKey("friendId"))!, forKey: "id")
//                    scene.userData?.setObject(userData?.objectForKey("image") as! UIImage, forKey: "image")
                    scene.userData?.setObject("practice", forKey: "arenaType")
                    scene.userData?.setObject("friend", forKey: "where")
                    view?.presentScene(scene)
                }
                
            }else if friendDetailCancelBtn.containsPoint(touchLocationForFriendDetailList!) {
                hideFriendDetail()
        //點擊傳送信件給好友
            }else if friendDetailMessageBtn.containsPoint(touchLocationForFriendDetailList!){
                showSendMailPage(friendDetailMessageBtn)
            }else if sendMailPageCancelBtn.containsPoint(touchLocationForFriendDetailList!){
                hideSendMailPage()
            }else if sendMailPageSendBtn.containsPoint(touchLocationForFriendDetailList!){
                sendingMailToFriend()
        //點擊刪除好友
            }else if friendDeleteBtn.containsPoint(touchLocationForFriendDetailList!){
                if sendMailPage.hidden == true{
                    deleteFriend(friendDeleteBtn)
                }
        //點擊好友彈出好友詳細資訊視窗
            }else{
                if background.containsPoint(touchEndedLocation!){
                    for i in friendCell.children {
                        if i.name!.hasPrefix("friendCellNew"){
                            if i.containsPoint(touchLocationForFriendList!) {
                                if self.friendCell.hidden == false {
                                    if friendDetailWindow.hidden == true {
                                        showFriendDetail(i)
                                    }
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
                                    if readMailPage.hidden == true {
                                        showReadMailPage(i)
                                    }
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
                if background.containsPoint(touchEndedLocation!) {
                        for a in inviteCell.children {
                            if ((a.name?.hasPrefix("inviteCellNew")) != nil) {
                                for b in a.children {
                                    if b.name!.hasPrefix("inviteAcceptBtn") {
                                        if b.containsPoint((touch?.locationInNode(b))!){
                                            friendInviteConfirmYes(b)
                                        }
                                    }else if b.name!.hasPrefix("inviteCancelBtn") {
                                        if b.containsPoint((touch?.locationInNode(b))!){
                                            friendInviteConfirmNo(b)
                                        }
                                    }
                                }
                            }
                        }
                }
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
            let changePositionValue = objectMoveRange / CGFloat(friendCount-1) / 2
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
                            if messageCount >= 7 {
                                messageCell.position.y += changePositionValue
                            }
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
                            if inviteCount >= 7 {
                                inviteCell.position.y += changePositionValue
                            }
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
        /*
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .Fill
            let myTransition = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.1)
            view?.presentScene(scene,transition: myTransition)
        }
        */
        view?.removeFromSuperview()
    }
    
    //切換至好友列表
    func showFriendList() {
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
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: false)
    }
    
    //彈出編寫信件頁方法
    func showSendMailPage(node:SKNode) {
        sendMailPage.hidden = false
        sendMailPage.position = CGPoint(x: 160, y: 265)

        let screemSize = UIScreen.mainScreen().applicationFrame
        let screemWidth = screemSize.size.width
        let screemHeight = screemSize.size.height
        
        sendMailToLabel.text = "To：" + (friendDetailNameLabel.text)!

        mailTextView = UITextView(frame: CGRect(x: 0, y: 0, width: screemWidth*0.56 , height: screemHeight*0.35))
        mailTextView.center = CGPointMake(screemWidth/2, screemHeight/2)
        mailTextView.backgroundColor = UIColor.clearColor()
        mailTextView.translatesAutoresizingMaskIntoConstraints = false
        self.view?.addSubview(mailTextView)
    }
    func hideSendMailPage() {
        sendMailPage.hidden = true
        sendMailPage.position = CGPoint(x: 450, y: 265)
//        mailTextView.hidden = true
        mailTextView.removeFromSuperview()
    }
    
    //彈出信件內容方法
    func showReadMailPage(node:SKNode) {
        readMailPage.hidden = false
        readMailPage.position = CGPoint(x: 160, y: 265)
        readMailPageSendFromLabel.text = "From：" + ((node.userData?.objectForKey("whoSendYou"))! as! String)
        //隱藏預設信件內容位置的SKLabelNode
        for a in readMailPage.children{
            if a.name!.hasPrefix("readMailPageMessageLabel") {
                a.hidden = true
            }
        }
        //把取到的信件內容轉成陣列
        let mailContentText = Array((node.userData?.objectForKey("mailContent") as? String)!.characters)
        
        //把字分給預設信件內容的node，每個最多分12個字
        let totalLines = (mailContentText.count/12)+1
        var wordCount = 0
        
        for i in 0..<totalLines{
            var linesLength = 0
            var linesString:String=""
            while linesLength<11 {
                if wordCount == mailContentText.count {
                    break
                }
                linesString = linesString+String(mailContentText[wordCount])
                linesLength = linesString.characters.count
                wordCount++
            }
            let label=readMailPage.childNodeWithName("readMailPageMessageLabel\(i)") as! SKLabelNode
            label.hidden=false
            label.text=linesString
        }
    }
    func hideReadMailPage() {
        readMailPage.hidden = true
        readMailPage.position = CGPoint(x: -135, y: 265)
    }
    
    //寄信給朋友
    func sendingMailToFriend() {
        let id = (friendDeleteBtn.userData?.objectForKey("friendId"))?.stringValue
        let mailContent = mailTextView.text
        alamoRequsetUpdate(sendMailURL, parameter: ["targetUserId":id!,"mailContent":mailContent]) { (inner) -> Void in
        }
        hideSendMailPage()
    }

    //回應交友邀請
    func friendInviteConfirmYes(node:SKNode) {
        let id = (node.userData?.objectForKey("friendId"))?.stringValue
        alamoRequsetUpdate(confirmInvitedURL, parameter: ["friendId":id!]) { (inner) -> Void in
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: false)
    }
    func friendInviteConfirmNo(node:SKNode) {
        let id = (node.userData?.objectForKey("friendId"))?.stringValue
        alamoRequsetUpdate(confirmInvitedURL, parameter: ["friendId":id!]) { (inner) -> Void in
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: false)
    }
    
    //刷新列表資料
    func updateTime() {
        if let scene = SocialScene(fileNamed: "SocialScene") {
            scene.scaleMode = .Fill
            scene.userData=NSMutableDictionary()
            scene.userData?.setObject("friendButtonPressed", forKey: "fromWhere")
            let myTransition = SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 0.1)
            view?.presentScene(scene,transition: myTransition)
        }
    }

    //第三方存取伺服器資料方法
    func alamoRequset(URL:String,headers:[String:String],completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
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
    
}
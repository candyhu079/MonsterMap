//
//  GameViewController.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/1/14.
//  Copyright (c) 2016年 Shangen. All rights reserved.
//

import UIKit
import SpriteKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreData

class GameViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var MapBackButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var mapBackButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var map: MKMapView!

    let userPhoneWidth=UIScreen.mainScreen().bounds.width
    let userPhoneHeight=UIScreen.mainScreen().bounds.height
    var location:CLLocationManager!
    var withinRange:Bool!
    var headers:[String:String]!
    let token = Player.playerSingleton().userToken
    var monsterInfoType=[String:String]()
    var monsterNameToDetectRepeat:[String]=["name"]
    var downloading=false
    var firstAskMonster=true
    var firstAskOtherUser=true
    var allowFightDistance:Double = 350
    var lastGotOtherUser:CLLocation!
    let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext:NSManagedObjectContext!
    var monsterImage:[MonsterImage] = []
    var monsterLocation:[MonsterLocation]=[]
    var imageDataSendToCallout:NSData!
    // 初始化
    var userDefault = NSUserDefaults.standardUserDefaults()
//    var i=0
    var toSetAnnotationImage:[String:UIImage]=["a":UIImage(named: "otherUserAnnotation")!]
    enum URL:String{
        case UpdateLocation="http://api.leolin.me/updateLocation"
        case AnotherUserNearToYou="http://api.leolin.me/anotherUserNearToYou"
        case URLBegining="http://api.leolin.me"
    }

    @IBAction func mapBackButtonPressed(sender: AnyObject) {
//        if let scene=MonsterHandbookScene(fileNamed: "MonsterHandbookScene"){
//            scene.scaleMode = .Fill
//            let addSubView:SKView=SKView(frame: CGRect(x: 0, y: 0, width: userPhoneWidth, height: userPhoneHeight))
//            addSubView.backgroundColor=UIColor(white: 1, alpha: 0)
//            self.view.addSubview(addSubView)
//            addSubView.presentScene(scene)
//        }
        let tvc = view?.nextResponder()?.nextResponder() as! ThreeIslandsViewController
        let vc = tvc.presentingViewController as! ViewController
        tvc.mapVoicePlayer.stop()
        Music.shareMusic().playMusic(vc.voicePlayer)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext=appDelegate.managedObjectContext
        headers=["token":token]
        mapBackButtonWidth.constant=userPhoneWidth/9.14
        MapBackButtonHeight.constant=userPhoneWidth/9.14*0.85
        location=CLLocationManager()
        location.requestWhenInUseAuthorization()
        location.delegate=self
        map.delegate=self
//        map.tintColor=UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        location.desiredAccuracy=kCLLocationAccuracyBest
        location.distanceFilter=CLLocationDistance(10)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteAnnotation:", name: "deleteAnnotation", object: nil)
        location.startUpdatingLocation()        
    }
    func deleteAnnotation(notify:NSNotification){
        let annotation:MKAnnotation=notify.object as! MKAnnotation
        map.removeAnnotation(annotation)
        for a in monsterLocation{
            if a.latitude==annotation.coordinate.latitude && a.longitude==annotation.coordinate.longitude{
                managedObjectContext.deleteObject(a)
                do{
                    try managedObjectContext.save()
                }catch{
                    fatalError("Failure to save context: \(error)")
                }
            }
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var returnAnnotationView:MKAnnotationView?
        if annotation is MonsterAnnotation{
                returnAnnotationView=MonsterAnnotation.createViewAnnotationForMapView(mapView: self.map, annotation: annotation, identifier: "monsterAnnotation")
//            let monsterCalloutButton=UIButton(type:UIButtonType.DetailDisclosure)
//                        monsterCalloutButton.addTarget(self, action: "monsterCalloutButtonAction:" , forControlEvents: UIControlEvents.TouchUpInside)
//            let imageView=UIImageView(frame: CGRect(x: 0, y: 0, width: userPhoneWidth/10, height: userPhoneWidth/10))
//            imageView.image=UIImage(named: "sugarApple")
//            returnAnnotationView!.rightCalloutAccessoryView=monsterCalloutButton
//            returnAnnotationView!.leftCalloutAccessoryView=imageView
            
        }else if annotation is OtherUserAnnotation{
            returnAnnotationView=OtherUserAnnotation.createViewAnnotationForMapView(mapView: self.map, annotation: annotation, identifier: "otherUserAnnotation")
        }
        
        return returnAnnotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotationLocation=CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        let distanceFromUser=annotationLocation.distanceFromLocation(map.userLocation.location!)
        if distanceFromUser < allowFightDistance{
            withinRange=true
        }else{
            withinRange=false
        }
        if view.annotation is MonsterAnnotation{
        for b in monsterImage{
            if b.name! == view.annotation!.title!!{
                let imageView=UIImageView(frame: CGRect(x: 0, y: 0, width: userPhoneWidth/10, height: userPhoneWidth/10))
                imageView.image=UIImage(data: b.picture!)
                view.leftCalloutAccessoryView=imageView
                imageDataSendToCallout=b.picture!
                break
            }
        }
        }else if view.annotation is OtherUserAnnotation{
            let imageView=UIImageView(frame: CGRect(x: 0, y: 0, width: userPhoneWidth/10, height: userPhoneWidth/10))

            imageView.image=toSetAnnotationImage["\((view.annotation as! OtherUserAnnotation).otherUserID!)"]
            view.leftCalloutAccessoryView=imageView
        }
//        print(distanceFromUser)
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.annotation is MonsterAnnotation{
        let title=view.annotation?.title
        let subtitle:String=((view.annotation?.subtitle)!)!
        let subtitleArray=Array(subtitle.characters)
        var lvStringToPass=""
        for i in 2..<subtitleArray.count{
            lvStringToPass += String(subtitleArray[i])
        }
        let theAnnotation=view.annotation
        let monsterType=monsterInfoType[title!!]!
        if let scene=MonsterCalloutInfoScene(fileNamed: "MonsterCalloutInfoScene"){
            let addSubView:SKView=SKView(frame: CGRect(x: 0, y: 0, width: userPhoneWidth, height: userPhoneHeight))
            addSubView.backgroundColor=UIColor(white: 1, alpha: 0)
            self.view.addSubview(addSubView)
            scene.scaleMode = .Fill
            scene.userData=NSMutableDictionary()
            scene.userData?.setObject(monsterType, forKey: "type")
            scene.userData?.setObject(lvStringToPass, forKey: "level")
            scene.userData?.setObject(title!!, forKey: "name")
            scene.userData?.setObject(withinRange, forKey: "withinRange")
            scene.userData?.setObject(imageDataSendToCallout, forKey: "image")
            scene.userData?.setObject(theAnnotation!, forKey: "annotation")
            addSubView.presentScene(scene)
        }
        }else if view.annotation is OtherUserAnnotation{
            let title=view.annotation?.title
            let subtitle:String=((view.annotation?.subtitle)!)!
//            let subtitleArray=Array(subtitle.characters)
//            var lvStringToPass=""
//            for i in 2..<subtitleArray.count{
//                lvStringToPass += String(subtitleArray[i])
//            }
//            let theAnnotation=view.annotation
            let theId:Int=(view.annotation as! OtherUserAnnotation).otherUserID!
            if let scene=OtherUserCalloutInfoScene(fileNamed: "OtherUserCalloutInfoScene"){
                let addSubView:SKView=SKView(frame: CGRect(x: userPhoneWidth*0.1, y: (userPhoneHeight-userPhoneWidth*0.8*1.29)/2, width: userPhoneWidth*0.8, height: userPhoneWidth*0.8*1.29))
                addSubView.backgroundColor=UIColor(white: 1, alpha: 0)
                self.view.addSubview(addSubView)
                scene.scaleMode = .Fill
                scene.userData=NSMutableDictionary()
                scene.userData?.setObject(subtitle, forKey: "level")
                scene.userData?.setObject(title!!, forKey: "name")
//                scene.userData?.setObject(withinRange, forKey: "withinRange")
                scene.userData?.setObject(toSetAnnotationImage["\((view.annotation as! OtherUserAnnotation).otherUserID!)"]!, forKey: "image")
                scene.userData?.setObject(theId, forKey: "id")
                addSubView.presentScene(scene)
            }
        }
    }
//    func monsterCalloutButtonAction(sender:UIButton){
//        if let scene=MonsterCalloutInfoScene(fileNamed: "MonsterCalloutInfoScene"){
//            let addSubView:SKView=SKView(frame: CGRect(x: userPhoneWidth*0.1, y: (userPhoneHeight-userPhoneWidth*0.8*1.29)/2, width: userPhoneWidth*0.8, height: userPhoneWidth*0.8*1.29))
//            addSubView.backgroundColor=UIColor(white: 1, alpha: 0)
//            self.view.addSubview(addSubView)
//        scene.scaleMode = .Fill
//            scene.userData=NSMutableDictionary()
//            scene.userData?.setObject(withinRange, forKey: "withinRange")
//            addSubView.presentScene(scene)
//        }
//    }
    func monsterCalloutInfoViewHide(notification:NSNotification){
    }
    override func viewDidAppear(animated: Bool) {
    }
    override func viewDidDisappear(animated: Bool) {
//        print("stopUpdatingLocation")
        userDefault.synchronize()
        location.stopUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("startupdating locations")
//        i++
//        print("i=\(i)")
        let userLocation=locations.last!
//        print("userLocation\(userLocation)")
//        print(".horizontalAccuracy\(userLocation.horizontalAccuracy)")
        let userCoordinate=CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        //設顯示範圍
        let span=MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        map.setRegion(MKCoordinateRegion(center: userCoordinate, span: span), animated: false)
        //畫圈
        map.addOverlay(MKCircle(centerCoordinate: userCoordinate, radius: allowFightDistance))
        if map.overlays.count > 1{
        map.removeOverlay(map.overlays.first!)
        }
        //拿地圖怪
        if userLocation.horizontalAccuracy < 100 && userLocation.horizontalAccuracy > 0{
        if let userLatitude:Double=userDefault.objectForKey("userLatitude") as? Double, let userLongitude:Double=userDefault.objectForKey("userLongitude") as? Double{
            let userGotMonsterLocation=CLLocation(latitude: userLatitude, longitude: userLongitude)
//            print("userDefault la\(userLatitude)lo\(userLongitude)")
//            print("userGotMonsterLocation.distanceFromLocation(userLocation)\(userGotMonsterLocation.distanceFromLocation(userLocation))")
            if userGotMonsterLocation.distanceFromLocation(userLocation)>500{
                for a in map.annotations{
                    if a is MonsterAnnotation{
                        map.removeAnnotation(a)
                    }
                }
                //update userdefault coordinate
                userDefault.setDouble(userLocation.coordinate.latitude, forKey: "userLatitude")
                userDefault.setDouble(userLocation.coordinate.longitude, forKey: "userLongitude")
//        print("got monster location from server")
                //上網拿資料
                firstAskMonster=false
                let userLocationParameter=["latitude":"\(userLocation.coordinate.latitude)","longitude":"\(userLocation.coordinate.longitude)"]
//                print(userLocationParameter)
                askForMonsterLocationFromServer(URL.UpdateLocation.rawValue, parameter: userLocationParameter)
            }else{
                if firstAskMonster{
                    firstAskMonster=false
//                    print("got monster location from coredata")
                    //coredata拿資料
                    askForLocationFromCoredata()
                }
            }
        }else{
            //上網拿資料
//            print("userdefaults are nil")
            userDefault.setDouble(userLocation.coordinate.latitude, forKey: "userLatitude")
            userDefault.setDouble(userLocation.coordinate.longitude, forKey: "userLongitude")
            let userLocationParameter=["latitude":"\(userLocation.coordinate.latitude)","longitude":"\(userLocation.coordinate.longitude)"]
            askForMonsterLocationFromServer(URL.UpdateLocation.rawValue, parameter: userLocationParameter)
            
        }
        //拿地圖人
        if firstAskOtherUser{
            firstAskOtherUser=false
            //上網拿資料
            for a in map.annotations{
                if a is OtherUserAnnotation{
                    map.removeAnnotation(a)
                }
            }
            let userLocationParameter=["latitude":"\(userLocation.coordinate.latitude)","longitude":"\(userLocation.coordinate.longitude)"]
            lastGotOtherUser=userLocation
            askForOtherUserLocationFromServer(URL.AnotherUserNearToYou.rawValue, parameter: userLocationParameter)

        }else if userLocation.distanceFromLocation(lastGotOtherUser)>100{
            //上網拿資料
            for a in map.annotations{
                if a is OtherUserAnnotation{
                    map.removeAnnotation(a)
                }
            }
            let userLocationParameter=["latitude":"\(userLocation.coordinate.latitude)","longitude":"\(userLocation.coordinate.longitude)"]
            lastGotOtherUser=userLocation
            askForOtherUserLocationFromServer(URL.AnotherUserNearToYou.rawValue, parameter: userLocationParameter)
        }
        }
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle=MKCircleRenderer(circle: overlay as! MKCircle)
        circle.fillColor=UIColor.redColor()
        circle.alpha=0.1
        return circle
    }
    func alamoRequest(URL:String,parameter:[String:AnyObject],completion: (inner: () throws -> [[String:AnyObject]]) -> Void) -> Void {
        Alamofire.request(.POST, URL,parameters: parameter, headers: headers,encoding:.JSON).responseJSON { (response) -> Void in
            switch response.result{
            case .Success:
            let swiftyJsonVar=JSON(response.result.value!)
            
            if let jsonResult=swiftyJsonVar["result"].arrayObject{
                let monsterJSON=jsonResult as! [[String:AnyObject]]
                completion(inner: {return monsterJSON})
            }
//            else{
//                print("lalala")
//                completion(inner: {[["name":"byebye"]] })
//            
//            }
                
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
//                    print("image downloaded: \(image)")
                    completion(inner: {return image})
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    func somethingAboutImage(theAnnotationTitle:String,thePicturePath:String){
        let moc=self.managedObjectContext
        let monsterImageFetch=NSFetchRequest(entityName: "MonsterImage")
        var fetchError:NSError?=nil
        var coreDataHasImage=false
        do{
            let fetchCount=moc.countForFetchRequest(monsterImageFetch, error: &fetchError)
            if fetchCount>0{
                self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
                for b in self.monsterImage{
                    if b.name! == theAnnotationTitle && b.picturePath! != thePicturePath{
//                        print("delete")
                        moc.deleteObject(b)
                        do{
                            try moc.save()
                        }catch{
                            fatalError("Failure to save context: \(error)")
                        }
                        break
                    }else if b.name! == theAnnotationTitle && b.picturePath! == thePicturePath {
                        coreDataHasImage=true
                        break
                    }
                }
            }
            if coreDataHasImage==false{
            if self.monsterNameToDetectRepeat.contains(thePicturePath) == false{
                self.monsterNameToDetectRepeat.append(thePicturePath)
                self.alamoImageRequset(thePicturePath, completion: { (inner) -> Void in
                    do{
                        let image = try inner()
                        
                        let saveMonsterImage=NSEntityDescription.insertNewObjectForEntityForName("MonsterImage", inManagedObjectContext: moc) as! MonsterImage
                        saveMonsterImage.name=theAnnotationTitle
                        saveMonsterImage.picture=UIImagePNGRepresentation(image)
                        saveMonsterImage.picturePath=thePicturePath
                        do{
//                            print("儲存\(theAnnotationTitle)的image")
                            try moc.save()
                            self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
                        }catch{
                            fatalError("Failure to save context: \(error)")
                        }
                    }catch let error{
                        print(error)
                    }
                })
                }}
        }catch{
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func somethingAboutImageForOtherUser(theOtherUserID:String,thePicturePath:String){
        self.alamoImageRequset(thePicturePath, completion: { (inner) -> Void in
            do{
                let image = try inner()
                self.toSetAnnotationImage.updateValue(image, forKey: theOtherUserID)
            }catch let error{
                print(error)
            }
        })
    }
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait,UIInterfaceOrientationMask.PortraitUpsideDown]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    func askForMonsterLocationFromServer(URL:String,parameter:[String:AnyObject]){
        alamoRequest(URL, parameter: parameter) { (inner) -> Void in
            do{
                
                let result=try inner()
                let moc=self.managedObjectContext
                let monsterLocationFetch=NSFetchRequest(entityName: "MonsterLocation")
//                    print(result.count)
//                    print("delete old coredata data")
                    self.monsterLocation=try moc.executeFetchRequest(monsterLocationFetch) as! [MonsterLocation]
                    for c in self.monsterLocation{
                        moc.deleteObject(c)
                    }
                    
                    do{
                        try moc.save()
                    }catch{
                        fatalError("Failure to save context: \(error)")
                    }
                    for i in 0..<result.count{
                        let name:String=result[i]["name"]! as! String
                        self.somethingAboutImage(name, thePicturePath: result[i]["picturePath"]! as! String)
                        let randomLevel=Int(arc4random_uniform(40))+1
                        let monster=MonsterAnnotation(monsterCoordinate: CLLocationCoordinate2D(latitude: result[i]["latitude"]!.doubleValue, longitude: result[i]["longitude"]!.doubleValue), monsterName: name, monsterLevel: "LV\(randomLevel)")
                        self.monsterInfoType.updateValue((result[i]["type"] as! String), forKey: name)
                        self.map.addAnnotation(monster)
                        let saveMonsterLocation=NSEntityDescription.insertNewObjectForEntityForName("MonsterLocation", inManagedObjectContext: moc) as! MonsterLocation
                        saveMonsterLocation.name=name
                        saveMonsterLocation.level="\(randomLevel)"
                        saveMonsterLocation.type=result[i]["type"]! as? String
                        saveMonsterLocation.latitude=result[i]["latitude"]!.doubleValue
                        saveMonsterLocation.longitude=result[i]["longitude"]!.doubleValue
                        do{
                            try moc.save()
                        }catch{
                            fatalError("Failure to save context: \(error)")
                        }
                    }
            }catch let error{
                print(error)
            }
        }
    }
    func askForLocationFromCoredata(){
        do{
        let moc=self.managedObjectContext
        let monsterLocationFetch=NSFetchRequest(entityName: "MonsterLocation")
        let monsterImageFetch=NSFetchRequest(entityName: "MonsterImage")
        self.monsterLocation=try moc.executeFetchRequest(monsterLocationFetch) as! [MonsterLocation]
        self.monsterImage=try moc.executeFetchRequest(monsterImageFetch) as! [MonsterImage]
        for c in self.monsterLocation{
            let monster=MonsterAnnotation(monsterCoordinate: CLLocationCoordinate2D(latitude: c.latitude!.doubleValue, longitude: c.longitude!.doubleValue), monsterName: c.name!, monsterLevel: "LV\(c.level!)")
            self.monsterInfoType.updateValue(c.type!, forKey: c.name!)
            self.map.addAnnotation(monster)
        }
        }catch let error{
            print(error)
        }
    }
    func askForOtherUserLocationFromServer(URL:String,parameter:[String:AnyObject]){
        alamoRequest(URL, parameter: parameter) { (inner) -> Void in
            do{
                
                let result=try inner()
//                print(result.count)
                for i in 0..<result.count{
                    let name:String=result[i]["nickname"]! as! String
                    let rank:Int=(result[i]["rank"]?.integerValue)!
                    let userID:Int=(result[i]["id"]?.integerValue)!
                    let monster=OtherUserAnnotation(monsterCoordinate: CLLocationCoordinate2D(latitude: result[i]["locationLatitude"]!.doubleValue, longitude: result[i]["locationLongitude"]!.doubleValue), monsterName: name, monsterLevel: "排名：\(rank)",userID:userID)
                    self.somethingAboutImageForOtherUser(String(userID), thePicturePath: result[i]["picture"]! as! String)
                    self.map.addAnnotation(monster)
                }
            }catch let error{
                print(error)
            }
        }
    }
}

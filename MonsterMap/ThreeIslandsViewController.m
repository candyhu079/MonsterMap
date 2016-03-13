//
//  ThreeIslandsViewController.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/1/18.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ThreeIslandsViewController.h"
#import "Player.h"
#import "Items.h"
#import <SpriteKit/SpriteKit.h>
#import "MonsterMap-Swift.h"
#import "ViewController.h"
#import "Music.h"
#import "SoundEffect.h"

@interface ThreeIslandsViewController ()<BackpackSceneDelegate>{
    Player * player;
    Items * items;
    int needDiamondValue;
    int buyCoinsQuantity;
    BackpackScene * theObject;
    AVAudioPlayer * voicePlayer;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePicImage;
//金幣、鑽石數量label
@property (weak, nonatomic) IBOutlet UILabel *coinLabel;
@property (weak, nonatomic) IBOutlet UILabel *diamondLabel;
//購買金幣frame
@property (weak, nonatomic) IBOutlet UIView *darkView;
@property (weak, nonatomic) IBOutlet UIImageView *buyCoinFrame;
@property (weak, nonatomic) IBOutlet UIButton *buyCoin1Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyCoin2Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyCoin3Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyCoin4Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyCoin5Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyCoin6Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyCoinFrameCancelBtn;
//購買鑽石frame
@property (weak, nonatomic) IBOutlet UIImageView *buyDiamondFrame;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamond1Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamond2Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamond3Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamond4Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamond5Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamond6Btn;
@property (weak, nonatomic) IBOutlet UIButton *buyDiamondFrameCancelBtn;
//鑽石數量不足frame
@property (weak, nonatomic) IBOutlet UIImageView *noDiamondFrame;
@property (weak, nonatomic) IBOutlet UIButton *noDiamondAdmitBtn;
//確定購買鑽石frame
@property (weak, nonatomic) IBOutlet UIImageView *checkAdmitBuyCoinFrame;
@property (weak, nonatomic) IBOutlet UIButton *checkAdmitButCoinBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelAdmitBuyCoinBtn;

@end

@implementation ThreeIslandsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Candy Add
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"button_press.mp3" withExtension:nil];
    voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:nil];
    voicePlayer.numberOfLoops = 0;
    [voicePlayer prepareToPlay];
    
    
    [self hideBuyCoinFrame];
    [self hideBuyDiamondFrame];
    [self hideNoDiamondFrame];
    [self hideComfirmBuyCoinFrame];
    
    player = [Player playerSingleton];
    items = [Items itemsSingleton];
    
    //facebook profile frame 改成圓形
    _profilePicImage.layer.cornerRadius = _profilePicImage.frame.size.width/2;
    _profilePicImage.layer.masksToBounds = true;
    
    //取得user 金幣和鑽石數量
    _coinLabel.text = [NSString stringWithFormat:@"%@",player.coin];
    _diamondLabel.text = [NSString stringWithFormat:@"%@",player.diamond];
//    theObject=[[BackpackScene alloc] init];
//    theObject.backPackDelegate=self;
}
-(void)passCoin:(NSInteger)coin{
    _coinLabel.text = [NSString stringWithFormat:@"%ld",(long)coin];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //取得user profile picture URL
    NSString * picString = [BASE_URL stringByAppendingString:player.userPicString];
    NSLog(@"picString:%@",picString);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //profile picture URL -> NSData
        NSData * picData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: picString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //user profile picture 顯示
            _profilePicImage.image = [UIImage imageWithData: picData];
        });
    });
}

- (IBAction)homeIslandBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    //按homeIsland button 跳到 Home島嶼頁面
    UIStoryboard * homeIslandStoryBoard = [UIStoryboard storyboardWithName:@"HomeIsland" bundle:nil];
    UIViewController * vc = [homeIslandStoryBoard instantiateViewControllerWithIdentifier:@"HomeIslandViewController"];
    [self showViewController:vc sender:nil];
    
}
//點擊購買金幣btn
- (IBAction)buyCoinBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [self showBuyCoinFrame];
}
//取消購買金幣btn
- (IBAction)buyCoinFrameCancelBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [self hideBuyCoinFrame];
}
//確定購買coin1 btn
- (IBAction)buyCoin1BtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    if ([_diamondLabel.text intValue] >= 1) {
        needDiamondValue = 1;
        buyCoinsQuantity = 100;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//確定購買coin2 btn
- (IBAction)buyCoin2BtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    if ([_diamondLabel.text intValue] >= 5) {
        needDiamondValue = 5;
        buyCoinsQuantity = 700;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//確定購買coin3 btn
- (IBAction)buyCoin3BtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    if ([_diamondLabel.text intValue] >= 10) {
        needDiamondValue = 10;
        buyCoinsQuantity = 1500;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//確定購買coin4 btn
- (IBAction)buyCoin4BtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    if ([_diamondLabel.text intValue] >= 15) {
        needDiamondValue = 15;
        buyCoinsQuantity = 2500;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//確定購買coin5 btn
- (IBAction)buyCoin5BtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    if ([_diamondLabel.text intValue] >= 30) {
        needDiamondValue = 30;
        buyCoinsQuantity = 5500;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//確定購買coin6 btn
- (IBAction)buyCoin6BtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    if ([_diamondLabel.text intValue] >= 50) {
        needDiamondValue = 50;
        buyCoinsQuantity = 1000;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//點擊購買鑽石btn
- (IBAction)buyDiamondBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [self showBuyDiamondFrame];
}
//取消購買鑽石btn
- (IBAction)buyDiamondFrameCancelBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [self hideBuyDiamondFrame];
}
- (IBAction)buyDiamond1BtnPressed:(id)sender {
}
- (IBAction)buyDiamond2BtnPressed:(id)sender {
}
- (IBAction)buyDiamond3BtnPressed:(id)sender {
}
- (IBAction)buyDiamond4BtnPressed:(id)sender {
}
- (IBAction)buyDiamond5BtnPressed:(id)sender {
}
- (IBAction)buyDiamond6BtnPressed:(id)sender {
}

-(void)hideBuyCoinFrame {
    _darkView.hidden = true;
    _buyCoinFrame.hidden = true;
    _buyCoin1Btn.hidden = true;
    _buyCoin2Btn.hidden = true;
    _buyCoin3Btn.hidden = true;
    _buyCoin4Btn.hidden = true;
    _buyCoin5Btn.hidden = true;
    _buyCoin6Btn.hidden = true;
    _buyCoinFrameCancelBtn.hidden = true;
}
-(void)showBuyCoinFrame {
    _darkView.hidden = false;
    _buyCoinFrame.hidden = false;
    _buyCoin1Btn.hidden = false;
    _buyCoin2Btn.hidden = false;
    _buyCoin3Btn.hidden = false;
    _buyCoin4Btn.hidden = false;
    _buyCoin5Btn.hidden = false;
    _buyCoin6Btn.hidden = false;
    _buyCoinFrameCancelBtn.hidden = false;
}
-(void)hideBuyDiamondFrame {
    _darkView.hidden = true;
    _buyDiamondFrame.hidden = true;
    _buyDiamond1Btn.hidden = true;
    _buyDiamond2Btn.hidden = true;
    _buyDiamond3Btn.hidden = true;
    _buyDiamond4Btn.hidden = true;
    _buyDiamond5Btn.hidden = true;
    _buyDiamond6Btn.hidden = true;
    _buyDiamondFrameCancelBtn.hidden = true;
}
-(void)showBuyDiamondFrame {
    _darkView.hidden = false;
    _buyDiamondFrame.hidden = false;
    _buyDiamond1Btn.hidden = false;
    _buyDiamond2Btn.hidden = false;
    _buyDiamond3Btn.hidden = false;
    _buyDiamond4Btn.hidden = false;
    _buyDiamond5Btn.hidden = false;
    _buyDiamond6Btn.hidden = false;
    _buyDiamondFrameCancelBtn.hidden = false;
}
//關閉鑽石數量不夠視窗btn
- (IBAction)noDiamondAdmitBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [self hideNoDiamondFrame];
}
//隱藏鑽石數量不夠視窗
-(void)hideNoDiamondFrame {
    _noDiamondFrame.hidden = true;
    _noDiamondAdmitBtn.hidden = true;
}
//顯示鑽石數量不夠視窗
-(void)showNoDiamondFrame {
    _noDiamondFrame.hidden = false;
    _noDiamondAdmitBtn.hidden = false;
}
//點擊確定confirm購買金幣
- (IBAction)checkAdmitBuyCoinBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    player.diamond = [NSNumber numberWithInt:([player.diamond intValue] - needDiamondValue)];
    _diamondLabel.text = [NSString stringWithFormat:@"%@",player.diamond];
    _coinLabel.text = [NSString stringWithFormat:@"%d",[player.coin intValue] + buyCoinsQuantity];
    [self buyCoinByDiamond];
    [self hideComfirmBuyCoinFrame];
}
//關閉購買鑽石視窗btn
- (IBAction)cancelComfirmBuyCoinBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [self hideComfirmBuyCoinFrame];
}
//隱藏confirm購買鑽石視窗
-(void)hideComfirmBuyCoinFrame {
    _checkAdmitBuyCoinFrame.hidden = true;
    _checkAdmitButCoinBtn.hidden = true;
    _cancelAdmitBuyCoinBtn.hidden = true;
}
//顯示confirm購買鑽石視窗
-(void)showComfirmBuyCoinFrame {
    _checkAdmitBuyCoinFrame.hidden = false;
    _checkAdmitButCoinBtn.hidden = false;
    _cancelAdmitBuyCoinBtn.hidden = false;
}
//購買金幣，跟server做溝通
-(void)buyCoinByDiamond {
    [items buyCoinByDiamondPostToken:player.userToken parameters:buyCoinsQuantity completion:^(NSError *error, id result) {
        //若連線失敗
        if (error) {
            NSLog(@"error:%@",error.description);
            //若連線成功
        }else{
            //接server回傳的result
            NSData * data = result;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //若result是error
            if ([[dic objectForKey:@"success"] boolValue] == false) {
                NSLog(@"get data error:%@",[[dic objectForKey:@"result"] description]);
                //若result是success
            }else{
                //取出 result 包的 dic
                NSString * resultString = [dic objectForKey:@"result"];
                NSLog(@"resultString:%@",resultString);
            }
        }
    }];
}
- (IBAction)shopBtnPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    //跳到商店
    UIStoryboard * shopPetStoryboard = [UIStoryboard storyboardWithName:@"Shop" bundle:nil];
    UIViewController * vc = [shopPetStoryboard instantiateViewControllerWithIdentifier:@"ShopPetViewController"];
    [self showViewController:vc sender:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Candy Add

- (IBAction)goUserProfileButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goSettingButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"Setting"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goLeaderboardButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ThreeIslands" bundle:nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"Leaderboard"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Bird Add
- (IBAction)goArenaButtonPressed:(id)sender {
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"BGM_battle.mp3" withExtension:nil];
    self.battleVoicePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:voiceURL error:nil];
    self.battleVoicePlayer.numberOfLoops = -1;
    self.battleVoicePlayer.volume = 0.3;
    [self.battleVoicePlayer prepareToPlay];
    ViewController * vc = (ViewController *)self.presentingViewController;
    [vc.voicePlayer stop];
    [[Music shareMusic] playMusic:self.battleVoicePlayer];
    CGRect viewRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    SKView * view=[[SKView alloc]initWithFrame:viewRect];
    SKScene *scene=[ArenaEntranceScene nodeWithFileNamed:@"ArenaEntranceScene"];
    scene.scaleMode = SKSceneScaleModeFill;
    [view presentScene:scene];
    //過場效果
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:transition forKey:nil];
    [self.view addSubview:view];
////    ArenaEntranceScene*scene=[[ArenaEntranceScene alloc] initWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    ArenaEntranceScene*scene=[ArenaEntranceScene sceneWithSize:view.bounds.size];
//    SKView *spriteView = (SKView *) self.view;
//    [spriteView presentScene:scene];
//    GameMainSKView * skView = (GameMainSKView *)[self.storyboard instantiateViewControllerWithIdentifier:@"GameMainSKView"];
    
}

- (IBAction)goMapButtonPressed:(id)sender {
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"BGM_map.mp3" withExtension:nil];
    self.mapVoicePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:voiceURL error:nil];
    self.mapVoicePlayer.numberOfLoops = -1;
    self.mapVoicePlayer.volume = 0.3;
    [self.mapVoicePlayer prepareToPlay];
    ViewController * vc = (ViewController *)self.presentingViewController;
    [vc.voicePlayer stop];
    [[Music shareMusic] playMusic:self.mapVoicePlayer];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"BirdMain" bundle:nil];
    UIViewController * mapvc = [storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    [self presentViewController:mapvc animated:TRUE completion:nil];
}
- (IBAction)goBackpackButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    CGRect viewRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    SKView * view=[[SKView alloc]initWithFrame:viewRect];
    BackpackScene *scene=[BackpackScene nodeWithFileNamed:@"BackpackScene"];
    scene.scaleMode = SKSceneScaleModeFill;
    scene.backPackDelegate = self;
    [view presentScene:scene];
    //過場效果
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:transition forKey:nil];
    [self.view addSubview:view];
}
- (IBAction)goHandbookButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    CGRect viewRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    SKView * view=[[SKView alloc]initWithFrame:viewRect];
    view.ignoresSiblingOrder=true;
    SKScene *scene=[MonsterHandbookScene nodeWithFileNamed:@"MonsterHandbookScene"];
    scene.scaleMode = SKSceneScaleModeFill;
    [view presentScene:scene];
    //過場效果
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:transition forKey:nil];
    [self.view addSubview:view];
    
}
- (IBAction)friendButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    CGRect viewRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    SKView * view=[[SKView alloc]initWithFrame:viewRect];
    [self.view addSubview:view];
    SKScene *scene=[SocialScene nodeWithFileNamed:@"SocialScene"];
    scene.scaleMode = SKSceneScaleModeFill;
    scene.userData=[[NSMutableDictionary alloc]init];
    [scene.userData setObject:@"friendButtonPressed" forKey:@"fromWhere"];
    [view presentScene:scene];
}
- (IBAction)mailButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    CGRect viewRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    SKView * view=[[SKView alloc]initWithFrame:viewRect];
    [self.view addSubview:view];
    SKScene *scene=[SocialScene nodeWithFileNamed:@"SocialScene"];
    scene.scaleMode = SKSceneScaleModeFill;
    scene.userData=[[NSMutableDictionary alloc]init];
    [scene.userData setObject:@"mailButtonPressed" forKey:@"fromWhere"];
    [view presentScene:scene];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

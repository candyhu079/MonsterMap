//
//  ViewController.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/1/15.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "FBEncryptorAES.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "ViewController.h"
#import "Player.h"
#import "Music.h"
#import "SoundEffect.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#define ENCRYPT_KEY @"nc5gt3rbqep24406"
#define ENCRYPT_IV  @"jd08h650n51ivies"

typedef void (^doneBlock)(NSError * error,id result);

@interface ViewController ()<UITextFieldDelegate,FBSDKLoginButtonDelegate,UIActionSheetDelegate>
{
    Player * player;
}

//登入頁面frame 的 IBOutlet
@property (weak, nonatomic) IBOutlet UIImageView *loginFrameImage;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *gameCenterBtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *facabookLogoutBtn;
//忘記密碼頁面frame 的 IBOutlet
@property (weak, nonatomic) IBOutlet UIImageView *forgotPasswordFrame;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordAdmitBtn;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UILabel *nameErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *textfieldErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordErrorLabel;
@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordEmailTextfield;
//@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNumber * check = [[NSUserDefaults standardUserDefaults] objectForKey:@"music"];
    if (check == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"music"];
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"sound"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSNumber * musicIsMute = [[NSUserDefaults standardUserDefaults] objectForKey:@"music"];
    NSNumber * soundIsMute = [[NSUserDefaults standardUserDefaults] objectForKey:@"sound"];
    if ([musicIsMute isEqual: @0]) {
        [Music shareMusic].isMute = @0;
    }else {
        [Music shareMusic].isMute = @1;
        
    }
    if ([soundIsMute isEqual: @0]) {
        [SoundEffect shareSound].isMute = @0;
    }else {
        [SoundEffect shareSound].isMute = @1;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"BGM_town.mp3" withExtension:nil];
    self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:nil];
    self.voicePlayer.numberOfLoops = -1;
    self.voicePlayer.volume = 0.3;
    [self.voicePlayer prepareToPlay];
    [[Music shareMusic] playMusic:self.voicePlayer];
    
    
    //收鍵盤
    _usernameTextfield.delegate = self;
    _passwordTextfield.delegate = self;
    _forgotPasswordEmailTextfield.delegate = self;

    player = [Player playerSingleton];

    [self hideForgotPasswordFrame];

    //facebook btn 添加點擊事件
    [_facebookBtn addTarget:self action:@selector(facebookLoginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [_facabookLogoutBtn addTarget:self action:@selector(facebookLogoutBtnPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)loginBtnPressed:(id)sender {
    
    //預設沒有錯誤訊息
    _nameErrorLabel.text = @"";
    _passwordErrorLabel.text = @"";
    
    /*//啟動一個hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //設定hud的顯示文字
    [hud setLabelText:@"connecting"];*/
    
    //登入帳號的格式錯誤
    if([self validateAccount:_usernameTextfield.text] == false){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"validateAccount fail");
        _nameErrorLabel.text = @"輸入帳號格式錯誤";
    }
    //登入密碼的格式錯誤
    if ([self validatePassword:_passwordTextfield.text] == false) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"validatePassword fail");
        _passwordErrorLabel.text = @"輸入密碼格式錯誤";
    }

    //登入帳號、密碼格式完全正確
    if ([self validateAccount:_usernameTextfield.text] == true &&
        [self validatePassword:_passwordTextfield.text] == true){
        
        //對使用者密碼做編碼加密
        NSData * keyData = [ENCRYPT_KEY dataUsingEncoding:NSASCIIStringEncoding];
        NSData * ivData = [ENCRYPT_IV dataUsingEncoding:NSASCIIStringEncoding];
        NSData * passwordData = [_passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding];
        NSData * encryptPassword = [FBEncryptorAES encryptData:passwordData key:keyData iv:ivData];
        NSString * passwordBase64 = [FBEncryptorAES hexStringForData:encryptPassword];
        NSLog(@"passwordBase64:%@",passwordBase64);
        
        //user帳號、密碼存到singleton
        player.userAcount = _usernameTextfield.text;
        player.userPassword = passwordBase64;
        
        //user帳號、密碼跟server做溝通
        [player userLoginWithCompletion:^(NSError *error, id result) {
            //若連線失敗
            if (error) {
                _textfieldErrorLabel.text = @"登入失敗，請重新登入";
                NSLog(@"Userlogin connect to server error:%@",error.description);
            //若連線成功
            }else{
                //接server回傳的result
                NSData * data = result;
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                //若取得error
                if ([[dic objectForKey:@"success"] boolValue] == false) {
                    _nameErrorLabel.text = [[dic objectForKey:@"result"] description];
                    NSLog(@"Login, server return error result: %@",
                          [[dic objectForKey:@"result"] description]);
                //若取得success
                }else{
                    //取出 result 包的 dic
                    NSDictionary * resultDic = [dic objectForKey:@"result"];
                    //取出的user資料，存入singleton
                    player.userToken = [resultDic objectForKey:@"userToken"];
                    player.userPicString = [resultDic objectForKey:@"picture"];
                    player.coin = [resultDic objectForKey:@"coin"];
                    player.diamond = [resultDic objectForKey:@"diamond"];

                    NSLog(@"一般登入成功");
                    NSLog(@"Login, server return success Result Dic:%@",resultDic);
                    
                    //成功登入，跳到三個島嶼主頁
                    UIStoryboard * threeIslandsStoryboard = [UIStoryboard storyboardWithName:@"ThreeIslands" bundle:nil];
                    UIViewController * vc = [threeIslandsStoryboard instantiateViewControllerWithIdentifier:@"ThreeIslands"];
                    [self showViewController:vc sender:nil];
                }
            }
        }];
    }
}
//點擊忘記密碼
- (IBAction)forgotPasswordBtn:(id)sender {
    //顯示忘記密碼框，隱藏其他框
    [self hideLoginFrame];
    [self showForgotPasswordFrame];
}
//點擊忘記密碼框 - 取消鍵
- (IBAction)forgotPasswordCancelBtnPressed:(id)sender {
    //顯示登入框，隱藏忘記密碼框
    [self hideForgotPasswordFrame];
    [self showLoginFrame];
}

//點擊忘記密碼框 - 確定鍵
- (IBAction)forgotPasswordAdmitBtnPressed:(id)sender {
    
    //若輸入信箱格式正確
    if ([self validateAccount:_forgotPasswordEmailTextfield.text] == true ){
       
        //user填入的email 存入singleton
        player.userAcount = _forgotPasswordEmailTextfield.text;
        //email傳給server, server寄出臨時密碼
        [player forgotPasswordWithCompletion:^(NSError *error, id result) {
            //若連線失敗
            if (error) {
                _forgotPasswordErrorLabel.text = @"信件傳送失敗，請再試一次。";
                NSLog(@"ForgotPassword connect to server error:%@",error.description);
                //若連線成功
            }else{
                //接server回傳的result
                NSData * data = result;
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                //若result是error
                if ([[dic objectForKey:@"success"] boolValue] == false) {
                    _nameErrorLabel.text = [[dic objectForKey:@"result"] description];
                    NSLog(@"ForgotPassword, server return errer result: %@",
                          [[dic objectForKey:@"result"] description]);
                //若result是success
                }else{
                    NSLog(@"ForgotPassword, server return success result: %@",
                          [[dic objectForKey:@"result"] description]);
                    [self hideForgotPasswordFrame];
                    [self showLoginFrame];
                }
            }
        }];
    //若輸入信箱格式錯誤
    }else{
        _forgotPasswordErrorLabel.text = @"信箱格式錯誤";
    }
}

//點擊註冊按鈕
- (IBAction)registerBtnPressed:(id)sender {
    [self makeSomeButtonNoise];
    //跳註冊頁面
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self showViewController:vc sender:nil];
}
//顯示、隱藏忘記密碼框
-(void) showForgotPasswordFrame{
    _forgotPasswordFrame.hidden = false;
    _forgotPasswordAdmitBtn.hidden = false;
    _forgotPasswordCancelBtn.hidden = false;
    _forgotPasswordEmailTextfield.hidden = false;
}
-(void) hideForgotPasswordFrame{
    _forgotPasswordFrame.hidden = true;
    _forgotPasswordAdmitBtn.hidden = true;
    _forgotPasswordCancelBtn.hidden = true;
    _forgotPasswordEmailTextfield.hidden = true;
}
//顯示、隱藏登入框
-(void) showLoginFrame{
    
    _loginFrameImage.hidden = false;
    _forgotPasswordBtn.hidden = false;
    _loginBtn.hidden = false;
    _registerBtn.hidden = false;
    _gameCenterBtn.hidden = false;
    _facebookBtn.hidden = false;
    _usernameTextfield.hidden = false;
    _passwordTextfield.hidden = false;
    _nameErrorLabel.hidden = false;
    _passwordErrorLabel.hidden = false;
    _textfieldErrorLabel.hidden = false;
    _facabookLogoutBtn.hidden = false;
    
}
-(void) hideLoginFrame{
    
    _loginFrameImage.hidden = true;
    _forgotPasswordBtn.hidden = true;
    _loginBtn.hidden = true;
    _registerBtn.hidden = true;
    _gameCenterBtn.hidden = true;
    _facebookBtn.hidden = true;
    _usernameTextfield.hidden = true;
    _passwordTextfield.hidden = true;
    _nameErrorLabel.hidden = true;
    _passwordErrorLabel.hidden = true;
    _textfieldErrorLabel.hidden = true;
    _facabookLogoutBtn.hidden = true;
}

//檢驗帳號格式
- (BOOL)validateAccount:(NSString *)account{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:account];
}
//檢驗密碼格式
- (BOOL)validatePassword:(NSString *)password{
    NSString *regex = @"[A-Z0-9a-z]{3,20}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:password];
}

#pragma mark - UITextfieldDelegate Methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

#pragma mark - FBSDKLoginButtonDelegate Methods

//facebook 登入
-(void)facebookLoginBtnPressed
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     //詢問使用者是否允許app取得user資料
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"] fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Facebook login process error");
         } else if (result.isCancelled) {
             NSLog(@"Facebook login cancelled");
         } else {
             //若facebook 成功登入，做didCompleteWithResult method
             [self facebookLoginBtn:_facebookBtn didCompleteWithResult:result error:error];
             NSLog(@"Facebook Logged in");
             //隱藏facebook login button
             _facebookBtn.hidden = true;
         }
     }];
}
 //取得facebook 使用者資料
-(void)facebookLoginBtn:(UIButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    //要取得的facebook 資料
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"me"
                                  parameters:@{@"fields" : @"email, name, first_name, last_name, picture.width(100).height(100)"}
                                  HTTPMethod:@"GET"];
    //取得user facebook 資料
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,id result,NSError *error) {
        NSString * userName = [result objectForKey:@"name"];
        NSString * userEmail = [result objectForKey:@"email"];
        NSString * userID = [result objectForKey:@"id"];
        NSString * userPic = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
        //facebook id 做編碼
        NSData * keyData = [ENCRYPT_KEY dataUsingEncoding:NSASCIIStringEncoding];
        NSData * ivData = [ENCRYPT_IV dataUsingEncoding:NSASCIIStringEncoding];
        NSData * IDData = [userID dataUsingEncoding:NSUTF8StringEncoding];
        NSData * encryptID = [FBEncryptorAES encryptData:IDData key:keyData iv:ivData];
        NSString * IDBase64 = [FBEncryptorAES hexStringForData:encryptID];
        //profile photo url 做編碼
        NSURL *picURL = [NSURL URLWithString:userPic];
        NSData * picData = [[NSData alloc] initWithContentsOfURL:picURL];
        NSString * picBase64 = [picData base64EncodedStringWithOptions:0];

        NSLog(@"name:%@",userName);
        NSLog(@"email:%@",userEmail);
        
        //將使用者資料存到singleton
        player.userNickname = userName;
        player.userAcount = userEmail;
        player.userPassword = IDBase64;
        player.userPicBase64 = picBase64;
        
        //facebook 帳號、密碼跟server做溝通
        [player createUserByFBWithCompletion:^(NSError *error, id result) {
            //若連線失敗
            if (error) {
                NSLog(@"FBLogin connect to server error:%@",error.description);
            //若連線成功
            }else{
                //接server回傳的result
                NSData * data = result;
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                //若result是error
                if ([[dic objectForKey:@"success"] boolValue] == false) {
                    NSLog(@"FBLogin, server return error result:%@",
                          [[dic objectForKey:@"result"] description]);
                //若result是success
                }else{
                    //取出 result 包的 dic
                    NSDictionary * resultDic = [dic objectForKey:@"result"];
                    //取出的userToken, picture存入singleton
                    player.userToken = [resultDic objectForKey:@"userToken"];
                    player.userPicString = [resultDic objectForKey:@"picture"];
                    player.coin = [resultDic objectForKey:@"coin"];
                    player.diamond = [resultDic objectForKey:@"diamond"];
                    
                    NSLog(@"Facebook登入成功");
                    NSLog(@"FBLogin, server return success result dic:%@",resultDic);
                    
                    //成功登入，跳到三個島嶼主頁
                    UIStoryboard * threeIslandsStoryboard = [UIStoryboard storyboardWithName:@"ThreeIslands" bundle:nil];
                    UIViewController * vc = [threeIslandsStoryboard instantiateViewControllerWithIdentifier:@"ThreeIslands"];
                    [self showViewController:vc sender:nil];
                }
            }
        }];
    }];
}

-(void) fbProfilePicture:(NSString*)URL
      completion:(doneBlock)completion{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        NSLog(@"FB profilePic doHttpPost error:%@",error.description);
    }];
}

//Facebook 登出
-(void)facebookLogoutBtnPressed
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc]
                                   initWithTitle:@"是否確定登出"
                                   delegate:self
                                   cancelButtonTitle:@"取消"
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:@"登出", nil];
    [actionSheet showInView:self.view];
}
//詢問是否確認登出facebook
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0: //登出
            [actionSheet showInView:self.view];
            
            [[FBSDKLoginManager new] logOut];
            player.userAcount = @"";
            player.userPassword = @"";
            player.userNickname = @"";
            _facebookBtn.hidden = false;
            break;
        default:
            break;
    }
}
-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{

}
-(void)makeSomeButtonNoise{
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"button_press" withExtension:@"mp3"];
    self.buttonVoicePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:voiceURL error:nil];
     [self.buttonVoicePlayer prepareToPlay];
    [[SoundEffect shareSound] playSoundEffect:self.buttonVoicePlayer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

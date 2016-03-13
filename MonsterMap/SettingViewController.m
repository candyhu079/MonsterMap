//
//  SettingViewController.m
//  MonsterMap
//
//  Created by Candy on 2016/2/27.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "SettingViewController.h"
#import "AFNetworking.h"
#import "Player.h"
#import "FBEncryptorAES.h"
#import "Music.h"
#import "SoundEffect.h"
#import "ViewController.h"
#import "ThreeIslandsViewController.h"

#define ENCRYPT_KEY @"nc5gt3rbqep24406"
#define ENCRYPT_IV  @"jd08h650n51ivies"
#define PASSWORD_KEY @"password"
#define NEWPASSWORD_KEY @"newPassword"

typedef void (^CompletionBlock)(NSError * error,id result);

#define BASE_URL @"http://api.leolin.me"
//#define BASE_URL @"http://192.168.196.48:8080"
#define CHANGEPASSWORD_URL [BASE_URL stringByAppendingPathComponent:@"changePassword"]
#define LOGOUT_URL [BASE_URL stringByAppendingPathComponent:@"logout"]

@interface SettingViewController ()<UITextFieldDelegate>
{
    AVAudioPlayer * voicePlayer;
    Player * player;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingLabelToTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *changePasswordFrameImageView;
@property (weak, nonatomic) IBOutlet UILabel *enterOldPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterNewPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNewPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterOldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *enterNewPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *checkNewPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *changePasswordOkImageView;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordOkButton;
@property (weak, nonatomic) IBOutlet UILabel *changePasswordOkLabel;
@property (weak, nonatomic) IBOutlet UIButton *musicOnButton;
@property (weak, nonatomic) IBOutlet UIButton *musicOffButton;
@property (weak, nonatomic) IBOutlet UIButton *soundEffectOnButton;
@property (weak, nonatomic) IBOutlet UIButton *soundEffectOffButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkNewPasswordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *enterNewPasswordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *enterOldPasswordImageView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.enterOldPasswordTextField.delegate = self;
    self.enterNewPasswordTextField.delegate = self;
    self.checkNewPasswordTextField.delegate = self;
    
    NSNumber * musicIsMute = [[NSUserDefaults standardUserDefaults] objectForKey:@"music"];
    if ([musicIsMute isEqual:@0]) {
        self.musicOnButton.hidden = false;
        self.musicOffButton.hidden = true;
    }else{
        self.musicOnButton.hidden = true;
        self.musicOffButton.hidden = false;
    }
    NSNumber * soundIsMute = [[NSUserDefaults standardUserDefaults] objectForKey:@"sound"];
    if ([soundIsMute isEqual:@0]) {
        self.soundEffectOnButton.hidden = false;
        self.soundEffectOffButton.hidden = true;
    }else{
        self.soundEffectOnButton.hidden = true;
        self.soundEffectOffButton.hidden = false;
    }
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (result.height == 480) {
        self.settingLabelToTopConstraint.constant = 90;
        
    }else if(result.height == 568){
        self.settingLabelToTopConstraint.constant = 120;
        
    }else if(result.height == 667){
        self.settingLabelToTopConstraint.constant = 150;
        
    }else {
        self.settingLabelToTopConstraint.constant = 170;
    }
    
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"button_press.mp3" withExtension:nil];
    voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:nil];
    voicePlayer.numberOfLoops = 0;
    [voicePlayer prepareToPlay];

}

- (IBAction)backButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)musicButton:(id)sender {
    NSNumber * isMute = [NSNumber numberWithInteger:[sender tag]];
    Music * music = [Music shareMusic];
    ViewController * vc;
    if ([self.presentingViewController.presentingViewController isMemberOfClass:[ViewController class]]) {
        vc = (ViewController *)self.presentingViewController.presentingViewController;
    }else{
        vc = (ViewController *)self.presentingViewController.presentingViewController.presentingViewController;
    }
    
    
    switch (isMute.integerValue) {
        case 0:
            music.isMute = @0;
            self.musicOnButton.hidden = false;
            self.musicOffButton.hidden = true;
            
            if (! vc.voicePlayer.isPlaying) {
                [vc.voicePlayer play];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"music"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 1:
            music.isMute = @1;
            self.musicOnButton.hidden = true;
            self.musicOffButton.hidden = false;
            [vc.voicePlayer stop];
            
            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"music"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        default:
            break;
    }
}

- (IBAction)soundEffectButton:(id)sender {
    NSNumber * isMute = [NSNumber numberWithInteger:[sender tag]];
    SoundEffect * soundEffect = [SoundEffect shareSound];
    
    switch (isMute.integerValue) {
        case 0:
            soundEffect.isMute = @0;
            self.soundEffectOnButton.hidden = false;
            self.soundEffectOffButton.hidden = true;
            
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"sound"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 1:
            soundEffect.isMute = @1;
            self.soundEffectOnButton.hidden = true;
            self.soundEffectOffButton.hidden = false;

            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"sound"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        default:
            break;
    }

}

- (IBAction)contactUsButtonPressed:(id)sender {
    NSString * urlString = @"https://www.facebook.com/hu.mei.16";
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];

}

- (IBAction)changePasswordButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    [self changePasswordFrameHidden:false];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    player = [Player playerSingleton];
    
    [self doHttpPost:LOGOUT_URL token:player.userToken parameter:nil completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"Error: %@", error.description);
        }else{
            NSData * resultData = result;
            NSDictionary * resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if ([resultDict[@"success"] boolValue] == false) {
                NSLog(@"Server say error: %@", [resultDict[@"result"] description]);
            }else{
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}

- (IBAction)okButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    
    NSString * password = self.enterOldPasswordTextField.text;
    NSString * newPassword = self.enterNewPasswordTextField.text;
    NSString * checkNewPassword = self.checkNewPasswordTextField.text;
    if ([newPassword isEqualToString:checkNewPassword]) {
        if ([self validatePassword:newPassword]) {
            player = [Player playerSingleton];
            
            NSData * keyData = [ENCRYPT_KEY dataUsingEncoding:NSASCIIStringEncoding];
            NSData * ivData = [ENCRYPT_IV dataUsingEncoding:NSASCIIStringEncoding];
            NSData * passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
            NSData * encryptPassword = [FBEncryptorAES encryptData:passwordData key:keyData iv:ivData];
            NSString * passwordBase64 = [FBEncryptorAES hexStringForData:encryptPassword];
            NSData * newPasswordData = [newPassword dataUsingEncoding:NSUTF8StringEncoding];
            NSData * encryptNewPassword = [FBEncryptorAES encryptData:newPasswordData key:keyData iv:ivData];
            NSString * newPasswordBase64 = [FBEncryptorAES hexStringForData:encryptNewPassword];
            
            NSDictionary * jsonObj = @{PASSWORD_KEY:passwordBase64, NEWPASSWORD_KEY:newPasswordBase64};
            
            [self doHttpPost:CHANGEPASSWORD_URL token:player.userToken parameter:jsonObj completion:^(NSError *error, id result) {
                if (error) {
                    NSLog(@"Error: %@", error.description);
                }else{
                    NSData * resultData = result;
                    NSDictionary * resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                    if ([resultDict[@"success"] boolValue] == false) {
                        NSLog(@"Server say error: %@", [resultDict[@"result"] description]);
                        self.infoLabel.text = [resultDict[@"result"] description];
                    }else{
                        self.infoLabel.hidden = true;
                        [self changePasswordFrameHidden:true];
                        self.changePasswordOkLabel.hidden = false;
                        self.changePasswordOkImageView.hidden = false;
                        self.changePasswordOkButton.hidden = false;
                    }
                }
            }];
        }else{
            self.infoLabel.text = @"密碼請輸入6-20位英文或數字";
        }
    }else{
        self.infoLabel.text = @"密碼輸入錯誤";
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    [self changePasswordFrameHidden:true];
    self.infoLabel.hidden = true;
}

- (IBAction)changePasswordOkButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    self.changePasswordOkLabel.hidden = true;
    self.changePasswordOkImageView.hidden = true;
    self.changePasswordOkButton.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Self Methods

-(void)changePasswordFrameHidden:(BOOL)hiddenYesOrNot{
    self.enterNewPasswordTextField.text = @"";
    self.enterOldPasswordTextField.text = @"";
    self.checkNewPasswordTextField.text = @"";
    self.changePasswordFrameImageView.hidden = hiddenYesOrNot;
    self.enterNewPasswordLabel.hidden = hiddenYesOrNot;
    self.enterOldPasswordLabel.hidden = hiddenYesOrNot;
    self.enterNewPasswordTextField.hidden = hiddenYesOrNot;
    self.enterOldPasswordTextField.hidden = hiddenYesOrNot;
    self.checkNewPasswordLabel.hidden = hiddenYesOrNot;
    self.checkNewPasswordTextField.hidden = hiddenYesOrNot;
    self.okButton.hidden = hiddenYesOrNot;
    self.cancelButton.hidden = hiddenYesOrNot;
    self.enterNewPasswordImageView.hidden = hiddenYesOrNot;
    self.enterOldPasswordImageView.hidden = hiddenYesOrNot;
    self.checkNewPasswordImageView.hidden = hiddenYesOrNot;
}

-(void) doHttpPost:(NSString *)URL token:(NSString *)token parameter:(NSDictionary *)parameter completion:(CompletionBlock)completion{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}

//檢查輸入密碼格式
- (BOOL)validatePassword:(NSString *)password{
    NSString *regex = @"[A-Z0-9a-z]{6,20}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:password];
}

@end

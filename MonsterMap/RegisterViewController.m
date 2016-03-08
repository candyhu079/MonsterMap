//
//  RegisterViewController.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/3.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "FBEncryptorAES.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Player.h"
#import "RegisterViewController.h"
#import "SoundEffect.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ENCRYPT_KEY @"nc5gt3rbqep24406"
#define ENCRYPT_IV  @"jd08h650n51ivies"
#define MAX_TITLE_LEN 8

@interface RegisterViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    Player * player;
    UIImagePickerController * imgPicker;
}

@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UITextField *accountTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *accountErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
//registerFrame IBOutlet
@property (weak, nonatomic) IBOutlet UIButton *photoFrameBtn;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *registerFrame;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
//registerSuccess IBOutlet
@property (weak, nonatomic) IBOutlet UIImageView *registerSuccessFrame;
@property (weak, nonatomic) IBOutlet UIButton *registerSuccessAdmitBtn;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    player = [Player playerSingleton];
    
    _accountTextfield.delegate = self;
    _passwordTextfield.delegate = self;
    _nicknameTextfield.delegate = self;
    _userNameTextfield.delegate = self;
    
    _accountErrorLabel.text = @"請填真實信箱，以利忘記密碼時使用";
    _registerSuccessFrame.hidden = true;
    _registerSuccessAdmitBtn.hidden = true;
    
    //profile picture改成圓形
    _photoImage.contentMode = UIViewContentModeScaleAspectFit;
    _photoImage.layer.cornerRadius = _photoImage.frame.size.width/2;
    _photoImage.layer.masksToBounds = true;
    // Do any additional setup after loading the view, typically from a nib.
}

//編輯profile picture
- (IBAction)takePhotoBtnPressed:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc]
                                   initWithTitle:@"請選擇照片來源"
                                   delegate:self
                                   cancelButtonTitle:@"取消"
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:@"照相機",@"相簿", nil];
    [actionSheet showInView:self.view];
}
//選profile picture來源
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UIImagePickerControllerSourceType sourceType;
    
    switch (buttonIndex) {
        case 0: //照相機
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1: //相簿
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            break;
    }
    //檢測手機是否有支援source type
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
        NSLog(@"SourceType not available.");
        return;
    }
    
    imgPicker = [UIImagePickerController new];
    imgPicker.sourceType = sourceType;
    imgPicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imgPicker.showsCameraControls = YES;
    }

    [self presentViewController:imgPicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
    {
        //取得剪裁過的image
        UIImage * img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self saveImage:img];
        //Image 轉成 Base64
        NSData * imgData = UIImageJPEGRepresentation(img, 0.05);
        NSString * imgBase64 = [imgData base64EncodedStringWithOptions:0];
        
        //Profile picture 存進singleton
        player.userPicBase64 = imgBase64;
        //Profile 顯示
        _photoImage.image = img;
        //關掉照相視窗框
        [imgPicker dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)saveImage:(UIImage*)image{
    
    NSString * fileName = [NSString stringWithFormat:@"%@.jpg",[NSDate date]];
    NSString * fullFilePathName = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSData * fileData = UIImageJPEGRepresentation(image, 0.8);
    
    //覆蓋 fullFilePathName 暫存檔
    [fileData writeToFile:fullFilePathName atomically:false];
    //存入相簿
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    [library writeImageToSavedPhotosAlbum:image.CGImage
                              orientation:(ALAssetOrientation)image.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              NSLog(@"Image saved.");
                          }];
}

- (IBAction)registerBtnPressed:(id)sender {
    
    _accountErrorLabel.text = @"";
    _passwordErrorLabel.text = @"";
    _errorLabel.text = @"";
    
    if (_photoImage.image == NULL) {
        _errorLabel.text = @"    尚未選取圖片";
    }
    
    if ([self validateAccount:_accountTextfield.text] == true &&
        [self validatePassword:_passwordTextfield.text] == true &&
        _photoImage.image != NULL){
        
        //對使用者密碼做編碼加密
        NSData * keyData = [ENCRYPT_KEY dataUsingEncoding:NSASCIIStringEncoding];
        NSData * ivData = [ENCRYPT_IV dataUsingEncoding:NSASCIIStringEncoding];
        NSData * passwordData = [_passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding];
        NSData * encryptPassword = [FBEncryptorAES encryptData:passwordData key:keyData iv:ivData];
        NSString * passwordBase64 = [FBEncryptorAES hexStringForData:encryptPassword];
        NSLog(@"encryptPassword: %@",encryptPassword);
        NSLog(@"passwordBase64: %@",passwordBase64);
        
        //使用者資料存到singleton
        player.userAcount =  _accountTextfield.text;
        player.userNickname = _nicknameTextfield.text;
        player.userPassword = passwordBase64;
        
        [player createUserWithCompletion:^(NSError *error, id result) {
            if (error) {
                _errorLabel.text = @"註冊失敗，請重新註冊";
            }
            else
            {
                NSData * resultData = result;
                NSDictionary * resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];

                if ([[resultDict objectForKey:@"success"] boolValue] == false) {
                    _accountErrorLabel.text = [[resultDict objectForKey:@"result"] description];
                }else{
                    
                    //取得 result
                    NSDictionary * successResultData = [resultDict objectForKey:@"result"];
                    NSLog(@"successResultData:%@",successResultData);
                    
                    //隱藏註冊頁面框
                    _accountTextfield.hidden = true;
                    _passwordTextfield.hidden = true;
                    _accountErrorLabel.hidden = true;
                    _passwordErrorLabel.hidden = true;
                    _userNameTextfield.hidden = true;
                    _registerFrame.hidden = true;
                    _photoImage.hidden = true;
                    _cancelBtn.hidden = true;
                    _registerBtn.hidden = true;
                    _photoFrameBtn.hidden = true;
                    //顯示成功註冊提示框
                    _registerSuccessFrame.hidden = false;
                    _registerSuccessAdmitBtn.hidden = false;
                }
            }
        }];
    }
    //輸入帳號的格式錯誤
    if ([self validateAccount:_accountTextfield.text] == false) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _accountErrorLabel.text = @"帳號格式輸入錯誤";
    }
    //輸入密碼的格式錯誤
    if ([self validatePassword:_passwordTextfield.text] == false) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _passwordErrorLabel.text = @"密碼格式輸入錯誤";
    }
}
- (IBAction)cancelBtnPressed:(id)sender {
    [self makeSomeButtonNoise];
    //返回登入頁面
//    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//    [self showViewController:vc sender:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerSuccessAdmitBtnPressed:(id)sender {
    
    //返回登入頁面
    [self dismissViewControllerAnimated:YES completion:nil];
}

//檢查輸入帳號格式
- (BOOL)validateAccount:(NSString *)account{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:account];
}
//檢查輸入密碼格式
- (BOOL)validatePassword:(NSString *)password{
    NSString *regex = @"[A-Z0-9a-z]{6,20}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:password];
}


#pragma mark - UITextfieldDelegate Methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

-(void)makeSomeButtonNoise{
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"button_press" withExtension:@"mp3"];
    self.buttonVoicePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:voiceURL error:nil];
    [self.buttonVoicePlayer prepareToPlay];
    [[SoundEffect shareSound] playSoundEffect:self.buttonVoicePlayer];
}

@end

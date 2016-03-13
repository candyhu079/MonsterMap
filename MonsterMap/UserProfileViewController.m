//
//  UserProfileViewController.m
//  MonsterMap
//
//  Created by Candy on 2016/2/26.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "AFNetworking.h"
#import "UserProfileViewController.h"
#import "Player.h"
#import <AVFoundation/AVFoundation.h>
#import "Music.h"
#import "SoundEffect.h"

typedef void (^CompletionBlock)(NSError * error,id result);

#define BASE_URL @"http://api.leolin.me"
//#define BASE_URL @"http://192.168.196.48:8080"
#define USERPROFILE_URL [BASE_URL stringByAppendingPathComponent:@"userProfile"]
#define CHANGEPHOTO_URL [BASE_URL stringByAppendingPathComponent:@"changePhoto"]
#define PICTUREBASE64 @"pictureBase64"

@interface UserProfileViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController * imagePicker;
    AVAudioPlayer * voicePlayer;
    Player * player;
}
@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinLabel;
@property (weak, nonatomic) IBOutlet UILabel *diamondLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *monsterQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *monsterTotalLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *defeatMonsterLabel;
@property (weak, nonatomic) IBOutlet UILabel *practiceModeWinRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;


@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    player = [Player playerSingleton];
    self.userPicImageView.layer.cornerRadius = 10;
    self.userPicImageView.layer.masksToBounds = true;
    
    NSURL * voiceURL = [[NSBundle mainBundle] URLForResource:@"button_press.mp3" withExtension:nil];
    voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:nil];
    voicePlayer.numberOfLoops = 0;
    [voicePlayer prepareToPlay];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (result.height == 480) {
        UIFont * fontBig4 = [UIFont boldSystemFontOfSize: 20];
        UIFont * fontMedium4 = [UIFont boldSystemFontOfSize: 14];
        UIFont * fontSmall4 = [UIFont boldSystemFontOfSize: 16];
        [self changeLabelFontSizeToFontBig:fontBig4 andFontMedium:fontMedium4 andFontSmall:fontSmall4];
        
        self.imageViewTopConstraint.constant = 100;
        
    }else if(result.height == 568){
        UIFont * fontBig5 = [UIFont boldSystemFontOfSize: 22];
        UIFont * fontMedium5 = [UIFont boldSystemFontOfSize: 16];
        UIFont * fontSmall5 = [UIFont boldSystemFontOfSize: 18];
        [self changeLabelFontSizeToFontBig:fontBig5 andFontMedium:fontMedium5 andFontSmall:fontSmall5];
        
        self.imageViewTopConstraint.constant = 120;
        
    }else if(result.height == 667){
        UIFont * fontBig6 = [UIFont boldSystemFontOfSize: 24];
        UIFont * fontMedium6 = [UIFont boldSystemFontOfSize: 18];
        UIFont * fontSmall6 = [UIFont boldSystemFontOfSize: 20];
        [self changeLabelFontSizeToFontBig:fontBig6 andFontMedium:fontMedium6 andFontSmall:fontSmall6];

        self.imageViewTopConstraint.constant = 140;

    }else {
        UIFont * fontBig7 = [UIFont boldSystemFontOfSize: 26];
        UIFont * fontMedium7 = [UIFont boldSystemFontOfSize: 20];
        UIFont * fontSmall7 = [UIFont boldSystemFontOfSize: 22];
        [self changeLabelFontSizeToFontBig:fontBig7 andFontMedium:fontMedium7 andFontSmall:fontSmall7];
        
        self.imageViewTopConstraint.constant = 160;
    }
    
    [self doHttpPost:USERPROFILE_URL token:player.userToken parameters:nil completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"Error: %@", error.description);
        }else{
            NSData * resultData = result;
            NSDictionary * resultDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if ([resultDictionary[@"success"] boolValue] == false) {
                NSLog(@"Server say error: %@", [resultDictionary[@"result"] description]);
            }else{
                NSDictionary * dataDictionary = resultDictionary[@"result"];
                NSLog(@"%@", dataDictionary.description);
                self.usernameLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"nickname"]];
                self.coinLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"coin"]];
                self.diamondLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"diamond"]];
                self.rankLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"rank"]];
                self.monsterQuantityLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"monsterQuantity"]];
                self.monsterTotalLevelLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"monsterTotalLevel"]];
                self.defeatMonsterLabel.text = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"defeatedMonster"]];
                
                if ([[dataDictionary objectForKey:@"practiceModePlay"] integerValue] == 0) {
                    self.practiceModeWinRateLabel.text = [NSString stringWithFormat:@"0%%"];
                }else {
                    double practiceModeWinRate = (double)[[dataDictionary objectForKey:@"practiceModeWin"] integerValue] / [[dataDictionary objectForKey:@"practiceModePlay"] integerValue] * 100;
                    self.practiceModeWinRateLabel.text = [NSString stringWithFormat:@"%.1f%%", practiceModeWinRate];
                }
                NSString * picURI = [NSString stringWithFormat:@"%@", [dataDictionary objectForKey:@"picture"]];
                NSString * imageURLStrng = [BASE_URL stringByAppendingPathComponent:picURI];
                NSURL * imageURL = [NSURL URLWithString:imageURLStrng];
                                     
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //下載網址物件的內容
                    NSData * imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
                    //將下載到的內容轉成圖片
                    UIImage * image = [UIImage imageWithData:imageData];
                    //切回主執行緒
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.userPicImageView.image = image;
                    });
                    
                });
            }
        }
    }];
    
    
}

- (IBAction)backButtonPressed:(id)sender {
    [[SoundEffect shareSound] playSoundEffect:voicePlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)changePhotoButtonPressed:(id)sender {
    __block UIImagePickerControllerSourceType sourceType;
    
    UIAlertController * actionSheet = [UIAlertController alertControllerWithTitle:@"更換頭像" message: @"請選擇照片來源" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* camera = [UIAlertAction actionWithTitle:@"照相機" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
        sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self handleImagePicker:sourceType];
    }];
    UIAlertAction* album = [UIAlertAction actionWithTitle:@"相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self handleImagePicker:sourceType];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler: nil];
    
    [actionSheet addAction:camera];
    [actionSheet addAction:album];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Self Methods

-(void) doHttpPost:(NSString *)URL token:(NSString *)token parameters:(NSDictionary *)parameters completion:(CompletionBlock)completion{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData * data = [NSData dataWithData:responseObject];
        completion(nil, data);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(error, nil);
        
        NSLog(@"doHttpPost error:%@",error.description);
    }];
}

-(void)changeLabelFontSizeToFontBig:(UIFont *)fontBig andFontMedium:(UIFont *)fontMedium andFontSmall:(UIFont *)fontSmall{
    self.usernameLabel.font = fontBig;
    self.coinLabel.font = fontMedium;
    self.diamondLabel.font = fontMedium;
    self.label1.font = fontSmall;
    self.label2.font = fontSmall;
    self.label3.font = fontSmall;
    self.label4.font = fontSmall;
    self.label5.font = fontSmall;
    self.rankLabel.font = fontSmall;
    self.monsterQuantityLabel.font = fontSmall;
    self.monsterTotalLevelLabel.font = fontSmall;
    self.defeatMonsterLabel.font = fontSmall;
    self.practiceModeWinRateLabel.font = fontSmall;
}

-(void)handleImagePicker:(UIImagePickerControllerSourceType)sourceType{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
        NSLog(@"Source type is not avalable");
        return;
    }
    
    imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        imagePicker.allowsEditing = true;  //可以裁切圖片
    }else if(sourceType == UIImagePickerControllerSourceTypeCamera){
        imagePicker.allowsEditing = true;
        imagePicker.showsCameraControls = true;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
    }
    
    [self presentViewController:imagePicker animated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage * originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage * editedImage = info[UIImagePickerControllerEditedImage];
    UIImage * finalImage = editedImage == nil?originalImage: editedImage;
    
    NSData * picData = UIImageJPEGRepresentation(finalImage, 0.05);
    NSString * picBase64 = [picData base64EncodedStringWithOptions:0];
    NSDictionary * jsonObj = @{@"pictureBase64":picBase64};
//    NSLog(@"%@", jsonObj);
    
    [self doHttpPost:CHANGEPHOTO_URL token:player.userToken parameters:jsonObj completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"Error: %@", error.description);
        }else{
            NSData * data = result;
            NSDictionary * dict  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([[dict objectForKey:@"success"] boolValue] == false) {
                NSLog(@"Server say error: %@", [[dict objectForKey:@"result"] description]);
            }else{
                self.userPicImageView.image = finalImage;
                
            }
        }
        
    }];
    
    //記得關掉系統提供的picker ViewController
    [picker dismissViewControllerAnimated:YES completion:nil];
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

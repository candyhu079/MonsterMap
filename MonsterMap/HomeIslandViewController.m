//
//  HomeIslandViewController.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/16.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "HomeIslandViewController.h"
#import "Items.h"
#import "Player.h"

@interface HomeIslandViewController ()<UIGestureRecognizerDelegate,NSFetchedResultsControllerDelegate>{
    
    Player * player;
    Items * items;
//    NSManagedObjectContext * context;
    NSMutableArray * userDecoArray;
    NSMutableArray * decoArray;
    NSMutableArray * decoImgOnGrassArray;
    NSMutableArray * btnDecoArray;
    NSInteger decoTag;
    NSInteger decoOnGrassTag;
    
    NSMutableArray * userMonsterArray;
    NSMutableArray * petMonsterArray;
    NSMutableArray * petImgOnGrassArray;
    NSMutableArray * btnMonsterArray;
    NSArray * grassArray;
    NSString * buildBtnPressed;
    NSInteger petTag;
    NSInteger itemsOnGrassTag;
    
    //畫草皮位置
    CGMutablePathRef grassRef;
}

@property (weak, nonatomic) IBOutlet UIView *darkView;
@property (weak, nonatomic) IBOutlet UIButton *deletePetBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteDecoBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *petScrollview;
@property (weak, nonatomic) IBOutlet UIImageView *petTagImage;

@property (weak, nonatomic) IBOutlet UIScrollView *decoScrollview;
@property (weak, nonatomic) IBOutlet UIImageView *decoTagImage;
@property (weak, nonatomic) IBOutlet UIImageView *decoFrameImage;
@property (weak, nonatomic) IBOutlet UIImageView *petFrameImage;
@property (weak, nonatomic) IBOutlet UIImageView *islandImage;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage01;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage02;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage03;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage04;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage05;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage06;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage07;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage08;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage09;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage10;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage11;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage12;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage13;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage14;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage15;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage16;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage17;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage18;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage19;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage20;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage21;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage22;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage23;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage24;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage25;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage26;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage27;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage28;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage29;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage30;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage31;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage32;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage33;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage34;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage35;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage36;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage37;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage38;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage39;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage40;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage41;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage42;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage43;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage44;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage45;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage46;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage47;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage48;
@property (weak, nonatomic) IBOutlet UIImageView *grassImage49;

@end

@implementation HomeIslandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    player = [Player playerSingleton];
    items = [Items itemsSingleton];
    userMonsterArray = [NSMutableArray new];
    petMonsterArray = [NSMutableArray new];
    petImgOnGrassArray = [NSMutableArray new];
    
    userDecoArray = [NSMutableArray new];
    decoArray = [NSMutableArray new];
    decoImgOnGrassArray = [NSMutableArray new];
    
    grassRef = CGPathCreateMutable();
    CGPathMoveToPoint(grassRef, NULL, 170, 192);
    CGPathAddLineToPoint(grassRef, NULL, 491, 375.5);
    CGPathAddLineToPoint(grassRef, NULL, 170,559);
    CGPathAddLineToPoint(grassRef, NULL, -291, 375.5);
    CGPathCloseSubpath(grassRef);
 
    
    //預設關閉 build frame
    buildBtnPressed = @"off";
    _petFrameImage.hidden = true;
    _decoFrameImage.hidden = true;
    _darkView.hidden = true;
    _deletePetBtn.hidden = true;
    _deleteDecoBtn.hidden = true;

    //草皮array
    grassArray = @[_grassImage01,_grassImage02,_grassImage03,_grassImage04,_grassImage05,_grassImage06,_grassImage07,_grassImage08,_grassImage09,_grassImage10,_grassImage11,_grassImage12,_grassImage13,_grassImage14,_grassImage15,_grassImage16,_grassImage17,_grassImage18,_grassImage19,_grassImage20,_grassImage21,_grassImage22,_grassImage23,_grassImage24,_grassImage25,_grassImage26,_grassImage27,_grassImage28,_grassImage29,_grassImage30,_grassImage31,_grassImage32,_grassImage33,_grassImage34,_grassImage35,_grassImage36,_grassImage37,_grassImage38,_grassImage39,_grassImage40,_grassImage41,_grassImage42,_grassImage43,_grassImage44,_grassImage45,_grassImage46,_grassImage47,_grassImage48,_grassImage49];
    
    //添加單指移動島嶼手勢
    [_islandImage addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mapPan:)]];
    //添加單指點擊寵物、裝飾品頁籤
    [_petTagImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buildChildFrameTap:)]];
    [_decoTagImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buildChildFrameTap:)]];
    [_islandImage setUserInteractionEnabled:YES];
    [_petTagImage setUserInteractionEnabled:YES];
    [_decoTagImage setUserInteractionEnabled:YES];
    
    //取得user monster
    [self getUserMonsterByPost];
    [self getUserDecorationByPost];
    
    }

//顯示monster btn
-(void)getPetBtnImage {
    
    int i;
    int x = 10;
    int y = 5;
    int width = 84;
    int height = 84;
    int buffer = 97;
    for (i = 0; i < userMonsterArray.count; i++)
    {
        //在scrollview產生pet小圖示
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x+(i*buffer),y,width,height);
        [button setImage:[UIImage imageWithData:[[userMonsterArray objectAtIndex:i] objectAtIndex:3]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickPetBtn:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger interI = i;
        button.tag = interI;
        [self.view addSubview:button];
        [btnMonsterArray addObject:button];
        [button setUserInteractionEnabled:YES];
        [_petScrollview addSubview:button];
    }
    [_petScrollview setNeedsLayout];
//    NSLog(@"getbtn_islandImage.frame:%@",NSStringFromCGPoint(_islandImage.frame.origin));
    _petScrollview.contentSize = CGSizeMake(107+(97*(userMonsterArray.count))+7, 93);
    [self hidePetBtn];

}
-(void)reloadPetBtnImage{
    int i;
    int x = 10;
    int y = 5;
    int width = 84;
    int height = 84;
    int buffer = 97;
    for (i = 0; i < userMonsterArray.count; i++)
    {
        //在scrollview產生pet小圖示
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x+(i*buffer),y,width,height);
        [button setImage:[UIImage imageWithData:[[userMonsterArray objectAtIndex:i] objectAtIndex:3]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickPetBtn:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger interI = i;
        button.tag = interI;
        [self.view addSubview:button];
        [btnMonsterArray addObject:button];
        [button setUserInteractionEnabled:YES];
        [_petScrollview addSubview:button];
    }
    [_petScrollview setNeedsLayout];
    //    NSLog(@"getbtn_islandImage.frame:%@",NSStringFromCGPoint(_islandImage.frame.origin));
    _petScrollview.contentSize = CGSizeMake(107+(97*(userMonsterArray.count))+7, 93);
    
}

//顯示deco btn
-(void)getDecoBtnImage {
    int i;
    int x = 10;
    int y = 5;
    int width = 84;
    int height = 84;
    int buffer = 97;
    for (i = 0; i < userDecoArray.count; i++)
    {
        //在scrollview產生pet小圖示
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x+(i*buffer),y,width,height);
        [button setImage:[UIImage imageWithData:[[userDecoArray objectAtIndex:i] objectAtIndex:3]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickDecoBtn:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger interI = i;
        button.tag = interI;
        [self.view addSubview:button];
        [btnDecoArray addObject:button];
//        NSLog(@"btnDecoArray:%@",btnDecoArray);
        [button setUserInteractionEnabled:YES];
        [_decoScrollview addSubview:button];
    }
    //    NSLog(@"getbtn_islandImage.frame:%@",NSStringFromCGPoint(_islandImage.frame.origin));
    _decoScrollview.contentSize = CGSizeMake(107+(97*(userDecoArray.count))+7, 93);
    [self hideDecoBtn];
}
-(void)reloadDecoBtnImage {
    int i;
    int x = 10;
    int y = 5;
    int width = 84;
    int height = 84;
    int buffer = 97;
    for (i = 0; i < userDecoArray.count; i++)
    {
        //在scrollview產生pet小圖示
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x+(i*buffer),y,width,height);
        [button setImage:[UIImage imageWithData:[[userDecoArray objectAtIndex:i] objectAtIndex:3]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickDecoBtn:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger interI = i;
        button.tag = interI;
        [self.view addSubview:button];
        [btnDecoArray addObject:button];
        //        NSLog(@"btnDecoArray:%@",btnDecoArray);
        [button setUserInteractionEnabled:YES];
        [_decoScrollview addSubview:button];
    }
    //    NSLog(@"getbtn_islandImage.frame:%@",NSStringFromCGPoint(_islandImage.frame.origin));
    _decoScrollview.contentSize = CGSizeMake(107+(97*(userDecoArray.count))+7, 93);
    
}

-(void)viewDidLayoutSubviews
{
    NSLog(@"viewWillLayoutSubviews");
    CGRect island = _islandImage.frame;
    _islandImage.frame = island;
    [_islandImage setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSLog(@"_islandImage.frame:%@",NSStringFromCGPoint(_islandImage.frame.origin));
//    NSLog(@"island.frame:%@",NSStringFromCGPoint(island.origin));
}

-(void)clickPetBtn:(UIButton*)sender {
    
    NSString * name = [[userMonsterArray objectAtIndex:sender.tag] objectAtIndex:0];
    NSString * petID = [[userMonsterArray objectAtIndex:sender.tag] objectAtIndex:1];
    NSData * picData = [[userMonsterArray objectAtIndex:sender.tag] objectAtIndex:2];
    NSData * btnPicData = [[userMonsterArray objectAtIndex:sender.tag] objectAtIndex:3];
    NSArray * petArray = [[NSArray alloc] initWithObjects:name,petID,picData,btnPicData, nil];
    [petMonsterArray addObject:petArray];
    
    int imgWidth = 90;
    int imgHeight = 90;
    //產生新的pet img, 增加到petMonsterArray
    UIImageView * petImg = [[UIImageView alloc] initWithFrame: CGRectMake(_grassImage12.frame.origin.x,_grassImage12.frame.origin.y-5,imgWidth,imgHeight)];
    petImg.image = [UIImage imageWithData:picData];
    [self.view addSubview:petImg];
    [petImgOnGrassArray addObject:petImg];
    petImg.tag = [petImgOnGrassArray indexOfObject:petImg];
    
    [petImg addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(monsterPan:)]];
    [petImg addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(monsterLongPress:)]];
    [petImg setUserInteractionEnabled:YES];
    //從userMonster裡移除
    [userMonsterArray removeObjectAtIndex:sender.tag];
    //更新 pet btns
    [self getPetBtnImage];
    [self showPetBtn];
//    NSLog(@"_grassImage12:%@",NSStringFromCGPoint(_grassImage12.frame.origin));
//    NSLog(@"img:%@",NSStringFromCGPoint(petImg.frame.origin));
//    NSLog(@"_petScrollview.contentSize:%@",NSStringFromCGSize(_petScrollview.contentSize));
}

-(void)clickDecoBtn:(UIButton*)sender {
    
    NSString * name = [[userDecoArray objectAtIndex:sender.tag] objectAtIndex:0];
    NSString * petID = [[userDecoArray objectAtIndex:sender.tag] objectAtIndex:1];
    NSData * picData = [[userDecoArray objectAtIndex:sender.tag] objectAtIndex:2];
    NSData * btnPicData = [[userDecoArray objectAtIndex:sender.tag] objectAtIndex:3];
    NSArray * decorationArray = [[NSArray alloc] initWithObjects:name,petID,picData,btnPicData, nil];
    [decoArray addObject:decorationArray];
    
    int imgWidth = 90;
    int imgHeight = 90;
    //產生新的pet img, 增加到decoArray
    UIImageView * petImg = [[UIImageView alloc] initWithFrame: CGRectMake(_grassImage12.frame.origin.x,_grassImage12.frame.origin.y-5,imgWidth,imgHeight)];
    petImg.image = [UIImage imageWithData:picData];
    [self.view addSubview:petImg];
    [decoImgOnGrassArray addObject:petImg];
    petImg.tag = [decoImgOnGrassArray indexOfObject:petImg];
    
    [petImg addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(monsterPan:)]];
    [petImg addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(decoLongPress:)]];
    [petImg setUserInteractionEnabled:YES];
    //從userMonster裡移除
    [userDecoArray removeObjectAtIndex:sender.tag];
    //更新 pet btns
    [self getDecoBtnImage];
    [self showDecoBtn];
}

//移動島嶼手勢
-(void)mapPan:(UIPanGestureRecognizer *) panGesture {
    
    CGPoint point = [panGesture translationInView:panGesture.view];
    CGPoint newCenter = CGPointMake(panGesture.view.center.x + point.x, panGesture.view.center.y + point.y);
    
    //限制移動島嶼範圍
    if (CGRectContainsPoint(CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height), newCenter)) {
        //        NSLog(@"new center : %@",NSStringFromCGPoint(newCenter));
        panGesture.view.center = newCenter;
        [panGesture setTranslation:CGPointZero inView:self.view];
        [panGesture.view updateConstraints];
        
        //島嶼移動時，草皮跟著移動
        for (UIImageView * grassImg in grassArray) {
            grassImg.center = CGPointMake(grassImg.center.x + point.x, grassImg.center.y + point.y);
            [grassImg updateConstraints];
        }
        //島嶼移動時，寵物跟著移動
        for (UIImageView * petImg in petImgOnGrassArray) {
            petImg.center = CGPointMake(petImg.center.x + point.x, petImg.center.y + point.y);
        }
        for (UIImageView * decoImg in decoImgOnGrassArray) {
            decoImg.center = CGPointMake(decoImg.center.x + point.x, decoImg.center.y + point.y);
        }
        
    };
}


- (void)monsterPan:(UIPanGestureRecognizer*)panGesture{
    
    CGPoint point = [panGesture translationInView:panGesture.view];
    CGPoint newCenter = CGPointMake(panGesture.view.center.x + point.x, panGesture.view.center.y + point.y);
    
    //限制中心只能在frame的框框內
//    if (CGRectContainsPoint(CGRectMake(_islandImage.frame.origin.x, _islandImage.frame.origin.y, _islandImage.bounds.size.width, _islandImage.bounds.size.height), newCenter)) {
    
    if (CGPathContainsPoint(grassRef, NULL, newCenter, NO)) {
        
        for (UIImageView * grass in grassArray) {
    
            int x = (grass.frame.origin.x)+22;
            int y = (grass.frame.origin.y)-13;
            int width = 30;
            int height = 20;
            
            if (CGRectContainsPoint(CGRectMake(x,y,width,height), panGesture.view.center)) {
                UIImage * darkGrass = [UIImage imageNamed:@"grassDark"];
                [grass setImage:darkGrass];

                CGPoint center = CGPointMake(grass.center.x, (grass.center.y)+10);
                panGesture.view.center = center;
                NSLog(@"grass center:%@",NSStringFromCGPoint(center));
                NSLog(@"panGesture.view.center:%@",NSStringFromCGPoint(panGesture.view.center));
                
                
                if(panGesture.state == UIGestureRecognizerStateEnded){
                    UIImage * grassImg = [UIImage imageNamed:@"grass"];
                    [grass setImage:grassImg];
                }
                
            }else{
                UIImage * grassImg = [UIImage imageNamed:@"grass"];
                [grass setImage:grassImg];
            }
        }
        panGesture.view.center = newCenter;
        [panGesture setTranslation:CGPointZero inView:self.view];
    }
}
- (void)monsterLongPress:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        _deletePetBtn.hidden = false;
        _deletePetBtn.frame = CGRectMake((longPressGesture.view.frame.origin.x)+20, (longPressGesture.view.frame.origin.y)+90,50,50);
        _deletePetBtn.layer.zPosition = 35;
        
        _darkView.hidden = false;
        _darkView.layer.zPosition = 30;
        [_darkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(darkviewPetTap:)]];
        [_darkView setUserInteractionEnabled:YES];

    }
    if (longPressGesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"longTouch UIGestureRecognizerStateEnded");
        itemsOnGrassTag = [petImgOnGrassArray indexOfObject:longPressGesture.view];
    }
}
- (void)decoLongPress:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        _deleteDecoBtn.hidden = false;
        _deleteDecoBtn.frame = CGRectMake((longPressGesture.view.frame.origin.x)+20, (longPressGesture.view.frame.origin.y)+90,50,50);
        _deleteDecoBtn.layer.zPosition = 35;
        
        _darkView.hidden = false;
        _darkView.layer.zPosition = 30;
        [_darkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(darkviewDecoTap:)]];
        [_darkView setUserInteractionEnabled:YES];
        
    }
    if (longPressGesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"longTouch UIGestureRecognizerStateEnded");
        itemsOnGrassTag = [decoImgOnGrassArray indexOfObject:longPressGesture.view];
    }
}

-(void)darkviewPetTap:(UITapGestureRecognizer *)tapGesture{
    _darkView.hidden = true;
    _deletePetBtn.hidden = true;
    
}
-(void)darkviewDecoTap:(UITapGestureRecognizer *)tapGesture{
    _darkView.hidden = true;
    _deleteDecoBtn.hidden = true;
    
}
- (IBAction)deleteItemOnGrassBtnPressed:(id)sender {

    UIImageView * monster = [petImgOnGrassArray objectAtIndex:itemsOnGrassTag];
    [monster removeFromSuperview];
    [userMonsterArray addObject:[petMonsterArray objectAtIndex:itemsOnGrassTag]];
    [petImgOnGrassArray removeObject:monster];
    [petMonsterArray removeObjectAtIndex:itemsOnGrassTag];
    [self reloadPetBtnImage];
    
    _deletePetBtn.hidden = true;
    _darkView.hidden = true;
}
- (IBAction)deletDecoOnGrassBtnPressed:(id)sender {
    
    UIImageView * monster = [decoImgOnGrassArray objectAtIndex:itemsOnGrassTag];
    [monster removeFromSuperview];
    [decoArray addObject:[decoArray objectAtIndex:itemsOnGrassTag]];
    [decoImgOnGrassArray removeObject:monster];
    [decoArray removeObjectAtIndex:itemsOnGrassTag];
    [self reloadDecoBtnImage];
    
    _deleteDecoBtn.hidden = true;
    _darkView.hidden = true;
}


- (IBAction)buildBtnPressed:(id)sender {
    
    //打開或關閉build frame
    if ([buildBtnPressed  isEqual: @"off"]) {
        _petFrameImage.hidden = false;
        _decoFrameImage.hidden = false;
        [self showPetBtn];
        [self showDecoBtn];
        buildBtnPressed = @"on";
    }else{
        _petFrameImage.hidden = true;
        _decoFrameImage.hidden = true;
        [self hidePetBtn];
        [self hideDecoBtn];
        buildBtnPressed = @"off";
    };
}
-(void)buildChildFrameTap:(UITapGestureRecognizer *) GR {
    //若點擊到寵物頁籤
    
    
    if ([GR view] == _petTagImage) {
        _petFrameImage.layer.zPosition = 20;
        _petTagImage.layer.zPosition = 21;
        _petScrollview.layer.zPosition = 22;
        _decoFrameImage.layer.zPosition = 10;
        _decoTagImage.layer.zPosition = 11;
        _decoScrollview.layer.zPosition = 12;
//        _decoScrollview.userInteractionEnabled = NO;
//        [_petScrollview becomeFirstResponder];
        [self.view bringSubviewToFront:_petScrollview];
        
        NSLog(@"pet frame pressed");
    //若點擊到裝飾品頁籤
    }else if ([GR view] == _decoTagImage){
        _decoFrameImage.layer.zPosition = 20;
        _decoTagImage.layer.zPosition = 21;
        _decoScrollview.layer.zPosition = 22;
        _petFrameImage.layer.zPosition = 10;
        _petTagImage.layer.zPosition = 11;
        _petScrollview.layer.zPosition = 12;
//        _petScrollview.userInteractionEnabled = NO;
//        [_decoScrollview becomeFirstResponder];
        [self.view bringSubviewToFront:_decoScrollview];
    
        NSLog(@"deco frame pressed");
    }
}
- (void)showPetBtn {
    _petScrollview.hidden = false;
    for (UIButton * btn in btnMonsterArray) {
        btn.hidden = false;
    }
}
- (void)hidePetBtn {
    _petScrollview.hidden = true;
    for (UIButton * btn in btnMonsterArray) {
        btn.hidden = true;
    }
}
- (void)showDecoBtn {
    _decoScrollview.hidden = false;
    for (UIButton * btn in btnDecoArray) {
        btn.hidden = false;
    }
}
- (void)hideDecoBtn {
    _decoScrollview.hidden = true;
    for (UIButton * btn in btnDecoArray) {
        btn.hidden = true;
    }
}

//按back button 跳回 3個島嶼頁面
- (IBAction)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//按shop button 跳 商店頁面
- (IBAction)shopBtnPressed:(id)sender {
    UIStoryboard * shopStoryBoard = [UIStoryboard storyboardWithName:@"Shop" bundle:nil];
    UIViewController * vc = [shopStoryBoard instantiateViewControllerWithIdentifier:@"ShopPetViewController"];
    [self showViewController:vc sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

- (IBAction)settingBtnPressed:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"Setting"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)rankBtnPressed:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"ThreeIslands" bundle:nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"Leaderboard"];
    [self presentViewController:vc animated:YES completion:nil];
}



#pragma mark - API Methods

- (void)getUserMonsterByPost {
    [items userMonsterPostToken:player.userToken completion:^(NSError *error, id result) {
        //若連線失敗
        if (error) {
            //顯示連線失敗
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
                NSDictionary * resultDic = [dic objectForKey:@"result"];
                //取出  dic 包的 array
                for (NSDictionary * dic in resultDic) {
                    NSString * name = [dic valueForKey:@"name"];
                    NSString * petID = [dic valueForKey:@"id"];
                    NSString * picPath = [dic valueForKey:@"picturePath"];
                    NSString * picString = [BASE_URL stringByAppendingString:picPath];
                    NSURL * picURL = [NSURL URLWithString:
                                      [picString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSData * picData = [NSData dataWithContentsOfURL:picURL];
                    
                    NSString * btnPicPath = [dic valueForKey:@"buttonPicturePath"];
                    NSString * btnPicString = [BASE_URL stringByAppendingString:btnPicPath];
                    NSURL * btnPicURL = [NSURL URLWithString:
                                         [btnPicString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSData * btnPicData = [NSData dataWithContentsOfURL:btnPicURL];
                    
                    NSArray * monsterArray = [[NSArray alloc] initWithObjects:name,petID,picData,btnPicData, nil];
                    [userMonsterArray addObject:monsterArray];
                }
                [self getPetBtnImage];
            }
        }
    }];
}

- (void)getUserDecorationByPost {
    [items userDecorationPostToken:player.userToken completion:^(NSError *error, id result) {
        //若連線失敗
        if (error) {
            //顯示連線失敗
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
                NSDictionary * resultDic = [dic objectForKey:@"result"];
                //取出  dic 包的 array
                for (NSDictionary * dic in resultDic) {
                    NSString * name = [dic valueForKey:@"itemName"];
//                    NSString * petID = [dic valueForKey:@"id"];
                    NSString * petID = @"";
                    NSString * picPath = [dic valueForKey:@"picturePath"];
                    NSString * picString = [BASE_URL stringByAppendingString:picPath];
                    NSURL * picURL = [NSURL URLWithString:
                                      [picString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSData * picData = [NSData dataWithContentsOfURL:picURL];
                    
                    NSString * btnPicPath = [dic valueForKey:@"buttonPicturePath"];
                    NSString * btnPicString = [BASE_URL stringByAppendingString:btnPicPath];
                    NSURL * btnPicURL = [NSURL URLWithString:
                                         [btnPicString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSData * btnPicData = [NSData dataWithContentsOfURL:btnPicURL];
                    
                    NSArray * decorationArray = [[NSArray alloc] initWithObjects:name,petID,picData,btnPicData, nil];

                    [userDecoArray addObject:decorationArray];
                }
                [self getDecoBtnImage];
            }
        }
    }];
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

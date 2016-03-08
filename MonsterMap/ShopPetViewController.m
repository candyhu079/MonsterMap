//
//  ShopPetViewController.m
//  MonsterMap
//
//  Created by 翁心苹 on 2016/2/5.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "ShopPetViewController.h"
#import "Player.h"
#import "Items.h"
#import <AFNetworking/AFNetworking.h>
#import <StoreKit/StoreKit.h>

@interface ShopPetViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    Player * player;
    Items * items;
    int buyBtnNumber;
    int needDiamondValue;
    int buyCoinsQuantity;
    NSMutableArray * decoArray;
    NSMutableArray * monsterArray;
    NSMutableArray * itemArray;
    NSArray * diamondBtnArray;
    NSArray * diamondArray;
}

//金幣、鑽石數量label
@property (weak, nonatomic) IBOutlet UILabel *coinLabel;
@property (weak, nonatomic) IBOutlet UILabel *diamondLabel;
//商品資訊label、picture
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
//下方scrollview表單
@property (weak, nonatomic) IBOutlet UILabel *petTabLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTabLabel;
@property (weak, nonatomic) IBOutlet UILabel *decoTabLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *petScrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *decoScrollview;
@property (weak, nonatomic) IBOutlet UIImageView *shopPetFrame;
@property (weak, nonatomic) IBOutlet UIImageView *shopItemFrame;
@property (weak, nonatomic) IBOutlet UIImageView *shopDecoFrame;
//商品小按鈕
@property (weak, nonatomic) IBOutlet UIButton *decoFireBtn;
//三個購買btn
@property (weak, nonatomic) IBOutlet UIButton *petBuyBtn;
@property (weak, nonatomic) IBOutlet UIButton *itemBuyBtn;
@property (weak, nonatomic) IBOutlet UIButton *decoBuyBtn;


//確認購買視窗
@property (weak, nonatomic) IBOutlet UIImageView *buySubmitFrame;
@property (weak, nonatomic) IBOutlet UILabel *buySubmitLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *buySubmitBtn;

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
//購買特定商品提示窗
@property (weak, nonatomic) IBOutlet UIImageView *buyAlertFrame;
@property (weak, nonatomic) IBOutlet UIButton *buyAlertAdmitBtn;
@property (weak, nonatomic) IBOutlet UILabel *buyAlertLabel;

//確定購買金幣frame
@property (weak, nonatomic) IBOutlet UIImageView *checkAdmitBuyCoinFrame;
@property (weak, nonatomic) IBOutlet UIButton *checkAdmitButCoinBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBuyCoinBtn;

@end

@implementation ShopPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideBuySubmitFrame];
    [self hideBuyCoinFrame];
    [self hideBuyAlertFrame];
    [self hideBuyDiamondFrame];
    [self hideNoDiamondFrame];
    [self hideComfirmBuyCoinFrame];
    [self setZPositionOfDiamondAndCoin];
    
    player = [Player playerSingleton];
    items = [Items itemsSingleton];
    monsterArray = [NSMutableArray new];
    decoArray = [NSMutableArray new];
    itemArray = [NSMutableArray new];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                   [NSSet setWithObjects:
                                    @"com.monsterTeam.diamond01",
                                    @"com.monsterTeam.diamond05",
                                    @"com.monsterTeam.diamond10",
                                    @"com.monsterTeam.diamond15",
                                    @"com.monsterTeam.diamond30",
                                    @"com.monsterTeam.diamond50",
                                    nil]];
    request.delegate = self;
    [request start];
    
    //新增頁籤tag點擊事件
    _petTabLabel.userInteractionEnabled = YES;
    _itemTabLabel.userInteractionEnabled = YES;
    _decoTabLabel.userInteractionEnabled = YES;
    [_petTabLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTap:)]];
    [_itemTabLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTap:)]];
    [_decoTabLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTap:)]];
    //取得user金幣和鑽石數量
    _coinLabel.text = [NSString stringWithFormat:@"%@",player.coin];
    _diamondLabel.text = [NSString stringWithFormat:@"%@",player.diamond];
    //取得篩店賣的所有商品
    [self getAllDecorationsByPost];
    [self getAllItemsByPost];
    [self getAllMonstersByPost];
}
//為scrollview設contentSize
-(void) viewDidLayoutSubviews{
    _petScrollview.contentSize = CGSizeMake(250, 740);
    _itemScrollview.contentSize = CGSizeMake(250, 300);
    _decoScrollview.contentSize = CGSizeMake(250, 360);
}

//當點擊產品，顯示產品資訊
- (IBAction)decoBtnPressed:(id)sender {
    NSInteger tag = [sender tag];
    [self getDecoDetial:tag];
    _petBuyBtn.hidden = true;
    _itemBuyBtn.hidden = true;
    _decoBuyBtn.hidden = false;
}
- (IBAction)itemBtnPressed:(id)sender {
    NSInteger tag = [sender tag];
    [self getItemDetail:tag];
    _petBuyBtn.hidden = true;
    _itemBuyBtn.hidden = false;
    _decoBuyBtn.hidden = true;
}
- (IBAction)monsterBtnPressed:(id)sender {
    NSInteger tag = [sender tag];
    [self getMonsterDetail:tag];
    _petBuyBtn.hidden = false;
    _itemBuyBtn.hidden = true;
    _decoBuyBtn.hidden = true;
}

//scrollview 頁籤點擊事件方法
-(void)tagTap:(UITapGestureRecognizer *)tapGesture{
    if ([tapGesture view] == _petTabLabel) {
        _petTabLabel.layer.zPosition = 20;
        _petScrollview.layer.zPosition = 19;
        _shopPetFrame.layer.zPosition = 18;
        _itemTabLabel.layer.zPosition = 17;
        _itemScrollview.layer.zPosition = 16;
        _shopItemFrame.layer.zPosition = 15;
        _decoTabLabel.layer.zPosition = 14;
        _decoScrollview.layer.zPosition = 13;
        _shopDecoFrame.layer.zPosition = 12;
        _productNameLabel.text = @"";
        _productDescriptionLabel.text = @"";
        _productPriceLabel.text = @"";
        _itemScrollview.userInteractionEnabled = NO;
        _decoScrollview.userInteractionEnabled = NO;
        [_petScrollview becomeFirstResponder];
        [_productImage setImage:[UIImage imageNamed:@"questionMark"]];
        
    }else if ([tapGesture view] == _itemTabLabel){
        _petTabLabel.layer.zPosition = 14;
        _petScrollview.layer.zPosition = 13;
        _shopPetFrame.layer.zPosition = 12;
        _itemTabLabel.layer.zPosition = 20;
        _itemScrollview.layer.zPosition = 19;
        _shopItemFrame.layer.zPosition = 18;
        _decoTabLabel.layer.zPosition = 17;
        _decoScrollview.layer.zPosition = 16;
        _shopDecoFrame.layer.zPosition = 15;
        _productNameLabel.text = @"";
        _productDescriptionLabel.text = @"";
        _productPriceLabel.text = @"";
        _decoScrollview.userInteractionEnabled = NO;
        _petScrollview.userInteractionEnabled = NO;
        [_itemScrollview becomeFirstResponder];
        [_productImage setImage:[UIImage imageNamed:@"questionMark"]];
    }else{
        _petTabLabel.layer.zPosition = 17;
        _petScrollview.layer.zPosition = 16;
        _shopPetFrame.layer.zPosition = 15;
        _itemTabLabel.layer.zPosition = 14;
        _itemScrollview.layer.zPosition = 13;
        _shopItemFrame.layer.zPosition = 12;
        _decoTabLabel.layer.zPosition = 20;
        _decoScrollview.layer.zPosition = 19;
        _shopDecoFrame.layer.zPosition = 18;
        _productNameLabel.text = @"";
        _productDescriptionLabel.text = @"";
        _productPriceLabel.text = @"";
        _petScrollview.userInteractionEnabled = NO;
        _itemScrollview.userInteractionEnabled = NO;
        [_decoScrollview becomeFirstResponder];
        [_productImage setImage:[UIImage imageNamed:@"questionMark"]]; 
    }
}
//特定商品購買btn點擊
- (IBAction)buyBtnPressed:(id)sender {
    [self showBuySubmitFrame];
    NSLog(@"sender tag:%ld",(long)[sender tag]);
    if ([sender tag] == 0) {
        buyBtnNumber = 0;
    }else if ([sender tag] == 1){
        buyBtnNumber = 1;
    }else{
        buyBtnNumber = 2;
    }
    _buyNameLabel.text = _productNameLabel.text;
    _buyPriceLabel.text = _productPriceLabel.text;
    NSLog(@"buyBtnNumber:%d",buyBtnNumber);
}

//顯示comfirm購買特定商品框
-(void)showBuySubmitFrame{
    _buySubmitBtn.hidden = false;
    _buyCancelBtn.hidden = false;
    _buySubmitLabel.hidden = false;
    _buyNameLabel.hidden = false;
    _buySubmitFrame.hidden = false;
    _buyPriceLabel.hidden = false;
    
    _buySubmitLabel.layer.zPosition = 32;
    _buyNameLabel.layer.zPosition = 32;
    _buyPriceLabel.layer.zPosition = 32;
    _buySubmitBtn.layer.zPosition = 31;
    _buyCancelBtn.layer.zPosition = 31;
    _buySubmitFrame.layer.zPosition = 30;
}
//隱藏comfirm購買特定商品框
-(void)hideBuySubmitFrame{
    _buySubmitBtn.hidden = true;
    _buyCancelBtn.hidden = true;
    _buySubmitLabel.hidden = true;
    _buyNameLabel.hidden = true;
    _buySubmitFrame.hidden = true;
    _buyPriceLabel.hidden = true;
}
//確定購買特定商品
- (IBAction)buySubmitBtnPressed:(id)sender {
    if ([player.coin intValue] < [_productPriceLabel.text intValue]) {
        [self hideBuySubmitFrame];
        [self showBuyAlertFrame];
        _buyAlertLabel.text = @"金幣數量不夠";
    }else{
        if (buyBtnNumber == 0) {
            [self buyMonsterByCoin];
        }else if (buyBtnNumber == 1){
            [self buyItemByCoin];
        }else{
            [self buyDecoByCoin];
        }
    }
}
//取消確定購買特定商品
- (IBAction)buyCancelBtnPressed:(id)sender {
    [self hideBuySubmitFrame];
}
//點擊購買金幣btn
- (IBAction)buyCoinBtnPressed:(id)sender {
    [self showBuyCoinFrame];
}
//取消購買金幣btn
- (IBAction)buyCoinFrameCancelBtnPressed:(id)sender {
    [self hideBuyCoinFrame];
}
//確定購買coin1 btn
- (IBAction)buyCoin1BtnPressed:(id)sender {
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
    if ([player.diamond intValue] >= 5) {
        needDiamondValue = 5;
        buyCoinsQuantity = 700;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//確定購買coin3 btn
- (IBAction)buyCoin3BtnPressed:(id)sender {
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
    if ([_diamondLabel.text intValue] >= 50) {
        needDiamondValue = 50;
        [self showComfirmBuyCoinFrame];
    }else{
        [self showNoDiamondFrame];
    }
}
//點擊購買鑽石btn
- (IBAction)buyDiamondBtnPressed:(id)sender {
    [self showBuyDiamondFrame];
}
//取消購買鑽石btn
- (IBAction)buyDiamondFrameCancelBtnPressed:(id)sender {
    [self hideBuyDiamondFrame];
}
//關閉鑽石數量不夠視窗btn
- (IBAction)noDiamondAdmitBtnPressed:(id)sender {
    [self hideNoDiamondFrame];
}
- (IBAction)buyAlertAdmitBtnPressed:(id)sender {
    [self hideBuyAlertFrame];
}
-(void)hideBuyAlertFrame {
    _buyAlertFrame.hidden = true;
    _buyAlertAdmitBtn.hidden = true;
    _buyAlertLabel.hidden = true;
}
-(void)showBuyAlertFrame {
    _buyAlertFrame.hidden = false;
    _buyAlertAdmitBtn.hidden = false;
    _buyAlertLabel.hidden = false;
}
//關閉購買鑽石視窗btn
- (IBAction)cancelBuyCoinBtnPressed:(id)sender {
    [self hideComfirmBuyCoinFrame];
}
//點擊確定confirm購買金幣
- (IBAction)checkAdmitBuyCoinBtnPressed:(id)sender {
    player.diamond = [NSNumber numberWithInt:([player.diamond intValue] - needDiamondValue)];
    _diamondLabel.text = [NSString stringWithFormat:@"%@",player.diamond];
    _coinLabel.text = [NSString stringWithFormat:@"%d",[player.coin intValue] + buyCoinsQuantity];
    [self buyCoinByDiamond];
    [self hideComfirmBuyCoinFrame];
}
//顯示購買金幣框
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
//隱藏購買金幣框
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
//顯示鑽石數量不夠視窗
-(void)showNoDiamondFrame {
    _noDiamondFrame.hidden = false;
    _noDiamondAdmitBtn.hidden = false;
}
//隱藏鑽石數量不夠視窗
-(void)hideNoDiamondFrame {
    _noDiamondFrame.hidden = true;
    _noDiamondAdmitBtn.hidden = true;
}
//顯示購買鑽石框
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
//隱藏購買鑽石框
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

//隱藏confirm購買鑽石視窗
-(void)hideComfirmBuyCoinFrame {
    _checkAdmitBuyCoinFrame.hidden = true;
    _checkAdmitButCoinBtn.hidden = true;
    _cancelBuyCoinBtn.hidden = true;
}
//顯示confirm購買鑽石視窗
-(void)showComfirmBuyCoinFrame {
    _checkAdmitBuyCoinFrame.hidden = false;
    _checkAdmitButCoinBtn.hidden = false;
    _cancelBuyCoinBtn.hidden = false;
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    for (NSString * invalidID in response.invalidProductIdentifiers) {
        NSLog(@"可以賣的產品：%@",invalidID);
    }
    if (response.products.count > 0) {
        diamondArray = response.products;
    }
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for (SKPaymentTransaction * transaction in  transactions) {
        switch (transaction.transactionState) {
                //第一次購買，且付款成功
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                break;
            case SKPaymentTransactionStateRestored:
                break;
                // 需要親子授權
            case SKPaymentTransactionStateDeferred:
                break;
            default:
                break;
        }
    }
}
//更新顯示的鑽石數量
-(void) completeTransaction:(SKPaymentTransaction*)transaction{
    NSString * diamondValue = @"";
    if ([transaction.payment.productIdentifier isEqualToString:@"com.monsterTeam.diamond01"]){
        diamondValue = [NSString stringWithFormat:@"%d",[player.diamond intValue] + 1];
    }else if ([transaction.payment.productIdentifier isEqualToString:@"com.monsterTeam.diamond05"]){
        diamondValue = [NSString stringWithFormat:@"%d",[player.diamond intValue] + 5];
    }else if ([transaction.payment.productIdentifier isEqualToString:@"com.monsterTeam.diamond10"]){
        diamondValue = [NSString stringWithFormat:@"%d",[player.diamond intValue] + 10];
    }else if ([transaction.payment.productIdentifier isEqualToString:@"com.monsterTeam.diamond15"]){
        diamondValue = [NSString stringWithFormat:@"%d",[player.diamond intValue] + 15];
    }else if ([transaction.payment.productIdentifier isEqualToString:@"com.monsterTeam.diamond30"]){
        diamondValue = [NSString stringWithFormat:@"%d",[player.diamond intValue] + 30];
    }else{
        diamondValue = [NSString stringWithFormat:@"%d",[player.diamond intValue] + 50];
    }
    _diamondLabel.text = diamondValue;
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
//點擊購買鑽石按鈕，新增購買訂單動作
- (IBAction)buyDiamondBtnTapped:(id)sender {
    if ([SKPaymentQueue canMakePayments]) {
        UIButton *buyButton = (UIButton *)sender;
        SKProduct *product = diamondArray[buyButton.tag];
        SKPayment * payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        NSLog(@"Buying %@...", product.productIdentifier);
    }
}

- (IBAction)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
- (void)setZPositionOfDiamondAndCoin {
    _darkView.layer.zPosition = 40;
    _buyCoinFrame.layer.zPosition = 41;
    _buyCoin1Btn.layer.zPosition = 42;
    _buyCoin2Btn.layer.zPosition = 42;
    _buyCoin3Btn.layer.zPosition = 42;
    _buyCoin4Btn.layer.zPosition = 42;
    _buyCoin5Btn.layer.zPosition = 42;
    _buyCoin6Btn.layer.zPosition = 42;
    _buyCoinFrameCancelBtn.layer.zPosition = 42;
    _buyDiamondFrame.layer.zPosition = 40;
    _buyDiamond1Btn.layer.zPosition = 41;
    _buyDiamond2Btn.layer.zPosition = 41;
    _buyDiamond3Btn.layer.zPosition = 41;
    _buyDiamond4Btn.layer.zPosition = 41;
    _buyDiamond5Btn.layer.zPosition = 41;
    _buyDiamond6Btn.layer.zPosition = 41;
    _buyDiamondFrameCancelBtn.layer.zPosition = 42;
    //鑽石數量不足frame
    _noDiamondFrame.layer.zPosition = 43;
    _noDiamondAdmitBtn.layer.zPosition = 44;
    //購買特定商品提示窗
    _buyAlertFrame.layer.zPosition = 45;
    _buyAlertAdmitBtn.layer.zPosition = 45;
    _buyAlertLabel.layer.zPosition = 45;
    
    //確定購買金幣frame
    _checkAdmitBuyCoinFrame.layer.zPosition = 43;
    _checkAdmitButCoinBtn.layer.zPosition = 44;
    _cancelBuyCoinBtn.layer.zPosition = 44;
}

#pragma mark - Get Products Detail Methods

- (void) getDecoDetial: (NSUInteger)index {
    
    NSDictionary * dic = [decoArray objectAtIndex:index];
    //取得特定商品圖片
    NSString * picPath = [dic valueForKey:@"picturePath"];
    NSString * picString = [BASE_URL stringByAppendingString:picPath];
    NSURL * picURL = [NSURL URLWithString:
                      [picString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData * picData = [NSData dataWithContentsOfURL:picURL];
    _productImage.image = [UIImage imageWithData:picData];
    
    //顯示特定商品資訊
    _productNameLabel.text = [dic objectForKey:@"name"];
    _productDescriptionLabel.text = [dic objectForKey:@"description"];
    _productPriceLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"price"]];
    
}
- (void) getItemDetail: (NSUInteger)index {
    NSDictionary * dic = [itemArray objectAtIndex:index];
    //取得特定商品圖片
    NSString * picPath = [dic valueForKey:@"picturePath"];
    NSString * picString = [BASE_URL stringByAppendingString:picPath];
    NSURL * picURL = [NSURL URLWithString:
                      [picString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData * picData = [NSData dataWithContentsOfURL:picURL];
    _productImage.image = [UIImage imageWithData:picData];
    
    //顯示特定商品資訊
    _productNameLabel.text = [dic objectForKey:@"name"];
    _productDescriptionLabel.text = [dic objectForKey:@"description"];
    _productPriceLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"price"]];
    
}
- (void) getMonsterDetail: (NSUInteger)index {
    NSDictionary * dic = [monsterArray objectAtIndex:index];
    //取得特定商品圖片
    NSString * picPath = [dic valueForKey:@"picturePath"];
    NSString * picString = [BASE_URL stringByAppendingString:picPath];
    NSURL * picURL = [NSURL URLWithString:
                      [picString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData * picData = [NSData dataWithContentsOfURL:picURL];
    _productImage.image = [UIImage imageWithData:picData];
    
    //顯示特定商品資訊
    NSString * type = @"屬性  ";
    _productNameLabel.text = [dic objectForKey:@"name"];
    _productDescriptionLabel.text = [type stringByAppendingString:[dic objectForKey:@"type"]];
    _productPriceLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"price"]];
    
}

#pragma mark - API Methods

//取得商店賣的所有寵物資訊
- (void) getAllMonstersByPost {
    
    [items shopMonsterPostToken:player.userToken completion:^(NSError *error, id result) {
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
                NSDictionary * resultDic = [dic objectForKey:@"result"];
                //取出  dic 包的 array
                for (NSArray * resultArray in resultDic) {
                    [monsterArray addObject:resultArray];
                    NSLog(@"Monster array:%@",resultArray);
                }
            }
        }
    }];
}
- (void) getAllItemsByPost {
    
    [items shopItemPostToken:player.userToken completion:^(NSError *error, id result) {
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
                NSDictionary * resultDic = [dic objectForKey:@"result"];
                //取出  dic 包的 array
                for (NSArray * resultArray in resultDic) {
                    [itemArray addObject:resultArray];
                    NSLog(@"Items array:%@",resultArray);
                }
            }
        }
    }];
}
//取得商店賣的所有裝飾品資訊
- (void) getAllDecorationsByPost {

    [items shopDecorationPostToken:player.userToken completion:^(NSError *error, id result) {
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
                NSDictionary * resultDic = [dic objectForKey:@"result"];
                //取出  dic 包的 array
                for (NSArray * resultArray in resultDic) {
                    [decoArray addObject:resultArray];
                    NSLog(@"Decoration array:%@",resultArray);
                }
            }
        }
    }];
}
//利用鑽石購買金幣
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

//用金幣購買裝飾品
- (void)buyDecoByCoin {
    [items shopCoinDecorationPostToken:player.userToken item:_productNameLabel.text completion:^(NSError *error, id result) {
        //若連線失敗
        if (error) {
            //顯示連線失敗
            NSLog(@"error:%@",error.description);
            [self hideBuySubmitFrame];
            [self showBuyAlertFrame];
            _buyAlertLabel.text = @"連線失敗";
            //若連線成功
        }else{
            //接server回傳的result
            NSData * data = result;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //若result是error
            if ([[dic objectForKey:@"success"] boolValue] == false) {
                NSLog(@"get data error:%@",[[dic objectForKey:@"result"] description]);
                //顯示購買失敗
                [self hideBuySubmitFrame];
                [self showBuyAlertFrame];
                _buyAlertLabel.text = @"購買失敗";
                NSLog(@"itemName:%@",_productNameLabel.text);
                //若result是success
            }else{
                //取出 result 包的 dic
                NSString * resultString = [dic objectForKey:@"result"];
                NSLog(@"resultString:%@",resultString);
                player.coin = [NSNumber numberWithInt:[player.coin intValue]-[_productPriceLabel.text intValue]];
                _coinLabel.text = [NSString stringWithFormat:@"%@",player.coin];
                //顯示購買成功
                [self hideBuySubmitFrame];
                [self showBuyAlertFrame];
                _buyAlertLabel.text = @"購買成功";
            }
        }
    }];
}


//用金幣購買寵物
- (void)buyMonsterByCoin {
    
    [items shopCoinMonsterPostToken:player.userToken item:_productNameLabel.text completion:^(NSError *error, id result) {
        //若連線失敗
        NSLog(@"_productNameLabel:%@",_productNameLabel.text);
        if (error) {
            //顯示連線失敗
            NSLog(@"error:%@",error.description);
            [self hideBuySubmitFrame];
            [self showBuyAlertFrame];
            _buyAlertLabel.text = @"連線失敗";
            //若連線成功
        }else{
            //接server回傳的result
            NSData * data = result;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //若result是error
            if ([[dic objectForKey:@"success"] boolValue] == false) {
                NSLog(@"get data error:%@",[[dic objectForKey:@"result"] description]);
                //顯示購買失敗
                [self hideBuySubmitFrame];
                [self showBuyAlertFrame];
                _buyAlertLabel.text = @"購買失敗";
                NSLog(@"itemName:%@",_productNameLabel.text);
                //若result是success
            }else{
                //取出 result 包的 dic
                NSString * resultString = [dic objectForKey:@"result"];
                NSLog(@"resultString:%@",resultString);
                player.coin = [NSNumber numberWithInt:[player.coin intValue]-[_productPriceLabel.text intValue]];
                _coinLabel.text = [NSString stringWithFormat:@"%@",player.coin];
                //顯示購買成功
                [self hideBuySubmitFrame];
                [self showBuyAlertFrame];
                _buyAlertLabel.text = @"購買成功";
            }
        }
    }];
    
}
- (void)buyItemByCoin {
    
    [items shopCoinItemPostToken:player.userToken item:_productNameLabel.text completion:^(NSError *error, id result) {
        //若連線失敗
        if (error) {
            //顯示連線失敗
            NSLog(@"error:%@",error.description);
            [self hideBuySubmitFrame];
            [self showBuyAlertFrame];
            _buyAlertLabel.text = @"連線失敗";
            //若連線成功
        }else{
            //接server回傳的result
            NSData * data = result;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //若result是error
            if ([[dic objectForKey:@"success"] boolValue] == false) {
                NSLog(@"get data error:%@",[[dic objectForKey:@"result"] description]);
                //顯示購買失敗
                [self hideBuySubmitFrame];
                [self showBuyAlertFrame];
                _buyAlertLabel.text = @"購買失敗";
                NSLog(@"itemName:%@",_productNameLabel.text);
                //若result是success
            }else{
                //取出 result 包的 dic
                NSString * resultString = [dic objectForKey:@"result"];
                NSLog(@"resultString:%@",resultString);
                player.coin = [NSNumber numberWithInt:[player.coin intValue]-[_productPriceLabel.text intValue]];
                _coinLabel.text = [NSString stringWithFormat:@"%@",player.coin];
                //顯示購買成功
                [self hideBuySubmitFrame];
                [self showBuyAlertFrame];
                _buyAlertLabel.text = @"購買成功";
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

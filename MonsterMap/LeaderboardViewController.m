//
//  LeaderboardViewController.m
//  MonsterMap
//
//  Created by 劉松樺 on 2016/2/25.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "AFNetworking.h"
#import "Player.h"
#import "LeaderboardTableViewCell.h"

//#define TOKEN   @"123"

@interface LeaderboardViewController()
<UITableViewDataSource,UITableViewDelegate>
{
    //Candy Add
    Player * player;
    
    NSMutableDictionary * leaderboardJson;
    NSMutableDictionary * leaderboard;
    
    NSMutableArray * displayArray;
    NSMutableArray * pictureArray;
    
    NSMutableArray * practiceModeWinRateArray;
    NSMutableArray * practiceModeWinRateNicknameArray;
    NSMutableArray * practiceModeWinRatePicPathArray;
    
    NSMutableArray * rankArray;
    NSMutableArray * rankNicknameArray;
    NSMutableArray * rankPicPathArray;

    NSMutableArray * monsterQuantityArray;
    NSMutableArray * monsterQuantityNicknameArray;
    NSMutableArray * monsterQuantityPicPathArray;
    
    NSMutableArray * monsterTotalLevelArray;
    NSMutableArray * monsterTotalLevelNicknameArray;
    NSMutableArray * monsterTotalLevelPicPathArray;
    
    NSMutableArray * defeatedMonsterArray;
    NSMutableArray * defeatedMonsterNicknameArray;
    NSMutableArray * defeatedMonsterPicPathArray;
}

@property (weak, nonatomic) IBOutlet UITableView *leaderboardTableView;
@property (weak, nonatomic) IBOutlet UIButton *practiceModeWinRateButtonRed;
@property (weak, nonatomic) IBOutlet UIButton *rankButtonRed;
@property (weak, nonatomic) IBOutlet UIButton *monsterQuantityButtonRed;
@property (weak, nonatomic) IBOutlet UIButton *monsterTotalLevelButtonRed;
@property (weak, nonatomic) IBOutlet UIButton *defeatMonsterButtonRed;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Candy Add
    player = [Player playerSingleton];
    self.leaderboardTableView.backgroundColor = [UIColor clearColor];

    
    
    //建立資料庫的連線
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:player.userToken forHTTPHeaderField:@"token"];
    
    [manager POST:@"http://192.168.197.112:8080/rank" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSError * error;
        NSData * data = [NSData dataWithData:responseObject];
        //下載的json檔
        leaderboardJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",leaderboardJson);
        //排行榜的dictionary
        leaderboard = [leaderboardJson objectForKey:@"result"];
        //練習模式勝率
        practiceModeWinRateArray = [leaderboard objectForKey:@"practiceModeWinRate"];
        practiceModeWinRateNicknameArray = [practiceModeWinRateArray valueForKey:@"nickname"];
        practiceModeWinRatePicPathArray = [practiceModeWinRateArray valueForKey:@"picPath"];
        //排行賽排名
        rankArray = [leaderboard objectForKey:@"rank"];
        rankNicknameArray = [rankArray valueForKey:@"nickname"];
        rankPicPathArray = [rankArray valueForKey:@"picPath"];
        //寵物數量
        monsterQuantityArray = [leaderboard objectForKey:@"monsterQuantity"];
        monsterQuantityNicknameArray = [monsterQuantityArray valueForKey:@"nickname"];
        monsterQuantityPicPathArray = [monsterQuantityArray valueForKey:@"picPath"];
        //寵物等級總和
        monsterTotalLevelArray = [leaderboard objectForKey:@"monsterTotalLevel"];
        monsterTotalLevelNicknameArray = [monsterTotalLevelArray valueForKey:@"nickname"];
        monsterTotalLevelPicPathArray = [monsterTotalLevelArray valueForKey:@"picPath"];
        //擊敗怪物數量
        defeatedMonsterArray = [leaderboard objectForKey:@"defeatedMonster"];
        defeatedMonsterNicknameArray = [defeatedMonsterArray valueForKey:@"nickname"];
        defeatedMonsterPicPathArray = [defeatedMonsterArray valueForKey:@"picPath"];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"error: %@",error.description);
    }];
    
    self.leaderboardTableView.delegate = self;
    self.leaderboardTableView.dataSource = self;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self practiceModeWinRateBtnPressed:nil];
    [_leaderboardTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    
    return [displayArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //灰色的選擇背景消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"Cell";
    LeaderboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    if (cell == nil){
//        //tableViewCell初始化，選擇有subtitle的
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    
    //textLabel顯示名次
    cell.rankLabel.text = [NSString stringWithFormat:@" %ld ",indexPath.row + 1];
    //detailLabel顯示玩家ID
    cell.nicknameLabel.text = [NSString stringWithFormat: @"%@", [displayArray objectAtIndex:indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    
    NSString * urlString = [BASE_URL stringByAppendingPathComponent:[pictureArray objectAtIndex:indexPath.row]];
    NSURL * url = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * picData = [NSData dataWithContentsOfURL:url];
        UIImage * image = [UIImage imageWithData:picData];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.userPhotoImageView.layer.cornerRadius = cell.userPhotoImageView.frame.size.width / 2;
            cell.userPhotoImageView.layer.masksToBounds = true;
            cell.userPhotoImageView.image = image;
        });
    });
    
//    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    UIImage * photo = [UIImage imageNamed:@"profile.png"];
//    photoImageView.image = photo;
//    cell.accessoryView = photoImageView;
    
    return cell;
}

- (IBAction)practiceModeWinRateBtnPressed:(id)sender {
    //原本顯示的陣列初始化後，將practiceModeWinRateArray寫入並更新tableview的資料
    displayArray = [[NSMutableArray alloc]initWithArray:practiceModeWinRateNicknameArray];
    pictureArray = [[NSMutableArray alloc]initWithArray:practiceModeWinRatePicPathArray];
    [_leaderboardTableView reloadData];
    
    [self showButtonRed:self.practiceModeWinRateButtonRed];
}

- (IBAction)rankBtnPressed:(id)sender {
    //原本顯示的陣列初始化後，將rankArray寫入並更新tableview的資料
    displayArray = [[NSMutableArray alloc]initWithArray:rankNicknameArray];
    pictureArray = [[NSMutableArray alloc]initWithArray:rankPicPathArray];
    [_leaderboardTableView reloadData];
    
    [self showButtonRed:self.rankButtonRed];
}

- (IBAction)monsterQuantityBtnPressed:(id)sender {
    //原本顯示的陣列初始化後，將monsterQuantityArray的陣列寫入並更新tableview的資料
    displayArray = [[NSMutableArray alloc]initWithArray:monsterQuantityNicknameArray];
    pictureArray = [[NSMutableArray alloc]initWithArray:monsterQuantityPicPathArray];
    [_leaderboardTableView reloadData];
    
    [self showButtonRed:self.monsterQuantityButtonRed];
}

- (IBAction)monsterTotalLevelBtnPressed:(id)sender {
    //原本顯示的陣列初始化後，將monsterTotalLevelArray寫入並更新tableview的資料
    displayArray = [[NSMutableArray alloc]initWithArray:monsterTotalLevelNicknameArray];
    pictureArray = [[NSMutableArray alloc]initWithArray:monsterTotalLevelPicPathArray];
    [_leaderboardTableView reloadData];
    
    [self showButtonRed:self.monsterTotalLevelButtonRed];
}

- (IBAction)defeatedMonsterBtnPressed:(id)sender {
    //原本顯示的陣列初始化後，將defeatedMonsterArray寫入並更新tableview的資料
    displayArray = [[NSMutableArray alloc]initWithArray:defeatedMonsterNicknameArray];
    pictureArray = [[NSMutableArray alloc]initWithArray:defeatedMonsterPicPathArray];
    [_leaderboardTableView reloadData];
    
    [self showButtonRed:self.defeatMonsterButtonRed];
}
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Candy Add

-(void)showButtonRed:(UIButton *)button{
    self.practiceModeWinRateButtonRed.hidden = true;
    self.monsterQuantityButtonRed.hidden = true;
    self.monsterTotalLevelButtonRed.hidden = true;
    self.defeatMonsterButtonRed.hidden  =true;
    self.rankButtonRed.hidden = true;
    button.hidden = false;
}
@end

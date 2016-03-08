//
//  LeaderboardTableViewCell.h
//  MonsterMap
//
//  Created by Candy on 2016/2/29.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;

@end

//
//  BirdGameSetting.swift
//  MonsterMap
//
//  Created by 林尚恩 on 2016/3/10.
//  Copyright © 2016年 MonsterTeam. All rights reserved.
//

import Foundation

class BirdGameSetting {
    enum URL:String{
        case URLBegining="http://api.leolin.me"
        case Monster="http://api.leolin.me/monster"
        case UserMonster="http://api.leolin.me/userMonster"
        case MyMonsterForFighting="http://api.leolin.me/myMonsterForFighting"
        case SettingUserMonsterBlood="http://api.leolin.me/settingUserMonsterBlood"
        case MonsterAddExperience="http://api.leolin.me/monsterAddExperience"
        case DefeatMonster="http://api.leolin.me/defeatMonster"
        case CatchMonster="http://api.leolin.me/catchMonster"
        case UseItem="http://api.leolin.me/useItem"
        case InventoryItem="http://api.leolin.me/inventoryItem"
        case InventoryDecorationForBackpack="http://api.leolin.me/inventoryDecorationForBackpack"
        case SellItem="http://api.leolin.me/sellItem"
        case SellDecoration="http://api.leolin.me/sellDecoration"
        case SellMonster="http://api.leolin.me/sellMonster"
        case SettingUserMonster="http://api.leolin.me/settingUserMonster"
        case AddFriend="http://api.leolin.me/addFriend"
        case UpdateLocation="http://api.leolin.me/updateLocation"
        case AnotherUserNearToYou="http://api.leolin.me/anotherUserNearToYou"
        case UserProfile="http://api.leolin.me/userProfile"
        case PracticeWithSomeoneKnow="http://api.leolin.me/practiceWithSomeoneKnow"
        case ArenaGameOver="http://api.leolin.me/arenaGameOver"
        case Arena="http://api.leolin.me/arena"
        case Practice="http://api.leolin.me/practice"
    }
}
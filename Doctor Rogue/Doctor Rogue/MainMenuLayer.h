//
//  MainMenuLayer.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/8/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface MainMenuLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, UITextFieldDelegate>

// returns a CCScene that contains the MainMenuLayer as the only child
+(CCScene *) scene;

@end

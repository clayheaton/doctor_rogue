//
//  MainMenuLayer.h
//  Doctor Rogue
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface MainMenuLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, UITextFieldDelegate>

// returns a CCScene that contains the MainMenuLayer as the only child
+(CCScene *) scene;

@end

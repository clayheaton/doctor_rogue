//
//  MainGameScene.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@class MapLayer;
@class UILayer;
@class GameWorld;

@interface MainGameScene : CCLayer {
    
}

@property (retain, readonly) GameWorld *gameWorld;

+ (CCScene *)scene;
- (MapLayer *)mapLayer;
- (UILayer  *)uiLayer;

@end

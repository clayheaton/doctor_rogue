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
@class HKTMXTiledMap;

@interface MainGameScene : CCLayer {
    
}

@property (retain, readwrite) GameWorld *gameWorld;
@property (assign, readwrite) BOOL       usingUnderlayer;

@property (assign, readwrite) float underlayerDimension;

+ (CCScene *) sceneWithMapTemplate:(NSString *)templateName;
+ (CCScene *) sceneWithRandomizedMap:(HKTMXTiledMap *)map;

- (id) initWithMapTemplate:(NSString *)templateName;
- (id) initWithRandomizedMap:(HKTMXTiledMap *)map;

- (MapLayer *)mapLayer;
- (UILayer  *)uiLayer;

- (void) establishUnderlayer;
- (void) positionUnderlayer:(CGPoint)mapPixelsMove;
@end

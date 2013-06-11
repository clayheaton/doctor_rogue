//
//  LoadingScene.h
//  FieldHospital
//
//  Created by Clay Heaton on 4/26/12.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "HKTMXTiledMap.h"
#import "RandomMapGenerator.h"

@interface LoadingScene : CCScene {
    LoadingTargetScenes targetScene_;
}

@property (retain, readwrite) NSDictionary *infoDict;
@property (retain, readwrite) NSArray      *locationInfo;
@property (assign, readwrite) BOOL         *loadingStarted;
@property (retain, readwrite) CCScene      *mainGameScene;
@property (assign, readwrite) BOOL         *gameSceneLoaded;
@property (assign, readwrite) BOOL         *switchExecuted;

@property (copy, readwrite) NSString       *rmgUpdateLabel;
@property (assign, readwrite) BOOL         *rmgLabelNeedsUpdate;

@property (retain, readwrite) RandomMapGenerator *rmg;

@property (retain, readwrite) CCSprite     *plane;

+(id) sceneWithTargetScene:(LoadingTargetScenes)targetScene;
-(id) initWithTargetScene:(LoadingTargetScenes)targetScene;

@end

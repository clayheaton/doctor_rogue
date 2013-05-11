//
//  MainGameScene.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
// 

#import "MainGameScene.h"
#import "MapLayer.h"
#import "UILayer.h"

@implementation MainGameScene
@synthesize gameWorld = _gameWorld;


static MainGameScene *gameScene;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild: [MainGameScene gameScene]];
	
	// return the scene
	return scene;
}

+ (MainGameScene *)gameScene
{
    if (!gameScene) {
        gameScene = [MainGameScene node];
    }
    return gameScene;
}

- (id)init
{
    self = [super init];

    if (self) {
        NSAssert(gameScene == nil, @"another MainGameScene is already in use!");
        // stuff
        MapLayer *mapLayer = [MapLayer node];
        [self addChild:mapLayer z:1 tag:kTag_MainGameScene_MapLayer];
        
        UILayer *uiLayer   = [UILayer node];
        [self addChild:uiLayer z:2 tag:kTag_MainGameScene_UILayer];
        
    }
    return self;
}

- (MapLayer *)mapLayer
{
    return (MapLayer *)[self getChildByTag:kTag_MainGameScene_MapLayer];
}
- (UILayer  *)uiLayer
{
    return (UILayer  *)[self getChildByTag:kTag_MainGameScene_UILayer];
}

- (void) dealloc
{
    _gameWorld = nil;
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end

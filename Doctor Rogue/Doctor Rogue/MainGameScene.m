//
//  MainGameScene.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
// 

#import "MainGameScene.h"
#import "MapLayer.h"
#import "UILayer.h"
#import "GameWorld.h"

@implementation MainGameScene
@synthesize gameWorld       = _gameWorld;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [MainGameScene node]];
	return scene;
}

- (id)init
{
    self = [super init];

    if (self) {

        _gameWorld     = [GameWorld node];
        
        // TODO: Change this initialization to allow for passing in a specified map
        
        MapLayer *mapLayer = [MapLayer node];
        [self addChild:mapLayer z:1 tag:kTag_MainGameScene_MapLayer];
        
        UILayer *uiLayer   = [UILayer node];
        [self addChild:uiLayer z:2 tag:kTag_MainGameScene_UILayer];
        
    }
    return self;
}

- (void) onExit
{
    [self removeAllChildrenWithCleanup:YES];
    _gameWorld = nil;
    
    [super onExit];
}

- (MapLayer *)mapLayer
{
    return (MapLayer *)[self getChildByTag:kTag_MainGameScene_MapLayer];
}
- (UILayer  *)uiLayer
{
    return (UILayer  *)[self getChildByTag:kTag_MainGameScene_UILayer];
}

/* Not needed with ARC
- (void) dealloc
{
    _gameWorld = nil;
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}
 */

@end

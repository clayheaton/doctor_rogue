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
#import "HKTMXTiledMap.h"

@implementation MainGameScene

+(CCScene *) sceneWithMapTemplate:(NSString *)templateName
{
	CCScene *scene       = [CCScene node];
    MainGameScene   *mgs = [[MainGameScene alloc] initWithMapTemplate:templateName];
    
	[scene addChild: mgs];
	return scene;
}

- (id) initWithMapTemplate:(NSString *)templateName
{
    self = [super init];
    
    if (self) {
        
        _usingUnderlayer = NO;
        
        _gameWorld     = [GameWorld node];
        
        MapLayer *mapLayer = [[MapLayer alloc] initWithMap:[HKTMXTiledMap tiledMapWithTMXFile:templateName] andGameWorld:_gameWorld];
        [self addChild:mapLayer z:1 tag:kTag_MainGameScene_mapLayer];
        
        UILayer *uiLayer   = [UILayer node];
        [self addChild:uiLayer z:2 tag:kTag_MainGameScene_uiLayer];
        
        if ([mapLayer underlayerIsNeeded]) {
            [self establishUnderlayer];
        }
        
    }
    return self;
}

- (id)init
{
    self = [super init];

    if (self) {

        _usingUnderlayer = NO;
        
        _gameWorld     = [GameWorld node];
        
        MapLayer *mapLayer = [[MapLayer alloc] initWithMap:[HKTMXTiledMap tiledMapWithTMXFile:@"test_grasslands.tmx"] andGameWorld:_gameWorld];
        [self addChild:mapLayer z:1 tag:kTag_MainGameScene_mapLayer];
        
        UILayer *uiLayer   = [UILayer node];
        [self addChild:uiLayer z:2 tag:kTag_MainGameScene_uiLayer];
        
        if ([mapLayer underlayerIsNeeded]) {
            [self establishUnderlayer];
        }
        
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
    return (MapLayer *)[self getChildByTag:kTag_MainGameScene_mapLayer];
}
- (UILayer  *)uiLayer
{
    return (UILayer  *)[self getChildByTag:kTag_MainGameScene_uiLayer];
}

# pragma mark Underlayer Methods

// The underlayer shows underneath the map and is visible through cracks in the map.
// Don't want to draw it if we don't have to...

- (void) establishUnderlayer
{
    CCLOG(@"Establishing the underlayer.");
    
    _usingUnderlayer = YES;
    CCLayer *underlayer = [CCLayer node];
    
    _underlayerDimension = 0;
    
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            CCSprite *ul = [CCSprite spriteWithFile:@"underlayer.png"];
            [underlayer addChild:ul];
            ul.anchorPoint = ccp(0,0);
            ul.position = ccp(i * ul.contentSize.width, j * ul.contentSize.height);
            _underlayerDimension += ul.boundingBox.size.width;
            ul.opacity = 160;
        }
    }
    
    [self addChild:underlayer z:-2 tag:kTag_MainGameScene_underlayer];
    
    //TODO: Make this make sense
    underlayer.position = ccp(-[[CCDirector sharedDirector] winSize].width,-[[CCDirector sharedDirector] winSize].height);
    underlayer.visible = YES;
    
    
    CCParticleSystemQuad *chasm_wind = [CCParticleSystemQuad particleWithFile:@"chasm_wind.plist"];
    chasm_wind.position = ccp(-20, [[CCDirector sharedDirector]winSize].height * 0.5);//ccp(underlayer.contentSize.width/2,underlayer.contentSize.height/2);
    chasm_wind.visible = YES;
    [self addChild:chasm_wind z:-1 tag:kTag_MainGameScene_chasmwind];
    
     
     
    
    // Hide the mapLayer for testing
    //[self getChildByTag:kTag_MainGameScene_mapLayer].visible = NO;
    
}

- (void) positionUnderlayer:(CGPoint)mapPixelsMove
{
    if (!_usingUnderlayer) {
        return;
    }
    
    CGPoint underlayerMove = ccpMult(mapPixelsMove, 0.4f);
    underlayerMove = ccpMult(underlayerMove, -1.0f);
    
    // Correct for possible illegal values (seen incoming)
    if (isnan(underlayerMove.x)) {
        underlayerMove.x = 0;
    }
    
    if (isnan(underlayerMove.y)) {
        underlayerMove.y = 0;
    }

    CCLayer *underlayer      = (CCLayer *)[self getChildByTag:kTag_MainGameScene_underlayer];
    CGPoint proposedPosition = ccpAdd(underlayer.position, underlayerMove);
    
    // Make sure that the entire underLayer always covers the screen under the map
    // The dimension calculations here might be incorrect.
    
    float minX = -_underlayerDimension + [[CCDirector sharedDirector] winSize].width;
    float minY = -_underlayerDimension + [[CCDirector sharedDirector] winSize].height;
    
    if (proposedPosition.x > 0) {
        proposedPosition.x = 0;
    } else if (proposedPosition.x < minX) {
        proposedPosition.x = minX;
    }
    
    if (proposedPosition.y > 0) {
        proposedPosition.y = 0;
    } else if (proposedPosition.y < minY) {
        proposedPosition.y = minY;
    }
    
    underlayer.position = proposedPosition;
    
}

@end

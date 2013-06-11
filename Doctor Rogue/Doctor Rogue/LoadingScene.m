//
//  LoadingScene.m
//  FieldHospital
//
//  Created by Clay Heaton on 4/26/12.
//

#import "LoadingScene.h"
#import "MainMenuLayer.h"
#import "MainGameScene.h"
#import "GameState.h"
#import "CCSprite+GLBoxes.h"


@interface LoadingScene (PrivateMethods)
-(void) update:(ccTime)delta;
@end

@implementation LoadingScene

+(id) sceneWithTargetScene:(LoadingTargetScenes)targetScene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
	// This creates an autorelease object of self (the current class: LoadingScene)
	return [[self alloc] initWithTargetScene:targetScene];

}

-(id) initWithTargetScene:(LoadingTargetScenes)targetScene
{
	if ((self = [super init]))
	{
        _loadingStarted = NO;
        _gameSceneLoaded = NO;
        _switchExecuted = NO;
        _rmgUpdateLabel = @"Starting the plane...";
        _rmgLabelNeedsUpdate = NO;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
		targetScene_  = targetScene;
		NSString *title;
        
        if (targetScene == LoadingTargetScene_MainGameScene) {
            _locationInfo = [[GameState gameState] nextMapAndLocation];
            title = [NSString stringWithFormat:@"Flying to %@", [_locationInfo objectAtIndex:0]];
        } else {
            title = @"Loading";
        }
        
        CCLabelTTF *rmgLabel = [CCLabelTTF labelWithString:_rmgUpdateLabel
                                                  fontName:[[UIFont systemFontOfSize:12] familyName]
                                                  fontSize:18];
        
		rmgLabel.position = CGPointMake(size.width / 2, size.height / 3);
		[self addChild:rmgLabel z:1 tag:kTag_LoadingScene_mapUpdate];
        
        NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter addObserverForName:nil
                                  object:nil
                                   queue:nil
                              usingBlock:^(NSNotification* notification){
                                  
                                  if ([[notification name] isEqualToString:NOTIFICATION_MAP_GENERATOR_UPDATE]) {
                                      _rmgUpdateLabel = [[notification userInfo] objectForKey:NOTIFICATION_LOADING_UPDATE];
                                      _rmgLabelNeedsUpdate = YES;
                                      
                                  }
        
                              }];
        
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:title fntFile:@"fedora-titles-35.fnt"];
		label.position = CGPointMake(size.width / 2, size.height / 2);
		[self addChild:label];
		
        // Add the plane for fun
        _plane = [CCSprite spriteWithFile:@"hawker_hart.png"];
        _plane.position = ccp(-1* _plane.boundingBox.size.width, size.height * 0.75);
        _plane.rotation = 90;
        
        [self addChild:_plane z:3 tag:kTag_LoadingScene_plane];
        
        
		// Must wait one frame before loading the target scene!
		// Two reasons: first, it would crash if not. Second, the Loading label wouldn't be displayed.
		[self scheduleUpdate];
	}
	
	return self;
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    [super onExit];
}

- (void) randomize:(HKTMXTiledMap *)map
{
    [_rmg randomize:map];
    
    _gameSceneLoaded = YES;
    
    // Perform the transition on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self transitionToMap:map];
    });
}

- (void) transitionToMap:(HKTMXTiledMap *)map
{
    
    [_rmg setNewTiles];
    _mainGameScene = [MainGameScene sceneWithRandomizedMap:map];
    
    CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1 scene:_mainGameScene withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:transition];
}

- (void) replaceRMGLabel
{
    [self removeChildByTag:kTag_LoadingScene_mapUpdate cleanup:YES];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *rmgLabel = [CCLabelTTF labelWithString:_rmgUpdateLabel
                                              fontName:[[UIFont systemFontOfSize:12] familyName]
                                              fontSize:18];
    rmgLabel.position = CGPointMake(size.width / 2, size.height / 3);
    [self addChild:rmgLabel z:1 tag:kTag_LoadingScene_mapUpdate];
    
    _rmgLabelNeedsUpdate = NO;
}

-(void) update:(ccTime)delta
{
    if (_rmgLabelNeedsUpdate) {
        [self replaceRMGLabel];
    }

    _plane.position = ccpAdd(_plane.position, ccp(2.0f, 0));
    
	// Decide which scene to load based on the TargetScenes enum.
	// You could also use TargetScene to load the same with using a variety of transitions.
    
    if (!_switchExecuted) {
        switch (targetScene_)
        {
            case LoadingTargetScene_MainMenuScene:
            {
                
                // TODO: Remove temporary reset of GameState
                
                // At the moment, this allows reproducability with the same seed because it sets the location number
                // and the map number back to -1 on the GameState. This is acceptable because we do not currently
                // have a way to save the gamestate with regards to map changes, etc.
                
                [[GameState gameState] temporaryReset];
                
                CCScene *mainMenuScene = [MainMenuLayer scene];
                CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1 scene:mainMenuScene withColor:ccBLACK];
                [[CCDirector sharedDirector] replaceScene:transition];
                break;
            }
                
            case LoadingTargetScene_MainGameScene:
            {
                if (!_loadingStarted) {
                    
                    NSString *mapTemplateName = [_locationInfo objectAtIndex:1];
                    unsigned int mapSeed      = [[_locationInfo objectAtIndex:2] unsignedIntValue];
                    
                    HKTMXTiledMap      *map = [HKTMXTiledMap tiledMapWithTMXFile:mapTemplateName];
                    _rmg = [[RandomMapGenerator alloc] initWithRandomSeed:mapSeed];
                    
                    // Randomize the map on another thread
                    // This allows us to animate the loading screen -- currently used to show labels
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                             (unsigned long)NULL), ^(void) {
                        [self randomize:map];
                    });
                    
                    _loadingStarted = YES;
                }
                
                break;
            }
                
            default:
                // Always warn if an unspecified enum value was used. It's a reminder for yourself to update the switch
                // whenever you add more enum values.
                NSAssert2(nil, @"%@: unsupported TargetScene %i", NSStringFromSelector(_cmd), targetScene_);
                break;
        }
        _switchExecuted = YES;
    }
        

}


@end

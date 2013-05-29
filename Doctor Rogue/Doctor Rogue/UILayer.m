//
//  UILayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import "UILayer.h"
#import "Constants.h"
#import "LoadingScene.h"
#import "CCSprite+GLBoxes.h"

@implementation UILayer

- (id)init
{
    self = [super init];
    if (self) {
        self.touchEnabled   = YES;
        _tilePanelIsShowing = NO;
        
        [self setupTempQuitButton];
        [self establishTopInfoBar];
        [self establishTileInfoPanel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showTileInfo:)
                                                     name:NOTIFICATION_DISPLAY_TILE_INFO
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideTileInfo:)
                                                     name:NOTIFICATION_HIDE_TILE_INFO
                                                   object:nil];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
}

- (void)onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark -

- (void) setupTempQuitButton
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    
    // These are placeholders for testing

    CCLabelTTF *quitButtonLabel = [CCLabelTTF labelWithString:@"Quit to Menu"
                                                      fontName:[[UIFont systemFontOfSize:12] familyName]
                                                      fontSize:20];
    
    quitButtonLabel.position = ccp(size.width - 10, 10);
    quitButtonLabel.anchorPoint = ccp(1,0);
    [self addChild:quitButtonLabel z:2 tag:kTag_UILayer_tempQuitButton];
    
    CCLabelTTF *toggleGridLabel  = [CCLabelTTF labelWithString:@"Toggle Grid"
                                                      fontName:[[UIFont systemFontOfSize:12] familyName]
                                                      fontSize:20];
    
    toggleGridLabel.position = ccp(10, 10);
    toggleGridLabel.anchorPoint = ccp(0,0);
    [self addChild:toggleGridLabel z:2 tag:kTag_UILayer_toggleGridButton];

}

- (void) establishTileInfoPanel
{
    CCSprite *tileInfoBar = [CCSprite rectangleOfSize:CGSizeMake([[CCDirector sharedDirector] winSize].width,[[CCDirector sharedDirector] winSize].height * 0.15)
                                              withRed:0
                                                green:0
                                                 blue:0
                                             andAlpha:200];
    
    [self addChild:tileInfoBar z:2 tag:kTag_UILayer_tileInfoBar];
    tileInfoBar.anchorPoint = ccp(0,1);
    tileInfoBar.position = ccp(0,[[CCDirector sharedDirector] winSize].height + [tileInfoBar contentSize].height);
    //ccp(0,[[CCDirector sharedDirector] winSize].height - ([[CCDirector sharedDirector] winSize].height * 0.1));
    tileInfoBar.visible = YES;
}

- (void) establishTopInfoBar
{
    CCSprite *topInfoBar = [CCSprite rectangleOfSize:CGSizeMake([[CCDirector sharedDirector] winSize].width,[[CCDirector sharedDirector] winSize].height * 0.05)
                                              withRed:0
                                                green:0
                                                 blue:0
                                             andAlpha:255];
    
    [self addChild:topInfoBar z:3 tag:kTag_UILayer_topInfoBar];
    topInfoBar.anchorPoint = ccp(0,1);
    topInfoBar.position = ccp(0,[[CCDirector sharedDirector] winSize].height);
    topInfoBar.visible = YES;
    
    
}

#pragma mark Handling touch events

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}


-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self locationFromTouch:touch];

    if (CGRectContainsPoint([self getChildByTag:kTag_UILayer_tempQuitButton].boundingBox, location)) {
        CCLOG(@"UI Layer Quit Button tapped.");
        [TestFlight passCheckpoint:@"Quit back to MainMenu from UILayer"];
        CCScene *mainMenu = [LoadingScene sceneWithTargetScene:LoadingTargetScene_MainMenuScene];
        
        // Pause might allow to fade out music, etc.
        [[CCDirector sharedDirector] performSelector:@selector(replaceScene:)
                                          withObject:mainMenu
                                          afterDelay:1.0f];
        return YES;
    }
    
    if (CGRectContainsPoint([self getChildByTag:kTag_UILayer_toggleGridButton].boundingBox, location)) {
        CCLOG(@"UI Layer Toggle Grid Button tapped.");
        [TestFlight passCheckpoint:@"Toggled Grid on Map via UILayer"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TOGGLE_GRID object:nil];
        return YES;
    }

    
	return NO;
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	//CCLOG(@"UserInterfaceLayer touch ended");
}

#pragma mark -
#pragma mark Notification Handling
- (void)showTileInfo:(NSNotification *)notification
{
    
    CCSprite *infoBar = (CCSprite *)[self getChildByTag:kTag_UILayer_tileInfoBar];
    
    NSString *desc = [[notification userInfo] objectForKey:TILE_DESCRIPTION];
    
    // Remove the description if it is there
    if ([infoBar getChildByTag:kTag_UILayer_tileInfoBarTileDescription]) {
        [infoBar removeChildByTag:kTag_UILayer_tileInfoBarTileDescription cleanup:YES];
    }
    
    CCLabelTTF *tileDesc = [CCLabelTTF labelWithString:desc fontName:[[UIFont systemFontOfSize:12] fontName] fontSize:18.0f];
    tileDesc.anchorPoint = ccp(0,0.5);
    tileDesc.position    = ccp(10,[infoBar contentSize].height * 0.5);
    [infoBar addChild:tileDesc z:3 tag:kTag_UILayer_tileInfoBarTileDescription];
    
    if (!_tilePanelIsShowing) {
        // Panel isn't showing, so show it
        _tilePanelIsShowing = YES;
        
        id uiAction = [CCMoveTo     actionWithDuration:0.25f position:ccp(0,[[CCDirector sharedDirector] winSize].height - ([[CCDirector sharedDirector] winSize].height * 0.05))];
        id uiEase   = [CCEaseSineIn actionWithAction:uiAction];
        
        [infoBar runAction: uiEase];
        
    } else {
        // Panel is showing, change the displayed info
    }
    
}

- (void)hideTileInfo:(NSNotification *)notification
{
    _tilePanelIsShowing = NO;
    
    id uiAction = [CCMoveTo actionWithDuration:0.25f
                                      position:ccp(0,[[CCDirector sharedDirector] winSize].height + [[self getChildByTag:kTag_UILayer_tileInfoBar] contentSize].height)];
    id uiEase = [CCEaseSineOut actionWithAction:uiAction];
    [[self getChildByTag:kTag_UILayer_tileInfoBar] runAction: uiEase];
}

@end

//
//  UILayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import "UILayer.h"
#import "Constants.h"
#import "LoadingScene.h"


@implementation UILayer

- (id)init
{
    self = [super init];
    if (self) {
        self.touchEnabled = YES;
        [self setupTempQuitButton];
    }
    return self;
}

- (void) setupTempQuitButton
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    
    // These are placeholders for testing
    // TODO: Remove placeholders & replace with real UI
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

@end

//
//  UILayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import "UILayer.h"
#import "Constants.h"
#import "LoadingScene.h"


@implementation UILayer

- (id)init
{
    self = [super init];
    if (self) {
        self.touchEnabled = YES; // Disabled for testing map scrolling
        [self setupTempQuitButton];
    }
    return self;
}

- (void) setupTempQuitButton
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF *startButtonLabel = [CCLabelTTF labelWithString:@"Quit to Menu"
                                                      fontName:[[UIFont systemFontOfSize:12] familyName]
                                                      fontSize:20];
    
    startButtonLabel.position = ccp(size.width - 10, 10);
    startButtonLabel.anchorPoint = ccp(1,0);
    [self addChild:startButtonLabel z:2 tag:kTag_UILayer_tempQuitButton];
    
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
        CCScene *mainMenu = [LoadingScene sceneWithTargetScene:LoadingTargetScene_MainMenuScene];
        
        // Pause might allow to fade out music, etc.
        [[CCDirector sharedDirector] performSelector:@selector(replaceScene:)
                                          withObject:mainMenu
                                          afterDelay:1.0f];
        return YES;
    }
    
    if (CGRectContainsPoint([self getChildByTag:kTag_UILayer_toggleGridButton].boundingBox, location)) {
        CCLOG(@"UI Layer Toggle Grid Button tapped.");
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

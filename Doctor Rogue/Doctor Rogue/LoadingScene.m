//
//  LoadingScene.m
//  FieldHospital
//
//  Created by Clay Heaton on 4/26/12.
//  Copyright 2012 The Perihelion Group. All rights reserved.
//

#import "LoadingScene.h"
#import "MainMenuLayer.h"
#import "MainGameScene.h"



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
		targetScene_ = targetScene;
		
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Loading..." fntFile:@"fedora-titles-35.fnt"];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height / 2);
		[self addChild:label];
		
		// Must wait one frame before loading the target scene!
		// Two reasons: first, it would crash if not. Second, the Loading label wouldn't be displayed.
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) update:(ccTime)delta
{
	// It's not strictly necessary, as we're changing the scene anyway. But just to be safe.
	[self unscheduleAllSelectors];
	
	// Decide which scene to load based on the TargetScenes enum.
	// You could also use TargetScene to load the same with using a variety of transitions.
	switch (targetScene_)
	{
		case LoadingTargetScene_MainMenuScene:
        {
            
            CCScene *mainMenuScene = [MainMenuLayer scene];
            CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1 scene:mainMenuScene withColor:ccBLACK];
			[[CCDirector sharedDirector] replaceScene:transition];
            break;
        }

		case LoadingTargetScene_MainGameScene:
		{
            
			CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1 scene:[MainGameScene scene] withColor:ccBLACK];
			[[CCDirector sharedDirector] replaceScene:transition];
			break;
		}
			
		default:
			// Always warn if an unspecified enum value was used. It's a reminder for yourself to update the switch
			// whenever you add more enum values.
			NSAssert2(nil, @"%@: unsupported TargetScene %i", NSStringFromSelector(_cmd), targetScene_);
			break;
	}

}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

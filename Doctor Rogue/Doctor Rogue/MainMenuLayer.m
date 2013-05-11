//
//  MainMenuLayer.m
//  Doctor Rogue
//


#import "MainMenuLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "GameStartGenerator.h"
#import "LoadingScene.h"

#pragma mark - MainMenuLayer

// MainMenuLayer implementation
@implementation MainMenuLayer

// Helper class method that creates a Scene with the MainMenuLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        [self setTouchEnabled:YES];
        
        [self addMainTitleLeadIn];
        [self addMainTitle];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *refreshLabel = [CCLabelTTF labelWithString:@"Try a Random Adventure"
                                                      fontName:[[UIFont systemFontOfSize:12] familyName]
                                                      fontSize:18];
        
        refreshLabel.position = ccp(size.width * 0.5, size.height * 0.25);
        [self addChild:refreshLabel z:1 tag:11];
        
        CCLabelTTF *seedButtonLabel = [CCLabelTTF labelWithString:@"Set Specific Adventure Number"
                                                         fontName:[[UIFont systemFontOfSize:12] familyName]
                                                         fontSize:18];
        
        seedButtonLabel.position = ccp(size.width * 0.5, size.height * 0.25 - (refreshLabel.boundingBox.size.height * 2));
        [self addChild:seedButtonLabel z:1 tag:15];
        
        CCLabelTTF *startButtonLabel = [CCLabelTTF labelWithString:@"Start"
                                                         fontName:[[UIFont systemFontOfSize:12] familyName]
                                                         fontSize:36];
        
        startButtonLabel.position = ccp(size.width - 10, 10);
        startButtonLabel.anchorPoint = ccp(1,0);
        [self addChild:startButtonLabel z:1 tag:17];
		
		
		/*
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// to avoid a retain-cycle with the menuitem and blocks
		__block id copy_self = self;
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			
			
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = copy_self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
			[achivementViewController release];
		}];
		
		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = copy_self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
			[leaderboardViewController release];
		}];
        
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
         */
        
        
        
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark Title Creation
- (void) addMainTitleLeadIn
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSString *drString      = @"Doctor Chick";
    CCLabelBMFont *drTitle  = [CCLabelBMFont labelWithString:drString fntFile:@"fedora-color-100.fnt"];
    drTitle.position        = ccp( size.width * 0.4 , size.height * 0.80 );
    drTitle.rotation        = -15.0f;
    drTitle.alignment       = kCCTextAlignmentCenter;
    [self addChild:drTitle z:1 tag:9];
    
    CCLabelBMFont *andThe   = [CCLabelBMFont labelWithString:@"and the" fntFile:@"fedora-titles-35.fnt"];
    andThe.position         = ccp( size.width * 0.5 , size.height * 0.67 );
    andThe.alignment        = kCCTextAlignmentCenter;
    [self addChild:andThe z:1 tag:8];
    
}
- (void) addMainTitle
{
    // Remove the old title if there is one
    if ([self getChildByTag:10]) {
        [self removeChildByTag:10 cleanup:YES];
    }
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:[[GameStartGenerator generator] gameTitle] fntFile:@"fedora-titles-50.fnt"];
    label.alignment      = kCCTextAlignmentRight;
    label.position       =  ccp( size.width * 0.5 , size.height * 0.55f );
    
    [self addChild: label z:1 tag:10];
}

# pragma mark Adventure Generation
- (void) getNewAdventure
{
    // CCLOG(@"Tapped New Adventure");
    [[GameStartGenerator generator] makeNewAdventure];
    [self addMainTitle];
}

#pragma mark Changing Seed
- (void)editSeedWithSeed:(uint)oldSeed
{
    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"What adventure number would you like to play?"
                                                     message:@"Numbers only"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Pull the file!", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].delegate = self;
    [alert show];
    alert.tag = 1;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    // Only do something if the OK button was tapped
    if (buttonIndex == 1) {
        NSString *value = [[alertView textFieldAtIndex:0] text];
        if ([value isEqualToString:@""]) {
            return;
        }
        [[GameStartGenerator generator] makeNewAdventureWithSeed:[value intValue]];
        [self addMainTitle];
    }
}


#pragma mark Touch events
-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocGL = [self locationFromTouch:[touches anyObject]];
    
    // Random adventure
    if (CGRectContainsPoint([self getChildByTag:11].boundingBox, touchLocGL)) {
        
        [self getNewAdventure];
        return;
    }
    
    // Set seed
    if (CGRectContainsPoint([self getChildByTag:15].boundingBox, touchLocGL)) {
        
        [self editSeedWithSeed:[[GameStartGenerator generator] seed]];
        return;
    }

    // Test Start
    if (CGRectContainsPoint([self getChildByTag:17].boundingBox, touchLocGL)) {
        CCScene *gameScene = [LoadingScene sceneWithTargetScene:LoadingTargetScene_MainGameScene];
        
        // Pause might allow to fade out music, etc.
        [[CCDirector sharedDirector] performSelector:@selector(replaceScene:)
                                          withObject:gameScene
                                          afterDelay:1.0f];
        
        [self getChildByTag:17].visible = NO;
        return;
    }

}












#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end


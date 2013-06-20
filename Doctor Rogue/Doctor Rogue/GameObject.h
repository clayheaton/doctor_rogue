//
//  GameObject.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

// All things that appear in the game world, living or dead, fixed or movable, controllable or otherwise are GameObjects

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameObject : CCNode {
    
}

@property (copy, readwrite)   NSString *name;
@property (retain, readwrite) CCSprite *primarySprite;

@property (assign, readwrite) BOOL selectable;

@property (assign, readwrite) BOOL blocksLineOfSight;
@property (assign, readwrite) BOOL revealsMapThroughFog;


@end

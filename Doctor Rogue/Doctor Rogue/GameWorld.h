//
//  GameWorld.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;

@interface GameWorld : CCNode {
    
}

- (void) parseMap:(HKTMXTiledMap *)map;


@end

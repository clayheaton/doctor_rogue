//
//  GameWorld.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import "GameWorld.h"
#import "HKTMXTiledMap.h"
#import "MapTile.h"

@implementation GameWorld

- (id) init
{
    self = [super init];
    if (self) {
        CCLOG(@"Init in GameWorld");
    }
    return self;
}

- (void) parseMap:(HKTMXTiledMap *)map
{
    CCLOG(@"GameWorld is parsing the map");
    
    
    
}

@end

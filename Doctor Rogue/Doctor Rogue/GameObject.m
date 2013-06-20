//
//  GameObject.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import "GameObject.h"


@implementation GameObject

- (id) init
{
    self = [super init];
    if (self) {
        
        // Game Objects with this set to YES will reveal the map through the fog of war.
        _revealsMapThroughFog = NO;
        
        _blocksLineOfSight = NO;
        
        // This means that we will get info about it if the player double-taps on the tile where it is
        _selectable = YES;
        
        
        _name = @"name not assigned";
    }
    return self;
}

@end

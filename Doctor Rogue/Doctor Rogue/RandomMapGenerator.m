//
//  RandomMapGenerator.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import "RandomMapGenerator.h"
#import "HKTMXTiledMap.h"

@implementation RandomMapGenerator


- (id) init
{
    self = [super init];
    if (self) {
        // Set up whatever parameters...
    }
    return self;
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onExit
{
    [super onExit];
}

// This is the entry point for map randomization

- (HKTMXTiledMap *)randomize:(HKTMXTiledMap *)map
{
    // Check for map property test_map with a value of YES
    
    BOOL isTest = [[map propertyNamed:@"test_map"] boolValue];
    
    if (isTest) {
        CCLOG(@"RandomMapGenerator detects a test map: skipping randomizer.");
    }
    
    CCLOG(@"RandomMapGenerator is generating the map.");
    return map;
}

@end

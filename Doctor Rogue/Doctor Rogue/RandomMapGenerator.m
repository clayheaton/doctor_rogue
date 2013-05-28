//
//  RandomMapGenerator.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import "RandomMapGenerator.h"
#import "HKTMXTiledMap.h"
#import "Constants.h"

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


// Each incoming map template will have a single tile at location (0,0) in each layer. Those tiles have to be cleared.
// You cannot load a .tmx file if each layer does not have a tile on it.

// Process, for now:
// 1. Clear the aforementioned tiles from each layer
// 2. Make everything grass as a default base


// This is the entry point for map randomization

- (HKTMXTiledMap *)randomize:(HKTMXTiledMap *)map
{
    // Check for map property test_map with a value of YES
    
    BOOL isTest = [[map propertyNamed:@"test_map"] boolValue];
    
    if (isTest) {
        CCLOG(@"RandomMapGenerator detects a test map: skipping randomizer.");
    }
    
    CCLOG(@"RandomMapGenerator is generating the map.");
    
    [self cleanTempTilesFrom:map];
    [self setDefaultTerrainFor:map];
    
    return map;
}

#pragma mark -
#pragma mark Cleaning templates

- (void) cleanTempTilesFrom:(HKTMXTiledMap *)map
{
    HKTMXLayer *terrainLayer    = [map layerNamed:MAP_LAYER_TERRAIN];
    HKTMXLayer *collisionsLayer = [map layerNamed:MAP_LAYER_COLLISIONS];
    HKTMXLayer *objectsLayer    = [map layerNamed:MAP_LAYER_OBJECTS];
    HKTMXLayer *fogLayer        = [map layerNamed:MAP_LAYER_FOG];
    
    [terrainLayer    setTileGID:0 at:ccp(0,0)];
    [collisionsLayer setTileGID:0 at:ccp(0,0)];
    [objectsLayer    setTileGID:0 at:ccp(0,0)];
    [fogLayer        setTileGID:0 at:ccp(0,0)];
}

- (void) setDefaultTerrainFor:(HKTMXTiledMap *)map
{
    BOOL defaultLocated = NO;
    
    unsigned short mw = map.mapSize.width;
    unsigned short mh = map.mapSize.height;
    
    // Iterate through the map layers and set MapTile info based on properties
    HKTMXLayer *terrainLayer = [map layerNamed:MAP_LAYER_TERRAIN];
    
    unsigned int defaultTileID = 0;
    
    unsigned int counter = 0;
    
    // Figure out what the default tile is
    while (!defaultLocated) {
        counter += 1;
        
        NSString *default_tile = [[map propertiesForGID:counter] objectForKey:@"default_tile"];
        
        if ([default_tile isEqualToString:@"YES"]) {
            // Found the default
            defaultTileID  = counter;
            defaultLocated = YES;
        }
    }
    
    // Fill the terrain layer with the default tile
    for (int i = 0; i < mw; i++) {
        for (int j=0; j < mh; j++) {
            [terrainLayer setTileGID:defaultTileID at:ccp(i,j)];
        }
    }
    
}

@end

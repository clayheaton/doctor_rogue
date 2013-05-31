//
//  RandomMapGenerator.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import "RandomMapGenerator.h"
#import "HKTMXTiledMap.h"
#import "Constants.h"
#import "GameState.h"
#import "TSXTerrainSetParser.h"
#import "TerrainTile.h"
#import "TerrainTilePositioned.h"
#import "TerrainType.h"

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
    // TODO: Reseed with srand() using the value in the AdventureLocation
    // this will create a consistent randomization experience, me thinks,
    // meaning that the same map will randomize the same way for the same seed each time
    
    // Check for map property test_map with a value of YES
    
    BOOL isTest = [[map propertyNamed:@"test_map"] boolValue];
    
    if (isTest) {
        CCLOG(@"RandomMapGenerator detects a test map: skipping randomizer.");
    }
    
    CCLOG(@"RandomMapGenerator is generating the map.");
    
    // Create layer references
    _terrainLayer       = [map layerNamed:MAP_LAYER_TERRAIN];
    _collisionsLayer    = [map layerNamed:MAP_LAYER_COLLISIONS];
    _objectsLayer       = [map layerNamed:MAP_LAYER_OBJECTS];
    _fogLayer           = [map layerNamed:MAP_LAYER_FOG];
    
    // DO NOT REMOVE THIS
    [self cleanTempTilesFrom:map];
    
    // TODO: Remove or refactor this.
    // The default implementation is poor because it doesn't add anything
    // to the _workingMap. It's just for show to fill gaps (which shouldn't be needed).
    [self setDefaultTerrainFor:map];
    
    [self parseTerrainTileset:map];
    
    NSAssert(_tileDict != nil, @"The tileDict is nil so the map cannot be randomized.");
    
    // Create a 2D array in memory to represent the map. We'll randomize and check this, and then
    // use the final result of it to set the actual map tiles.
    _mapSize = [map mapSize];
    
    _workingMap = [[NSMutableArray alloc] initWithCapacity:_mapSize.width];
    
    for (int i = 0; i < _mapSize.width; i++) {
        NSMutableArray *nested = [[NSMutableArray alloc] initWithCapacity:_mapSize.height];

        for (int i = 0; i < _mapSize.height; i++) {
            [nested addObject:[NSNull null]];
        }
        
        [_workingMap addObject:nested];
    }
    
    [self testRandomizeOutdoorMap:map];
    
    return map;
}

#pragma mark -
#pragma mark Building the Allowed Neighbors Map

/*  The _tileDict is an NSDictionary that contains a key for every tileGID that is part of the marked terrain
    in the tileset for the indicated layer. Here, you'll see it's the @"terrain" layer, though we may want to
    use this approach in the fog of war manager, too. The structure is built to support tiles that can rotate,
    but the ones in this tile set currently cannot rotate, so the additional rotations are disabled, leaving
    only the TerrainTileRotation_0.
 
    Let's say that you're interested in the tile with gID == 1. You would call the following to get the array
    of TerrainTilePositioned objects (again, only one at this time):
 
    NSArray *allTilesWithGID1 = [_tileDict objectforKey:@"1"];
    
    Then, to get the tile:
 
    TerrainTilePositioned *theTile = [allTilesWithGID1 objectAtIndex:TerrainTileRotation_0]; //equivalent to index of 0
    
    The TerrainTilePositioned class is a container class for the TerrainTile class, meant to represent it in different rotations.
 
    The _tileDict also stores information about the terrain types. To get the TerrainType objects, call:
 
    NSArray *terrainTypes = [_tileDict objectForKey:TERRAIN_DICT_TERRAINS];
 
    terrainTypes will then contain an ordered list of the TerrainType objects in the tile set, as defined in the .tsx file. The index
    number of the TerrainType corresponds to the number that the TerrainTiles and TerrainTilePositioned objects use to refer
    to the type of terrain that is in each corner. For example, if you called:
 
    unsigned int terType = [theTile cornerNWTarget];
 
    you then could use terType to retrieve the TerrainType from the _tileDict, like this:
 
    TerrainType *myTerrain = [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS] objectAtIndex:terType];
 
    When parsing the tiles, they are added to special "brush" arrays in the TerrainType objects. If you
    are looking for a TerrainTilePositioned object that has all 4 corners of one type of terrain, then you could just call:
 
    TerrainTilePositioned *mySolidTile = [[myTerrain wholeBrushes] objectAtIndex:0];
 
    TerrainType objects also have halfBrushes and quarterBrushes arrays from which you can draw tiles.
 
    Finally, the TerrainTilePositioned objects have a series of pass-through (to the TerrainTile) methods that
    provide more detail about whether they contain a certain type of terrain. See the header file for more info.
 
 */

- (void) parseTerrainTileset:(HKTMXTiledMap *)map
{
    NSString *tilesetName = [[map layerNamed:@"terrain"]tileset].name; // Make this so that we can pass in other layer names
    _tileDict             = [TSXTerrainSetParser parseTileset:tilesetName];
    _tileDictKeyArray     = [[NSMutableArray alloc] init]; // Not used at the moment.
    
    for (NSString *key in _tileDict) {
        if ([key isEqualToString:TERRAIN_DICT_TERRAINS]) {
            continue;
        }
        [_tileDictKeyArray addObject:key];
    }
    
    // Testing Output
    /*
    NSArray *tiles = [_tileDict objectForKey:@"1"];
    
    TerrainTilePositioned *t = [tiles objectAtIndex:TerrainTileRotation_0]; // Currently, the only object in the array
    NSArray *t_northNeighbors = [t neighborsNorth];

     */
    
    CCLOG(@"Tileset parsed");
}

# pragma mark -
# pragma mark Testing randomization

- (void) testRandomizeOutdoorMap:(HKTMXTiledMap *)map
{
    // Randomize here, into _workingMap
    
  
    
    
    
    // Finished setting up the Working map -- now use it to set tiles
    for (int i = 0; i < _mapSize.width; i++) {
        for (int j = 0; j < _mapSize.height; j++) {
            if ([[_workingMap objectAtIndex:i] objectAtIndex:j] != [NSNull null]) {
                TerrainTilePositioned * tile = [[_workingMap objectAtIndex:i] objectAtIndex:j];
                [_terrainLayer setTileGID:[tile tileGID] at:ccp(i,j)];
            }
        }
    }
     
    CCLOG(@"Map randomization complete");
}

- (void) putNeighborsOf:(CGPoint)coord intoQueue:(NSMutableArray *)queue
{
    CGPoint n = [self nextPointInDirection:North from:coord];
    CGPoint e = [self nextPointInDirection:East from:coord];
    CGPoint s = [self nextPointInDirection:South from:coord];
    CGPoint w = [self nextPointInDirection:West from:coord];
    CGPoint ne = [self nextPointInDirection:Northeast from:coord];
    CGPoint nw = [self nextPointInDirection:Northwest from:coord];
    CGPoint se = [self nextPointInDirection:Southeast from:coord];
    CGPoint sw = [self nextPointInDirection:Southwest from:coord];
    
    if ([self isValid:n]) {
        [queue addObject:[NSValue valueWithCGPoint:n]];
    }
    
    if ([self isValid:e]) {
        [queue addObject:[NSValue valueWithCGPoint:e]];
    }
    
    if ([self isValid:s]) {
        [queue addObject:[NSValue valueWithCGPoint:s]];
    }
    
    if ([self isValid:w]) {
        [queue addObject:[NSValue valueWithCGPoint:w]];
    }
    
    if ([self isValid:ne]) {
        [queue addObject:[NSValue valueWithCGPoint:ne]];
    }
    
    if ([self isValid:nw]) {
        [queue addObject:[NSValue valueWithCGPoint:nw]];
    }
    
    if ([self isValid:se]) {
        [queue addObject:[NSValue valueWithCGPoint:se]];
    }
    
    if ([self isValid:sw]) {
        [queue addObject:[NSValue valueWithCGPoint:n]];
    }
}

- (TerrainTilePositioned *)tileTo:(CardinalDirections)direction ofTileAt:(CGPoint)coord
{
    TerrainTilePositioned *t = nil;
    
    switch (direction) {
        case North:
        {
            CGPoint n = ccpSub(coord, ccp(0,1));
            if ([self isValid:n]) {
                if ([[_workingMap objectAtIndex:n.x] objectAtIndex:n.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:n.x] objectAtIndex:n.y];
                }
            }
            break;
        }
        case East:
        {
            CGPoint e = ccpAdd(coord, ccp(1,0));
            if ([self isValid:e]) {
                if ([[_workingMap objectAtIndex:e.x] objectAtIndex:e.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:e.x] objectAtIndex:e.y];
                }
            }
            break;
        }
        case South:
        {
            CGPoint s = ccpAdd(coord, ccp(0,1));
            if ([self isValid:s]) {
                if ([[_workingMap objectAtIndex:s.x] objectAtIndex:s.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:s.x] objectAtIndex:s.y];
                }
            }
            break;
        }
        case West:
        {
            CGPoint w = ccpSub(coord, ccp(1,0));
            if ([self isValid:w]) {
                if ([[_workingMap objectAtIndex:w.x] objectAtIndex:w.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:w.x] objectAtIndex:w.y];
                }
            }
            break;
        }
        case Northeast:
        {
            CGPoint ne = ccpAdd(coord, ccp(1,-1));
            if ([self isValid:ne]) {
                if ([[_workingMap objectAtIndex:ne.x] objectAtIndex:ne.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:ne.x] objectAtIndex:ne.y];
                }
            }
            break;
        }
        case Northwest:
        {
            CGPoint nw = ccpSub(coord, ccp(1,1));
            if ([self isValid:nw]) {
                if ([[_workingMap objectAtIndex:nw.x] objectAtIndex:nw.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:nw.x] objectAtIndex:nw.y];
                }
            }
            break;
        }
        case Southeast:
        {
            CGPoint se = ccpAdd(coord, ccp(1,1));
            if ([self isValid:se]) {
                if ([[_workingMap objectAtIndex:se.x] objectAtIndex:se.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:se.x] objectAtIndex:se.y];
                }
            }
            break;
        }
        case Southwest:
        {
            CGPoint sw = ccpAdd(coord, ccp(-1,1));
            if ([self isValid:sw]) {
                if ([[_workingMap objectAtIndex:sw.x] objectAtIndex:sw.y] == [NSNull null]) {
                    t = nil;
                } else {
                    t = [[_workingMap objectAtIndex:sw.x] objectAtIndex:sw.y];
                }
            }
            break;
        }
    }
    
    return t;
}

- (CGPoint) nextPointInDirection:(CardinalDirections)direction from:(CGPoint)pt
{
    switch (direction) {
        case North:
        {
            return ccpSub(pt, ccp(0,1));
        }
        case East:
        {
            return ccpAdd(pt, ccp(1,0));
        }
        case South:
        {
            return ccpAdd(pt, ccp(0,1));
        }
        case West:
        {
            return ccpSub(pt, ccp(1,0));
        }
        case Northwest:
        {
            return ccpSub(pt, ccp(1,1));
        }
        case Northeast:
        {
            return ccpAdd(pt, ccp(1,-1));
        }
        case Southwest:
        {
            return ccpAdd(pt, ccp(-1,1));
        }
        case Southeast:
        {
            return ccpAdd(pt, ccp(1,1));
        }
    }
}

- (BOOL) isValid:(CGPoint)coord
{
    // Invalid coordinate
    if (coord.x > _mapSize.width - 1
        || coord.x < 0
        || coord.y > _mapSize.height - 1
        || coord.y < 0)
    {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Cleaning templates

- (void) cleanTempTilesFrom:(HKTMXTiledMap *)map
{
    
    [_terrainLayer    setTileGID:0 at:ccp(0,0)];
    [_collisionsLayer setTileGID:0 at:ccp(0,0)];
    [_objectsLayer    setTileGID:0 at:ccp(0,0)];
    [_fogLayer        setTileGID:0 at:ccp(0,0)];
}

- (void) setDefaultTerrainFor:(HKTMXTiledMap *)map
{
    BOOL defaultLocated = NO;
    
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
    [self fillLayer:_terrainLayer onMap:map withTileID:defaultTileID];
}


#pragma mark -
#pragma mark Utility Methods

- (void) fillLayer:(HKTMXLayer *)layer onMap:(HKTMXTiledMap *)map withTileID:(unsigned short)tileID
{
    unsigned short mw = map.mapSize.width;
    unsigned short mh = map.mapSize.height;
    
    for (int i = 0; i < mw; i++) {
        for (int j=0; j < mh; j++) {
            [layer setTileGID:tileID at:ccp(i,j)];
        }
    }
}

@end

/* Old and broken-ish testing method

- (void) testRandomizeOutdoorMap:(HKTMXTiledMap *)map
{
    
    // Start at (0,0) and walk the map
    
    // Queue up the coordinates
    NSMutableArray *queueToProcess = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _mapSize.height; i++) {
        for (int j = 0; j < _mapSize.width; j++) {
            if (i == 0 && j == 0) {
                continue;
            }
            [queueToProcess addObject:[NSValue valueWithCGPoint:ccp(j,i)]];
        }
    }
    
    // Place the (0,0) tile
    TerrainTilePositioned *seedTile = [[_tileDict objectForKey:@"1"] objectAtIndex:0];
    [seedTile setLockedOnMap:YES];
    
    // Place the seed tile on the working map
    [[_workingMap objectAtIndex:0] setObject:seedTile atIndex:0];
    
    while ([queueToProcess count] > 0) {
        
        CGPoint thisCoord = [[queueToProcess objectAtIndex:0] CGPointValue];
        [queueToProcess removeObjectAtIndex:0];
        
        NSMutableSet *possibleTilesForCoord = [[NSMutableSet alloc] init];
        NSSet *tilesNorth = nil;
        NSSet *tilesEast  = nil;
        NSSet *tilesSouth = nil;
        NSSet *tilesWest  = nil;
        
        TerrainTilePositioned *t;
        
        t = [self tileTo:South ofTileAt:thisCoord];
        
        if (t) {
            NSArray *neighbors = [t neighborsNorth];
            tilesNorth = [NSSet setWithArray:neighbors];
        }
        
        t = [self tileTo:North ofTileAt:thisCoord];
        
        if (t) {
            NSArray *neighbors = [t neighborsSouth];
            tilesSouth = [NSSet setWithArray:neighbors];
        }
        
        t = [self tileTo:East ofTileAt:thisCoord];
        
        if (t) {
            NSArray *neighbors = [t neighborsWest];
            tilesWest = [NSSet setWithArray:neighbors];
        }
        
        t = [self tileTo:West ofTileAt:thisCoord];
        
        if (t) {
            NSArray *neighbors = [t neighborsEast];
            tilesEast = [NSSet setWithArray:neighbors];
        }
        
        // Initialize the mutable set that we will interset the other sets with
        if (tilesNorth && tilesNorth.count > 0) {
            [possibleTilesForCoord unionSet:tilesNorth];
        } else if (tilesEast && tilesEast.count > 0) {
            [possibleTilesForCoord unionSet:tilesEast];
        } else if (tilesSouth && tilesSouth.count > 0){
            [possibleTilesForCoord unionSet:tilesSouth];
        } else if (tilesWest && tilesWest.count > 0) {
            [possibleTilesForCoord unionSet:tilesWest];
        } else {
            // NSAssert([possibleTilesForCoord count] != 0, @"Unable to initialize possible tiles set");
        }
        
        // Intersect the sets
        if (tilesNorth.count > 0) {
            [possibleTilesForCoord intersectSet:tilesNorth];
        }
        
        if (tilesEast.count > 0) {
            [possibleTilesForCoord intersectSet:tilesEast];
        }
        
        if (tilesSouth.count > 0) {
            [possibleTilesForCoord intersectSet:tilesSouth];
        }
        
        if (tilesWest.count > 0) {
            [possibleTilesForCoord intersectSet:tilesWest];
        }
        
        // At this point, our set includes possible tiles. Add one to the working map
        // NSAssert([possibleTilesForCoord count] != 0, @"There are no possible tiles for this coordinate");
        
        if ([possibleTilesForCoord count] > 0) {
            NSArray *arrayOfPossibleTiles = [possibleTilesForCoord allObjects];
            
            TerrainTilePositioned *chosenTile = [arrayOfPossibleTiles objectAtIndex:rand() % arrayOfPossibleTiles.count];
            [chosenTile setLockedOnMap:YES];
            
            [[_workingMap objectAtIndex:thisCoord.x] setObject:chosenTile atIndex:thisCoord.y];
        } else {
            [_terrainLayer setTileGID:0 at:thisCoord];
        }
        
    }
    
    CCLOG(@"Map randomization complete");
    // CCLOG(@"_workingMap: %@", _workingMap);
    
    for (int i = 0; i < _mapSize.width; i++) {
        for (int j = 0; j < _mapSize.height; j++) {
            if ([[_workingMap objectAtIndex:i] objectAtIndex:j] != [NSNull null]) {
                TerrainTilePositioned * tile = [[_workingMap objectAtIndex:i] objectAtIndex:j];
                [_terrainLayer setTileGID:[tile tileGID] at:ccp(i,j)];
            }
        }
    }
    
}
*/

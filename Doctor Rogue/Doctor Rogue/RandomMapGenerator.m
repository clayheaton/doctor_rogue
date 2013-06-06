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
#import "Tile.h"
#import "TerrainType.h"

const CGPoint CGPointNull = {(CGFloat)NAN, (CGFloat)NAN};

@implementation RandomMapGenerator


- (id) init
{
    self = [super init];
    if (self) {
        _edges          = [[NSMutableArray alloc] init];
        _protectedTiles = [[NSMutableSet alloc] init];
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
    
    // TODO: Read this from a tile property instead of assigning it here.
    _landingStripTerrain = 0;
    
    [self createLayerReferencesFrom:map];
    
    // This removes the placeholder tiles on each layer in the .tmx file.
    // Map randomization will not work properly if you remove this line.
    [self cleanTempTilesFrom:map];
    
    [self parseTileset:map];
    
    [self establishWorkingMapFrom:map];
    
    // Just for testing purposes
    [self clayTestRandomizeOutdoorMap:map];
    
    [self convertWorkingMapToRealMap];
    
    CCLOG(@"Map randomization complete");

    return map;
}

#pragma mark -
#pragma mark Building the Allowed Neighbors Map

/*  The _tileDict is an NSDictionary that contains a key for every tileGID that is part of the marked terrain
    in the tileset for the indicated layer. Here, you'll see it's the @"terrain" layer, though we may want to
    use this approach in the fog of war manager, too. The structure is built to support tiles that can rotate,
    but the ones in this tile set currently cannot rotate, so the additional rotations are disabled, leaving
    only the TileRotation_0.
 
    Let's say that you're interested in the tile with gID == 1. You would call the following to get the array
    of Tile objects (again, only one at this time):
 
    NSArray *allTilesWithGID1 = [_tileDict objectforKey:@"1"];
    
    Then, to get the tile:
 
    Tile *theTile = [allTilesWithGID1 objectAtIndex:TileRotation_0]; //equivalent to index of 0
    
    The Tile class is a container class for the Tile class, meant to represent it in different rotations.
 
    The _tileDict also stores information about the terrain types. To get the TerrainType objects, call:
 
    NSArray *terrainTypes = [_tileDict objectForKey:TERRAIN_DICT_TERRAINS];
 
    terrainTypes will then contain an ordered list of the TerrainType objects in the tile set, as defined in the .tsx file. The index
    number of the TerrainType corresponds to the number that the Tiles and Tile objects use to refer
    to the type of terrain that is in each corner. For example, if you called:
 
    unsigned int terType = [theTile cornerNWTarget];
 
    you then could use terType to retrieve the TerrainType from the _tileDict, like this:
 
    TerrainType *myTerrain = [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS] objectAtIndex:terType];
 
    When parsing the tiles, they are added to special "brush" arrays in the TerrainType objects. If you
    are looking for a Tile object that has all 4 corners of one type of terrain, then you could just call:
 
    Tile *mySolidTile = [[myTerrain wholeBrushes] objectAtIndex:0];
 
    TerrainType objects also have halfBrushes and quarterBrushes arrays from which you can draw tiles. The purpose of brushes
    is not to simply be tiles in an array. Eventually, there should be a TerrainBrush class that paints terrain in a manner
    similar to how it is done in Tiled. Take a look here, around line 260, to see how it is implemented in Tiled:
    https://github.com/bjorn/tiled/blob/master/src/tiled/terrainbrush.cpp
 
    What we probably need to do is to simply place down the whole tile for the desired brush, and then perform a tree search,
    maybe a breadth-first search, to look for tiles that will match as closely as possible with the surrounding terrain.
 
    Finally, the Tile objects have a series of pass-through (to the Tile) methods that
    provide more detail about whether they contain a certain type of terrain. See the header file for more info.
 
 */

- (void) parseTileset:(HKTMXTiledMap *)map
{
    NSString *tilesetName = [[map layerNamed:@"terrain"]tileset].name; // Make this so that we can pass in other layer names
    _tileDict             = [TSXTerrainSetParser parseTileset:tilesetName];
    
    NSAssert(_tileDict != nil, @"The tileDict is nil so the map cannot be randomized.");
    
    CCLOG(@"Tileset parsed");
}

# pragma mark -
# pragma mark Clay's Randomization Testing

- (void) clayTestRandomizeOutdoorMap:(HKTMXTiledMap *)map
{
    // Randomize here, into _workingMap
    
    NSMutableSet *lockedCoordinates = [[NSMutableSet alloc] init];
    
    [self clayTestCreateOutdoorEntryPoint:lockedCoordinates];
    
    // Test by making a river from left to right and filling in the neighboring tiles
    
    /*
    Tile *t = [self tileWithID:23];
    [self placeTile:t atCoord:ccp(1,1)];
    */
    
    
    
    

}

- (void)clayTestCreateOutdoorEntryPoint:(NSMutableSet *)lockedCoordinates
{
    // Pick a 3x3 starting area and lock it.
    int startX = (rand() % (int)(_mapSize.width  - 12)) + 6;
    int startY = (rand() % (int)(_mapSize.height - 12)) + 6;
    
    CGPoint start  = ccp(4, 4);
    
    // Use this to determine the landing pad orientation
    int direction = 0; //rand() % 4;
    
    NSSet *coordsToIgnore = nil;
    CGPoint extraTile;
    
    switch (direction) {
        case 0:
        {
            extraTile      = ccpAdd(start, ccp(2,1));
            coordsToIgnore = [NSSet setWithObjects:
                              [NSValue valueWithCGPoint:ccpAdd(start, ccp(2,0))],
                              [NSValue valueWithCGPoint:ccpAdd(start, ccp(2,2))]
                              , nil];
           break; 
        }
            
        case 1:
        {
            extraTile      = ccpAdd(start, ccp(1,2));
            coordsToIgnore = [NSSet setWithObjects:
                              [NSValue valueWithCGPoint:ccpAdd(start, ccp(2,2))],
                              [NSValue valueWithCGPoint:ccpAdd(start, ccp(0,2))]
                              , nil];
            break;
        }
            
        case 2:
        {
            extraTile      = ccpAdd(start, ccp(0,1));
            coordsToIgnore = [NSSet setWithObjects:
                              [NSValue valueWithCGPoint:ccpAdd(start, ccp(0,2))],
                              [NSValue valueWithCGPoint:ccpAdd(start, ccp(0,0))]
                              , nil];
            break;
        }
        case 3:
        {
            extraTile      = ccpAdd(start, ccp(1,0));
            coordsToIgnore = [NSSet setWithObjects:
                           [NSValue valueWithCGPoint:ccpAdd(start, ccp(0,0))],
                           [NSValue valueWithCGPoint:ccpAdd(start, ccp(2,0))]
                           , nil];
            break;
        }
    }
    
    // Need a way to figure out the 'landing strip' terrain for each tileset -- maybe it should be flagged in the .tsx file as a property
    Tile *water  = [self tileForTerrainType:@"water_shallow"]; //_landingStripTerrain
    Tile *grass  = [_tileDict objectForKey:TERRAIN_DICT_DEFAULT];
    
    
    for (int i = 4; i < 9; i++) {
        for (int j = 4; j < 9; j++) {
            [self paintTile:water atPoint:ccp(j, i)];
            [_protectedTiles addObject:[NSValue valueWithCGPoint:ccp(j,i)]];
        }
    }
    
    [_protectedTiles removeAllObjects];
    
    
    [self paintTile:grass atPoint:ccp(6,6)];
    [_protectedTiles addObject:[NSValue valueWithCGPoint:ccp(4,4)]];
    
    
    /*
    [self paintTile:water atPoint:ccp(4,5)];
    [_protectedTiles addObject:[NSValue valueWithCGPoint:ccp(5,5)]];

    
    [self paintTile:water atPoint:ccp(5,5)];
    [_protectedTiles addObject:[NSValue valueWithCGPoint:ccp(5,5)]];
    
    [self paintTile:water atPoint:ccp(5,5)];
    [_protectedTiles addObject:[NSValue valueWithCGPoint:ccp(5,5)]];
    */
     
    // Only protect tiles for this operation
    [_protectedTiles removeAllObjects];
}

- (void) paintTile:(Tile *)tile atPoint:(CGPoint)target
{
    // the single specified tile
    [self addTile:tile toWorkingMapAtPoint:target];
    
    NSMutableArray *diagonals = [[NSMutableArray alloc] initWithCapacity:4];
    [self putNeighborsOf:target intoQueue:diagonals directions:SecondaryDirections];
    
    NSMutableArray *straights = [[NSMutableArray alloc] initWithCapacity:4];
    [self putNeighborsOf:target intoQueue:straights directions:PrimaryDirections];
    
    // Try placing the diagonals.
    for (int i = 0; i < diagonals.count; i++) {
        // Leave this tile along
        if ([_protectedTiles member:[diagonals objectAtIndex:i]]) {
            continue;
        }
        
        Tile *success = [self findTileFor:[[diagonals objectAtIndex:i] CGPointValue] isDiagonal:YES fromAnchorCoord:target];
        if (!success) {
            CCLOG(@"Failed to find a tile for %@", NSStringFromCGPoint([[diagonals objectAtIndex:i] CGPointValue]));
            continue;
        }
        
        [self addTile:success toWorkingMapAtPoint:[[diagonals objectAtIndex:i] CGPointValue]];
    }
    
    // Try placing the straights.
    for (int i = 0; i < straights.count; i++) {
        // Leave this tile along
        if ([_protectedTiles member:[straights objectAtIndex:i]]) {
            continue;
        }
        
        Tile *success = [self findTileFor:[[straights objectAtIndex:i] CGPointValue] isDiagonal:NO fromAnchorCoord:target];
        if (!success) {
            CCLOG(@"Failed to find a tile for %@", NSStringFromCGPoint([[straights objectAtIndex:i] CGPointValue]));
            continue;
        }
        
        [self addTile:success toWorkingMapAtPoint:[[straights objectAtIndex:i] CGPointValue]];
    }

}


- (Tile *) findTileFor:(CGPoint)coord isDiagonal:(BOOL)isDiagonal fromAnchorCoord:(CGPoint)anchor
{
    
    // Build the integers that we need to make the signature we will use to search for a tile
    CardinalDirections directionFromAnchor = [self directionOfCoord:coord relativeToCoord:anchor];
    
    int nw, ne, sw, se;
    
    
    switch (directionFromAnchor) {
        case North:
        {
            Tile *s = [self tileAt:anchor];
            sw = [s cornerNWTarget];
            se = [s cornerNETarget];
            
            Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            
            if (!w) {
                nw = -1;
            } else {
                nw = [w cornerNETarget];
            }
            
            if (!e) {
                ne = -1;
            } else {
                ne = [e cornerNWTarget];
            }
            break;
        }
        case East:
        {
            Tile *w = [self tileAt:anchor];
            nw = [w cornerNETarget];
            sw = [w cornerSETarget];
            
            Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            
            if (!n) {
                ne = -1;
            } else {
                ne = [n cornerSETarget];
            }
            
            if (!s) {
                se = -1;
            } else {
                se = [s cornerNETarget];
            }
            break;
        }
        case South:
        {
            Tile *n = [self tileAt:anchor];
            nw = [n cornerSWTarget];
            ne = [n cornerSETarget];
            
            Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            
            if (!w) {
                sw = -1;
            } else {
                sw = [w cornerSETarget];
            }
            
            if (!e) {
                se = -1;
            } else {
                se = [e cornerSWTarget];
            }
            break;
        }
        case West:
        {
            Tile *e = [self tileAt:anchor];
            ne = [e cornerNWTarget];
            se = [e cornerSWTarget];
            
            Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            
            if (!n) {
                nw = -1;
            } else {
                nw = [n cornerSWTarget];
            }
            
            if (!s) {
                sw = -1;
            } else {
                sw = [s cornerNWTarget];
            }
            break;
        }
        case Northwest:
        {
            Tile *seTile = [self tileAt:anchor];
            se = [seTile cornerNWTarget];
            
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            Tile *nwTile = [self tileAt:[self nextPointInDirection:Northwest from:coord]];
            
            if (!e) {
                ne = -1;
            } else {
                ne = [e cornerNWTarget];
            }
            
            if (!s) {
                sw = -1;
            } else {
                sw = [s cornerNWTarget];
            }
            
            if (!nwTile) {
                nw = -1;
            } else {
                nw = [nwTile cornerSETarget];
            }
            break;
        }
        case Northeast:
        {
            Tile *swTile = [self tileAt:anchor];
            sw = [swTile cornerNETarget];
            
            Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            Tile *neTile = [self tileAt:[self nextPointInDirection:Northeast from:coord]];
            
            if (!w) {
                nw = -1;
            } else {
                nw = [w cornerNETarget];
            }
            
            if (!s) {
                se = -1;
            } else {
                se = [s cornerNETarget];
            }
            
            if (!neTile) {
                ne = -1;
            } else {
                ne = [neTile cornerSWTarget];
            }
            break;
        }
        case Southwest:
        {
            Tile *neTile = [self tileAt:anchor];
            ne = [neTile cornerSWTarget];
            
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
            Tile *swTile = [self tileAt:[self nextPointInDirection:Southwest from:coord]];
            
            if (!e) {
                se = -1;
            } else {
                se = [e cornerSWTarget];
            }
            
            if (!n) {
                nw = -1;
            } else {
                nw = [n cornerSWTarget];
            }
            
            if (!swTile) {
                sw = -1;
            } else {
                sw = [swTile cornerNETarget];
            }
            break;
        }
        case Southeast:
        {
            Tile *nwTile = [self tileAt:anchor];
            nw = [nwTile cornerSETarget];
            
            Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
            Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
            Tile *seTile = [self tileAt:[self nextPointInDirection:Southeast from:coord]];
            
            if (!w) {
                sw = -1;
            } else {
                sw = [w cornerSETarget];
            }
            
            if (!n) {
                ne = -1;
            } else {
                ne = [n cornerSETarget];
            }
            
            if (!seTile) {
                se = -1;
            } else {
                se = [seTile cornerNWTarget];
            }
            break;
        }
        case InvalidDirection:
        {
            return nil;
        }
    }
    
    NSString *signature = [NSString stringWithFormat:@"%i|%i|%i|%i", nw, ne, sw, se];
    
    // Use the signature to search through all of the tiles
    for (Tile *t in [_tileDict objectForKey:TERRAIN_DICT_ALL_TILES_SET]) {
        if ([t isEqualToSignature:signature]) {
            return t;
        }
    }
    
    return nil;
}

- (Tile *)brushForTerrain:(unsigned int)matchingTerrain
                           andOtherTerrain:(unsigned int)otherTerrain
                              andDirection:(CardinalDirections)direction
{
    
    TerrainType *terrain = [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:matchingTerrain];
    NSArray *brushes = nil;
    
    CardinalDirections oppositeDirection = [self directionOpposite:direction];
    
    TerrainBrushTypes brushType;
    
    if (   direction == North
        || direction == South
        || direction == East
        || direction == West) {
        brushType = TerrainBrush_Half;
        brushes   = [terrain halfBrushes];
    } else {
        brushType = TerrainBrush_Quarter;
        brushes   = [terrain quarterBrushes];
        
        // NSAssert(direction != InvalidDirection, @"Invalid Direction");
    }
    
    Tile *theBrush = nil;
    
    for (Tile *brush in brushes) {
        // CCLOG(@"Tile: %@", brush);
        if (brushType == TerrainBrush_Half) {
            if ([brush sideOn:oppositeDirection isOfTerrainType:otherTerrain] && [brush sideOn:direction isOfTerrainType:matchingTerrain]) {
                theBrush = brush;
                return theBrush;
            }
        } else if (brushType == TerrainBrush_Quarter) {
            
            if ([brush cornerWithTerrainType:matchingTerrain] == direction ) { // && [brush threeQuarterBrushType] == otherTerrain
                theBrush = brush;
                return theBrush;
            }
        }
    }
    //NSAssert(theBrush != nil, @"The brush is nil...");
    return nil;
}


#pragma mark -
#pragma mark Utility Methods

- (Tile *)tileForTerrainType:(NSString *)type
{
    return [[[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NAME] objectForKey:type] wholeBrush];
}

- (Tile *)tileForTerrainNumber:(int)terNumber
{
    return [[[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:terNumber] wholeBrush];
}

// Useful for debugging
- (NSString *)stringForDirection:(CardinalDirections)direction
{
    switch (direction) {
        case North:
        {
            return @"north";
        }
        case East:
        {
            return @"east";
        }
        case South:
        {
            return @"south";
        }
        case West:
        {
            return @"west";
        }
        case Northwest:
        {
            return @"northwest";
        }
        case Northeast:
        {
            return @"northeast";
        }
        case Southwest:
        {
            return @"southwest";
        }
        case Southeast:
        {
            return @"southeast";
        }
        case InvalidDirection:
        {
            return @"invalid direction";
        }
    }
}

- (void) createLayerReferencesFrom:(HKTMXTiledMap *)map
{
    // Create layer references
    _terrainLayer       = [map layerNamed:MAP_LAYER_TERRAIN];
    _collisionsLayer    = [map layerNamed:MAP_LAYER_COLLISIONS];
    _objectsLayer       = [map layerNamed:MAP_LAYER_OBJECTS];
    _fogLayer           = [map layerNamed:MAP_LAYER_FOG];
}

- (void) establishWorkingMapFrom:(HKTMXTiledMap *)map
{
    // Create a 2D array in memory to represent the map. We'll randomize and check this, and then
    // use the final result of it to set the actual map tiles.
    _mapSize    = [map mapSize];
    
    _workingMap = [[NSMutableArray alloc] initWithCapacity:_mapSize.width];
    
    Tile *defaultTile = [_tileDict objectForKey:TERRAIN_DICT_DEFAULT];
    
    for (int i = 0; i < _mapSize.width; i++) {
        NSMutableArray *nested = [[NSMutableArray alloc] initWithCapacity:_mapSize.height];
        
        for (int i = 0; i < _mapSize.height; i++) {
            [nested addObject:defaultTile];
        }
        
        [_workingMap addObject:nested];
    }
}

- (void) convertWorkingMapToRealMap
{
    // Finished setting up the Working map -- now use it to set tiles
    for (int i = 0; i < _mapSize.width; i++) {
        for (int j = 0; j < _mapSize.height; j++) {
            if ([[_workingMap objectAtIndex:i] objectAtIndex:j] != [NSNull null]) {
                Tile * tile = [[_workingMap objectAtIndex:i] objectAtIndex:j];
                [_terrainLayer setTileGID:[tile tileGID] at:ccp(i,j)];
            }
        }
    }
}

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

- (void) putNeighborsOf:(CGPoint)coord intoQueue:(NSMutableArray *)queue directions:(DirctionType)dirType
{
    int min, max;
    switch (dirType) {
        case PrimaryDirections:
            min = North;
            max = Northwest;
            break;
        case SecondaryDirections:
            min = Northwest;
            max = InvalidDirection;
            break;
        case AllDirections:
            min = North;
            max = InvalidDirection;
    }
    
    for (int direction = min; direction < max; direction++) {
        CGPoint dir = [self nextPointInDirection:direction from:coord];
        if ([self isValid:dir]) {
            [queue addObject:[NSValue valueWithCGPoint:dir]];
        }
    }
}

- (Tile *)tileAt:(CGPoint)coord
{
    Tile *t = nil;
    if ([self isValid:coord]) {
        t = [[_workingMap objectAtIndex:coord.x] objectAtIndex:coord.y];
    }
    return t;
}

- (Tile *)tileTo:(CardinalDirections)direction ofTileAt:(CGPoint)coord
{
    Tile *t = nil;
    
    switch (direction) {
        case North:
        {
            CGPoint n = [self nextPointInDirection:North from:coord];
            if ([self isValid:n]) {
                t = [[_workingMap objectAtIndex:n.x] objectAtIndex:n.y];
            }
            break;
        }
        case East:
        {
            CGPoint e = [self nextPointInDirection:East from:coord];
            if ([self isValid:e]) {
                t = [[_workingMap objectAtIndex:e.x] objectAtIndex:e.y];
            }
            break;
        }
        case South:
        {
            CGPoint s = [self nextPointInDirection:South from:coord];
            if ([self isValid:s]) {
                t = [[_workingMap objectAtIndex:s.x] objectAtIndex:s.y];
            }
            break;
        }
        case West:
        {
            CGPoint w = [self nextPointInDirection:West from:coord];
            if ([self isValid:w]) {
                t = [[_workingMap objectAtIndex:w.x] objectAtIndex:w.y];
            }
            break;
        }
        case Northeast:
        {
            CGPoint ne = [self nextPointInDirection:Northeast from:coord];
            if ([self isValid:ne]) {
                t = [[_workingMap objectAtIndex:ne.x] objectAtIndex:ne.y];
            }
            break;
        }
        case Northwest:
        {
            CGPoint nw = [self nextPointInDirection:Northwest from:coord];
            if ([self isValid:nw]) {
                t = [[_workingMap objectAtIndex:nw.x] objectAtIndex:nw.y];
            }
            break;
        }
        case Southeast:
        {
            CGPoint se = [self nextPointInDirection:Southeast from:coord];
            if ([self isValid:se]) {
                t = [[_workingMap objectAtIndex:se.x] objectAtIndex:se.y];
            }
            break;
        }
        case Southwest:
        {
            CGPoint sw = [self nextPointInDirection:Southwest from:coord];
            if ([self isValid:sw]) {
                t = [[_workingMap objectAtIndex:sw.x] objectAtIndex:sw.y];
            }
            break;
        }
        case InvalidDirection:
        {
            t = nil;
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
        case InvalidDirection:
        {
            return CGPointNull;
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

- (CardinalDirections)directionOpposite:(CardinalDirections)direction
{
    switch (direction) {
        case North:
        {
            return South;
        }
        case East:
        {
            return West;
        }
        case South:
        {
            return North;
        }
        case West:
        {
            return East;
        }
        case Northwest:
        {
            return Southeast;
        }
        case Northeast:
        {
            return Southwest;
        }
        case Southwest:
        {
            return Northeast;
        }
        case Southeast:
        {
            return Northwest;
        }
        default:
            return InvalidDirection;
    }
}

- (CardinalDirections)directionOfCoord:(CGPoint)coord relativeToCoord:(CGPoint)otherCoord
{
    CGPoint offset = ccpSub(coord, otherCoord);
    
    if (CGPointEqualToPoint(offset, ccp(0,0))) {
        return InvalidDirection;
    } else if (offset.x == 0  && offset.y == 1)  {
        return South;
    } else if (offset.x == 0  && offset.y == -1) {
        return North;
    } else if (offset.x == 1  && offset.y == 0)  {
        return East;
    } else if (offset.x == -1 && offset.y == 0)  {
        return West;
    } else if (offset.x == 1  && offset.y == 1)  {
        return Southeast;
    } else if (offset.x == 1  && offset.y == -1) {
        return Northeast;
    } else if (offset.x == -1 && offset.y == 1)  {
        return Southwest;
    } else if (offset.x == -1 && offset.y == -1) {
        return Northwest;
    } else {
        return InvalidDirection;
    }
    
}

- (Tile *)tileWithID:(unsigned int)tileID
{
    NSString *key = [NSString stringWithFormat:@"%i", tileID];
    return [[_tileDict objectForKey:key] objectAtIndex:0];
}

- (Tile *)workingTileAt:(CGPoint)pos
{
    return [[_workingMap objectAtIndex:pos.x] objectAtIndex:pos.y];
}

- (Tile *)workingTileAtValuePt:(NSValue *)posAsValue
{
    CGPoint pt = [posAsValue CGPointValue];
    return [[_workingMap objectAtIndex:pt.x] objectAtIndex:pt.y];
}

- (void) addTile:(Tile *)tile toWorkingMapAtPoint:(CGPoint)coord
{
    [[_workingMap objectAtIndex:coord.x] setObject:tile atIndex:coord.y];
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


// This isn't a great method because it changes the map without
// changing the _workingMap, so the tiles that are here go
// undetected by the _workingMap. It is useful, however, to
// fill the map so that there are no blank tiles.
// It probably should be removed.
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


@end

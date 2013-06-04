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

const CGPoint CGPointNull = {(CGFloat)NAN, (CGFloat)NAN};

@implementation RandomMapGenerator


- (id) init
{
    self = [super init];
    if (self) {
        // Set up whatever parameters...
        _edges = [[NSMutableSet alloc] init];
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
    
    // TODO: Read this from a tile property instead of assigning it here.
    _landingStripTerrain = 0;
    
    [self createLayerReferencesFrom:map];
    
    // This removes the placeholder tiles on each layer in the .tmx file.
    // Map randomization will not work properly if you remove this line.
    [self cleanTempTilesFrom:map];
    
    [self parseTerrainTileset:map];
    
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
 
    TerrainType objects also have halfBrushes and quarterBrushes arrays from which you can draw tiles. The purpose of brushes
    is not to simply be tiles in an array. Eventually, there should be a TerrainBrush class that paints terrain in a manner
    similar to how it is done in Tiled. Take a look here, around line 260, to see how it is implemented in Tiled:
    https://github.com/bjorn/tiled/blob/master/src/tiled/terrainbrush.cpp
 
    What we probably need to do is to simply place down the whole tile for the desired brush, and then perform a tree search,
    maybe a breadth-first search, to look for tiles that will match as closely as possible with the surrounding terrain.
 
    Finally, the TerrainTilePositioned objects have a series of pass-through (to the TerrainTile) methods that
    provide more detail about whether they contain a certain type of terrain. See the header file for more info.
 
 */

- (void) parseTerrainTileset:(HKTMXTiledMap *)map
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
    TerrainTilePositioned *t = [self tileWithID:23];
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
    TerrainTilePositioned *dirt  = [[[[_tileDict objectForKey:TERRAIN_DICT_TERRAINS] objectAtIndex:3] wholeBrushes] objectAtIndex:0]; //_landingStripTerrain
    TerrainTilePositioned *grass = [_tileDict objectForKey:TERRAIN_DICT_DEFAULT];
    
    // Paint the solid tiles onto the map
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            CGPoint pt = ccpAdd(start, ccp(j,i));
            [self paintTile:dirt atPoint:pt];
            [_protectedTiles addObject:[NSValue valueWithCGPoint:pt]];
        }
    }
    
    CCLOG(@"Protected: %@", _protectedTiles);
    
    [self processEdges];
    
    // Only protect tile for this operation
    [_protectedTiles removeAllObjects];
    
    // [self paintTile:grass atPoint:ccp(6, 2)];
    // [self processEdges];
    
    // Problem here is that it only detects solid tiles as a base for painting.
    // Need to be able to look up the required match instead of just looking for
    // the terrain type that covers the entire tile.
    
    
}

- (void) paintTile:(TerrainTilePositioned *)tile atPoint:(CGPoint)target
{
    // the single specified tile
    [self addTile:tile toWorkingMapAtPoint:target];
    
    // The surrounding tiles -- need edges
    NSMutableArray *neighbors = [[NSMutableArray alloc] init];
    [self putNeighborsOf:target intoQueue:neighbors primaryDirectionsOnly:NO];
    
    for (int i = 0; i < neighbors.count; i++) {
        if ([_protectedTiles member:[neighbors objectAtIndex:i]]) {
            continue;
        }
        [self addTile:tile toWorkingMapAtPoint:[[neighbors objectAtIndex:i] CGPointValue]];
    }

    // Track the edes
    [_edges addObjectsFromArray:neighbors];
}

- (void) processEdges
{
    // http://stackoverflow.com/questions/8901987/map-tiling-algorithm?rq=1
    
    NSMutableArray *tileQueue = [[NSMutableArray alloc] init];
    NSMutableArray *pointQueue = [[NSMutableArray alloc] init];
    
    while (_edges.count > 0) {
        NSValue *edgeVal = [_edges anyObject];
        [_edges removeObject:edgeVal];
        
        CGPoint edgePt = [edgeVal CGPointValue];
        TerrainTilePositioned *edgeTile = [self edgeCaseTypeForPoint:edgePt];
        
        if (!edgeTile) {
            // It's not an edge tile, so we can continue
            continue;
        }
        
        // It is an edge tile. Add it to the change queue
        [tileQueue addObject:edgeTile];
        [pointQueue addObject:edgeVal];
        
    }
    
    // Process the change queue
    for (int i = 0; i < tileQueue.count; i++) {
        [self addTile:[tileQueue objectAtIndex:i] toWorkingMapAtPoint:[[pointQueue objectAtIndex:i] CGPointValue]];
    }
}

- (TerrainTilePositioned *)edgeCaseTypeForPoint:(CGPoint)edgePt
{
    int tileType = [[self workingTileAt:edgePt] wholeBrushType];
    
    NSMutableSet   *nonEdgeCheck       = [[NSMutableSet alloc] init];
    NSMutableArray *neighborMatchArray = [[NSMutableArray alloc] init];
    
    [nonEdgeCheck addObject:[NSNumber numberWithInt:tileType]];

    
    for (int direction = North; direction < InvalidDirection; direction++) {
        CGPoint dir = [self nextPointInDirection:direction from:edgePt];
        if ([self isValid:dir]) {
            int thisType = [[self workingTileAt:dir] wholeBrushType];
            [neighborMatchArray addObject:[NSNumber numberWithInt:thisType]];
            [nonEdgeCheck addObject:[NSNumber numberWithInt:thisType]];
        } else {
            // Invalid (off map) tiles get the same number as the main edge tile
            [neighborMatchArray addObject:[NSNumber numberWithInt:tileType]];
        }
    }
    
    // Non edges will only have a single value in this set
    if (nonEdgeCheck.count == 1) {
        nonEdgeCheck = nil;
        return nil;
    }
    
    //CCLOG(@"---");
    //CCLOG(@"Processing edge at %@", NSStringFromCGPoint(edgePt));
    
    EdgeCaseType       caseType = EdgeCase_None;
    CardinalDirections brushDirection;
    
    int matchingTerrain = tileType;
    int otherTerrain    = -1; // default
    
    // Case 1
    if ([[neighborMatchArray objectAtIndex:East] intValue] == [[neighborMatchArray objectAtIndex:West] intValue] &&
        [[neighborMatchArray objectAtIndex:East] intValue] == tileType) {
        
        if ([[neighborMatchArray objectAtIndex:North] intValue] == tileType) {
            otherTerrain   = [[neighborMatchArray objectAtIndex:South] intValue];
            brushDirection = North;
        } else {
            otherTerrain = [[neighborMatchArray objectAtIndex:North] intValue];
            brushDirection = South;
        }
        
        caseType = EdgeCase_1;
    }
    
    if (caseType == EdgeCase_None) {
        // Case 2
        if ([[neighborMatchArray objectAtIndex:North] intValue] == [[neighborMatchArray objectAtIndex:South] intValue] &&
            [[neighborMatchArray objectAtIndex:North] intValue] == tileType) {
            
            if ([[neighborMatchArray objectAtIndex:East] intValue] == tileType) {
                otherTerrain = [[neighborMatchArray objectAtIndex:West] intValue];
                brushDirection = East;
            } else {
                otherTerrain = [[neighborMatchArray objectAtIndex:East] intValue];
                brushDirection = West;
            }
            
            caseType = EdgeCase_2;
        }
    }
    
    if (caseType == EdgeCase_None) {
        // Case 3
        if ([[neighborMatchArray objectAtIndex:South] intValue] == [[neighborMatchArray objectAtIndex:East] intValue] &&
            [[neighborMatchArray objectAtIndex:South] intValue] == tileType) {
            
            if ([[neighborMatchArray objectAtIndex:Southeast] intValue] == tileType) {
                otherTerrain = [[neighborMatchArray objectAtIndex:Northwest] intValue];
                brushDirection = Southeast;
            } else {
                otherTerrain = [[neighborMatchArray objectAtIndex:Southeast] intValue];
                brushDirection = Northwest;
            }
            
            caseType = EdgeCase_3;
        }
    }
    
    if (caseType == EdgeCase_None) {
        // Case 4
        if ([[neighborMatchArray objectAtIndex:West] intValue] == [[neighborMatchArray objectAtIndex:South] intValue] &&
            [[neighborMatchArray objectAtIndex:West] intValue] == tileType) {
            
            if ([[neighborMatchArray objectAtIndex:Southwest] intValue] == tileType) {
                otherTerrain = [[neighborMatchArray objectAtIndex:Northeast] intValue];
                brushDirection = Southwest;
            } else {
                otherTerrain = [[neighborMatchArray objectAtIndex:Southwest] intValue];
                brushDirection = Northeast;
            }
            
            caseType = EdgeCase_4;
        }
    }
    
    if (caseType == EdgeCase_None) {
        // Case 5
        if ([[neighborMatchArray objectAtIndex:North] intValue] == [[neighborMatchArray objectAtIndex:East] intValue] &&
            [[neighborMatchArray objectAtIndex:North] intValue] == tileType) {
            
            if ([[neighborMatchArray objectAtIndex:Northeast] intValue] == tileType) {
                otherTerrain = [[neighborMatchArray objectAtIndex:Southwest] intValue];
                brushDirection = Northeast;
            } else {
                otherTerrain = [[neighborMatchArray objectAtIndex:Northeast] intValue];
                brushDirection = Southwest;
            }
            
            caseType = EdgeCase_5;
        }
    }
    
    if (caseType == EdgeCase_None) {
        // Case 6
        if ([[neighborMatchArray objectAtIndex:North] intValue] == [[neighborMatchArray objectAtIndex:West] intValue] &&
            [[neighborMatchArray objectAtIndex:North] intValue] == tileType) {
            
            if ([[neighborMatchArray objectAtIndex:Northwest] intValue] == tileType) {
                otherTerrain = [[neighborMatchArray objectAtIndex:Southeast] intValue];
                brushDirection = Northwest;
            } else {
                otherTerrain = [[neighborMatchArray objectAtIndex:Northwest] intValue];
                brushDirection = Southeast;
            }
            
            caseType = EdgeCase_6;
        }
    }
    
    
    if (otherTerrain == -1) {
        return nil;
    }
    
    
    //CCLOG(@"caseType: %i", caseType);
    //CCLOG(@"     brush matching terrain: %i other terrain: %i direction: %@", matchingTerrain, otherTerrain, [self stringForDirection:brushDirection]);
    
    // Now, we know the terrain types we need to use to call for a tile
    TerrainTilePositioned *terrainTile = [self brushForTerrain:matchingTerrain andOtherTerrain:otherTerrain andDirection:brushDirection];
    return terrainTile;
    
    // TODO: handle cases where there is no match by adding them to a temp edge set that is folded back into the main set after assignment
}


- (TerrainTilePositioned *)brushForTerrain:(unsigned int)matchingTerrain
                           andOtherTerrain:(unsigned int)otherTerrain
                              andDirection:(CardinalDirections)direction
{
    
    TerrainType *terrain = [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS] objectAtIndex:matchingTerrain];
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
    
    TerrainTilePositioned *theBrush = nil;
    
    for (TerrainTilePositioned *brush in brushes) {
        
        if (brushType == TerrainBrush_Half) {
            if ([brush sideOn:oppositeDirection isOfTerrainType:otherTerrain] && [brush sideOn:direction isOfTerrainType:matchingTerrain]) {
                theBrush = brush;
                return theBrush;
            }
        } else if (brushType == TerrainBrush_Quarter) {
            
            if ([brush cornerWithTerrainType:matchingTerrain] == direction && [brush quarterBrushTerrainAlt] == otherTerrain) { 
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
    
    TerrainTilePositioned *defaultTile = [_tileDict objectForKey:TERRAIN_DICT_DEFAULT];
    
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
                TerrainTilePositioned * tile = [[_workingMap objectAtIndex:i] objectAtIndex:j];
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

- (void) putNeighborsOf:(CGPoint)coord intoQueue:(NSMutableArray *)queue primaryDirectionsOnly:(BOOL)primary
{
    int max;
    if (!primary) {
        max = InvalidDirection;
    } else {
        max = Northwest;
    }
    
    for (int direction = North; direction < max; direction++) {
        CGPoint dir = [self nextPointInDirection:direction from:coord];
        if ([self isValid:dir]) {
            [queue addObject:[NSValue valueWithCGPoint:dir]];
        }
    }
}

- (TerrainTilePositioned *)tileTo:(CardinalDirections)direction ofTileAt:(CGPoint)coord
{
    TerrainTilePositioned *t = nil;
    
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

- (TerrainTilePositioned *)tileWithID:(unsigned int)tileID
{
    NSString *key = [NSString stringWithFormat:@"%i", tileID];
    return [[_tileDict objectForKey:key] objectAtIndex:0];
}

- (TerrainTilePositioned *)workingTileAt:(CGPoint)pos
{
    return [[_workingMap objectAtIndex:pos.x] objectAtIndex:pos.y];
}

- (TerrainTilePositioned *)workingTileAtValuePt:(NSValue *)posAsValue
{
    CGPoint pt = [posAsValue CGPointValue];
    return [[_workingMap objectAtIndex:pt.x] objectAtIndex:pt.y];
}

- (void) addTile:(TerrainTilePositioned *)tile toWorkingMapAtPoint:(CGPoint)coord
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

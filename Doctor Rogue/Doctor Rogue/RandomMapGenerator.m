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
#import "TransitionPlan.h"

const CGPoint CGPointNull = {(CGFloat)NAN, (CGFloat)NAN};

@implementation RandomMapGenerator


- (id) init
{
    self = [super init];
    if (self) {
        _edges          = [[NSMutableArray alloc] init];
        _protectedTiles = [[NSMutableSet alloc] init];
        _considerationList   = [[NSMutableArray alloc] init];
        _modifiedTiles = [[NSMutableSet alloc] init];
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
        return map;
    }
    
    CCLOG(@"RandomMapGenerator is generating the map.");
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Generating the Random Map..." forKey:NOTIFICATION_LOADING_UPDATE];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAP_GENERATOR_UPDATE object:nil userInfo:dict];
    
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
#pragma mark Build the tile dictionary and terrain transitions

- (void) parseTileset:(HKTMXTiledMap *)map
{
    NSString *tilesetName = [[map layerNamed:@"terrain"]tileset].name; // Make this so that we can pass in other layer names
    _tileDict             = [TSXTerrainSetParser parseTileset:tilesetName];
    NSAssert(_tileDict != nil, @"The tileDict is nil so the map cannot be randomized.");
    
    
    // _tileDict contains the following:
    // 1. A key for each tile GID that returns the Tile object.
    // 2. A key called TERRAIN_DICT_ALL_TILES_SET that returns a set of all of the tiles
    // 3. A key called TERRAIN_DICT_DEFAULT that returns the Tile that represents the default tile for the tile set (set in the .tsx file)
    // 4. A key called TERRAIN_DICT_TERRAINS_BY_NAME that returns a dictionary of the TerrainType objects, using their names as keys
    // 5. A key called TERRAIN_DICT_TERRAINS_BY_NUMBER that returns an array of TerrainType objects, in order of their terrainNumber.
    
    // There are some utility methods in this file to help extract these more easily. For example:
    // [self tileForTerrainType:@"water_shallow"] will return the tile that is completely water, useful for painting.
    
    
    [self establishTerrainTransitions];
    
    
    // Each TerrainType object has a dictionary of transitions; an array of steps that must be taken to transition from itself to another terrain
    // Each TerrainType is stored under a key that responds to the terrainNumber. For example:
    // [[dirt transitions] objectForKey:@"2"] will return an NSArray of TerrainType objects that represents the steps that you must take
    // to transition from dirt to the TerrainType with terrainNumber == 2.
    
    // More simply, you can call [dirt connections] to receive an array of the terrain types that have a direct connection to dirt.
    // dirt itself will not be included in the array; it is assumed to connect to itself.
}

- (void) establishTerrainTransitions
{
    NSArray *terrainTypes = [_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER];
    
    for (int i = 0; i < terrainTypes.count; i++) {
        TerrainType *tt = [terrainTypes objectAtIndex:i];
        [tt establishConnections:terrainTypes];
    }
    
    for (int i = 0; i < terrainTypes.count; i++) {
        TerrainType *tt = [terrainTypes objectAtIndex:i];
        [tt findTransitionsTo:terrainTypes];
    }
}







# pragma mark -
# pragma mark Clay's Randomization Testing

- (void) clayTestRandomizeOutdoorMap:(HKTMXTiledMap *)map
{
    // Randomize here, into _workingMap
    // [self clayTestCreateOutdoorEntryPoint:lockedCoordinates]; // currently not implemented
    
    //[self clayLakeTest];
    //[self clayRiverTest];
    
    [self clayExampleUsage];
}

- (void) clayExampleUsage
{
    // If you know you want to paint many tiles with the same terrain type,
    // you can submit the coordinates of those tiles in this manner:
    
    [self spotPaintTerrain:@"grass_heavy" atPercentageOfMap:0.1];
    [self spotPaintTerrain:@"grass_light" atPercentageOfMap:0.05];
    [self spotPaintTerrain:@"hole" atPercentageOfMap:0.01];
    
    // If you want to paint tiles one at a time, then you can submit them like this:
    
    //[self paintTile:dirt atPoint:ccp(5,3)];
    
    // Individual tile painting guarantees slightly more accurate painting results
    // due to errors that have to be handled when painting multiple tiles at once.
    // Performance is better painting multiple tiles with an array, however.
    
    // Here we paint a river, just as an example.
    
    CCLOG(@"Now performing the clayRiverTest");
    [self clayRiverTest];

}

- (void) spotPaintTerrain:(NSString *)terrain atPercentageOfMap:(float)percentage
{
    int totalTiles       = _mapSize.width * _mapSize.height;
    int tilesToPaint      = 10 + ((rand() % (totalTiles - 10) * percentage));
    
    NSString *update = [NSString stringWithFormat:@"Painting %i tiles with %@", tilesToPaint, terrain];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:update forKey:NOTIFICATION_LOADING_UPDATE];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAP_GENERATOR_UPDATE object:nil userInfo:dict];
    
    CCLOG(@"Painting %i tiles with %@", tilesToPaint, terrain);
    
    NSMutableArray *pts = [[NSMutableArray alloc] initWithCapacity:tilesToPaint];
    
    for (int i=0; i<tilesToPaint; i++) {
        [pts addObject:[NSValue valueWithCGPoint:ccp(rand() % (int)_mapSize.width, rand() % (int)_mapSize.height)]];
    }
    
    Tile    *terrType    = [self tileForTerrainType:terrain];
    
    [self paintTile:terrType atMultiplePoints:pts];
}


- (void) clayRiverTest {
    
    NSString *terrType = nil;
    
    int randN = rand() % 100;
    if (randN < 50) {
        terrType = @"water_shallow";
    } else {
        terrType = @"water_deep";
    }
    
    Tile *terrain  = [self tileForTerrainType:terrType];
    
    NSMutableArray *paintPoints = [[NSMutableArray alloc] init];
    
    int randStartY = (rand() % (int)_mapSize.height * 0.25);
    int randEndY   = (rand() % (int)_mapSize.height);
    
    if (randStartY < 0) {
        randStartY = 0;
    }
    
    if (randEndY < 0) {
        randEndY = 0;
    }
    
    int offset1 = rand() % 10;
    int offset2 = rand() % 10;
    
    int offsetDir1 = rand() % 100;
    int offsetDir2 = rand() % 100;
    
    if (offsetDir1 > 50) {
        offsetDir1 = -1;
    } else {
        offsetDir1 = 1;
    }
    
    if (offsetDir2 > 50) {
        offsetDir2 = -1;
    } else {
        offsetDir2 = 1;
    }
    
    offset1 *= offsetDir1;
    offset2 *= offsetDir1;
    
    CGPoint start = ccp(0,randStartY);
    CGPoint mid   = ccp((int)(_mapSize.width * 0.5) + offset1, (int)(_mapSize.height * 0.5) + offset2);
    
    CGPoint end   = ccp(_mapSize.width, randEndY);
    
    while (!CGPointEqualToPoint(start, mid)) {
        [paintPoints addObject:[NSValue valueWithCGPoint:start]];
        //[self paintTile:terrain atPoint:start];
        
        int rand1 = rand() % 100;
        BOOL startingRandom = YES;
        int randLimit = 20;
        CGPoint next;
        while (rand1 > randLimit) {
            if (startingRandom) {
                next = [self nextPointInDirection:(rand() % InvalidDirection) from:start];
                startingRandom = NO;
            } else {
                next = [self nextPointInDirection:(rand() % InvalidDirection) from:next];
            }
            //[self paintTile:terrain atPoint:next];
            [paintPoints addObject:[NSValue valueWithCGPoint:next]];
            rand1 = rand() % 100;
            randLimit += 5;
        }
        
        if (start.x < mid.x) {
            start.x += 1;
        } else if (start.x > mid.x) {
            start.x -= 1;
        }
        
        if (start.y < mid.y) {
            start.y += 1;
        } else if (start.y > mid.y) {
            start.y -= 1;
        }
    }
    
    while (!CGPointEqualToPoint(start, end)) {
        [paintPoints addObject:[NSValue valueWithCGPoint:start]];
        //[self paintTile:terrain atPoint:start];
        
        int rand1 = rand() % 100;
        BOOL startingRandom = YES;
        int randLimit = 20;
        CGPoint next;
        while (rand1 > randLimit) {
            if (startingRandom) {
                next = [self nextPointInDirection:(rand() % InvalidDirection) from:start];
                startingRandom = NO;
            } else {
                next = [self nextPointInDirection:(rand() % InvalidDirection) from:next];
            }
            //[self paintTile:terrain atPoint:next];
            [paintPoints addObject:[NSValue valueWithCGPoint:next]];
            rand1 = rand() % 100;
            randLimit += 5;
        }
        
        if (start.x < end.x) {
            start.x += 1;
        } else if (start.x > end.x) {
            start.x -= 1;
        }
        
        if (start.y < end.y) {
            start.y += 1;
        } else if (start.y > end.y) {
            start.y -= 1;
        }
    }
    
    // Send in the points as an array for painting
    [self paintTile:terrain atMultiplePoints:paintPoints];
}

/*
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
    Tile *dirt  = [self tileForTerrainType:@"dirt"]; //_landingStripTerrain
    [self paintTile:dirt atPoint:ccp(4,4)];
}
*/

#pragma mark -
#pragma mark Painting Tiles onto the Map

// Easy entry point into the painting
- (void) paintTile:(Tile *)tile atPoint:(CGPoint)target
{
    NSArray *point = [NSArray arrayWithObject:[NSValue valueWithCGPoint:target]];
    [self doPaintTile:tile atMultiplePoints:point];
}

- (void) paintTile:(Tile *)tile atMultiplePoints:(NSArray *)points
{
    [self doPaintTile:tile atMultiplePoints:points];
    
    // Finally, we want to double-check all modified tiles to make sure that they fit their space.
    // If they don't, then paint them with the preferred tile.
    // This shouldn't be an issue for individually painted tiles.
    [self doubleCheckTiles];
}


- (void) doubleCheckTiles
{
    /*
    for (int i = 0; i < _mapSize.width; i++) {
        for (int j = 0; j < _mapSize.height; j++) {
            NSValue *ptVal = [NSValue valueWithCGPoint:ccp(i, j)];
            if ([_modifiedTiles member:ptVal]) {
                [_modifiedTiles removeObject:ptVal];
            } else {
                continue; // Only check modified tiles.
            }
            
            NSString *currentSignature   = [[self tileAt:[ptVal CGPointValue]] signatureAsString];
            NSString *preferredSignature = [self signatureForMapCoord:[ptVal CGPointValue] matchTo:InvalidDirection];
            if ([currentSignature isEqualToString:preferredSignature]) {
                continue;
            } else {
                Tile *preferred = [self bestTileForSignature:preferredSignature mustMatchNW:NO mustMatchNE:NO mustMatchSW:NO mustMatchSE:NO];
                [self paintTile:preferred atPoint:[ptVal CGPointValue]];
            }
            
        }
    }
     */
    CCLOG(@"Double-checking tiles");
    NSArray *modifiedArray = [_modifiedTiles allObjects];
    for (int i=0; i<modifiedArray.count; i++) {
        NSValue *ptVal = [modifiedArray objectAtIndex:i];
        [_modifiedTiles removeObject:ptVal];
        NSString *currentSignature   = [[self tileAt:[ptVal CGPointValue]] signatureAsString];
        NSString *preferredSignature = [self signatureForMapCoord:[ptVal CGPointValue] matchTo:InvalidDirection];
        if ([currentSignature isEqualToString:preferredSignature]) {
            continue;
        } else {
            Tile *preferred = [self bestTileForSignature:preferredSignature mustMatchNW:NO mustMatchNE:NO mustMatchSW:NO mustMatchSE:NO];
            [self paintTile:preferred atPoint:[ptVal CGPointValue]];
        }
    }
    [_modifiedTiles removeAllObjects];
}

// Don't call this directly
- (void) doPaintTile:(Tile *)tile atMultiplePoints:(NSArray *)points
{
    NSMutableArray *transitionList = [[NSMutableArray alloc] init];
    
    // Create the array that we will use to track whether a tile has been set
    NSMutableArray *checked        = [[NSMutableArray alloc] initWithCapacity:_mapSize.width];
    
    for (int i = 0; i < _mapSize.width; i++) {
        NSMutableArray *nested = [[NSMutableArray alloc] initWithCapacity:_mapSize.height];
        
        for (int i = 0; i < _mapSize.height; i++) {
            [nested addObject:[NSNumber numberWithBool:NO]];
        }
        
        [checked addObject:nested];
    }
    
    // Will hold tiles that we intend to push to the working map
    NSMutableArray *newTerrain    = [[NSMutableArray alloc] initWithCapacity:_mapSize.width];
    
    for (int i = 0; i < _mapSize.width; i++) {
        NSMutableArray *nested = [[NSMutableArray alloc] initWithCapacity:_mapSize.height];
        
        for (int i = 0; i < _mapSize.height; i++) {
            [nested addObject:[NSNull null]];
        }
        
        [newTerrain addObject:nested];
    }
    
    // Container for tiles that cannot be handled during the loop
    // This should only be handled when submitting an array of points
    // instead of painting tiles individually
    NSMutableSet *misfits = [[NSMutableSet alloc] init];
    
    // Get the initial points that were painted and flag them as initials so that
    // they are painted with the proper terrain
    for (int i=0; i<points.count; i++) {
        CGPoint thisPt = [[points objectAtIndex:i] CGPointValue];
        
        TransitionPlan *initial = [[TransitionPlan alloc] init];
        [initial setPoint:thisPt];
        [initial setIsInitialTile:YES];
        [initial setDirFromAnchor:InvalidDirection];
        [initial setDirToAnchor:InvalidDirection];
        
        [transitionList addObject:initial];
    }
    
    while (transitionList.count > 0) {
        // CCLOG(@" ");
        // CCLOG(@"-------------------------------");
        // CCLOG(@"transitionList count: %i", transitionList.count);
        
        TransitionPlan *plan = [transitionList objectAtIndex:0];
        CGPoint point        = [plan point];
        // CCLOG(@"Working with %@", NSStringFromCGPoint(point));
        
        [transitionList removeObjectAtIndex:0];
        
        if (![self isValid:point]) {
            // CCLOG(@"Point is invalid");
            continue;
        }
        
        CGPoint n = [self nextPointInDirection:North from:point];
        CGPoint e = [self nextPointInDirection:East  from:point];
        CGPoint s = [self nextPointInDirection:South from:point];
        CGPoint w = [self nextPointInDirection:West  from:point];
        
        // We have already considered this point. Skip to the next
        if ([self checked:point inArray:checked]) {
            // CCLOG(@"We already have checked this point -- it is in the checked array. Continuing.");
            continue;
        }
        
        Tile *currentTile = [self tileAt:point];
        
        // CCLOG(@"Tile currently at %@ is %@", NSStringFromCGPoint(point), currentTile);
        
        NSString *currentSignature   = [currentTile signatureAsString];
        
        // This should be overwritten later, in the else part of the next block
        NSString *preferredSignature = [self signatureForMapCoord:point matchTo:[plan dirToAnchor]];
        
        // CCLOG(@"Initial setting of preferredSignature: %@", preferredSignature);
        
        BOOL nwMustMatch = NO;
        BOOL neMustMatch = NO;
        BOOL swMustMatch = NO;
        BOOL seMustMatch = NO;
        
        if (plan.isInitialTile) {
            // CCLOG(@"This is the initial tile...");
            preferredSignature = [tile signatureAsString];
            nwMustMatch = YES;
            neMustMatch = YES;
            swMustMatch = YES;
            seMustMatch = YES;
            
            // CCLOG(@"The preferred signature of the initial tile is: %@", preferredSignature);
            // set the tile to be the 'tile' parameter sent in
            if ([currentSignature isEqualToString:preferredSignature]) {
                // CCLOG(@"This is equal to the tile currently in place. There's nothing to do. Continuing.");
                // There's nothing to paint
                continue;
            }
        
        } else {
            // Setting the preferredSignature based on which of the neighbors have been checked already
            int nw = -1;
            int ne = -1;
            int sw = -1;
            int se = -1;

            if ([self isValid:n] && [self checked:n inArray:checked]) {
                // CCLOG(@"This tile has a checked tile to the north.");
                nw = [[[newTerrain objectAtIndex:n.x] objectAtIndex:n.y] cornerSWTarget];
                ne = [[[newTerrain objectAtIndex:n.x] objectAtIndex:n.y] cornerSETarget];
                nwMustMatch = YES;
                neMustMatch = YES;
            }
            
            if ([self isValid:e] && [self checked:e inArray:checked]) {
                // CCLOG(@"This tile has a checked tile to the east.");
                ne = [[[newTerrain objectAtIndex:e.x] objectAtIndex:e.y] cornerNWTarget];
                se = [[[newTerrain objectAtIndex:e.x] objectAtIndex:e.y] cornerSWTarget];
                neMustMatch = YES;
                seMustMatch = YES;
            }
            
            if ([self isValid:s] && [self checked:s inArray:checked]) {
                // CCLOG(@"This tile has a checked tile to the south.");
                sw = [[[newTerrain objectAtIndex:s.x] objectAtIndex:s.y] cornerNWTarget];
                se = [[[newTerrain objectAtIndex:s.x] objectAtIndex:s.y] cornerNETarget];
                swMustMatch = YES;
                seMustMatch = YES;
            }
            
            if ([self isValid:w] && [self checked:w inArray:checked]) {
                // CCLOG(@"This tile has a checked tile to the west.");
                nw = [[[newTerrain objectAtIndex:w.x] objectAtIndex:w.y] cornerNETarget];
                sw = [[[newTerrain objectAtIndex:w.x] objectAtIndex:w.y] cornerSETarget];
                nwMustMatch = YES;
                swMustMatch = YES;
            }
            
            NSArray *prev = [preferredSignature componentsSeparatedByString:@"|"];
            
            if (nw == -1) {
                nw = [[prev objectAtIndex:0] intValue];
            }
            if (ne == -1) {
                ne = [[prev objectAtIndex:1] intValue];
            }
            if (sw == -1) {
                sw = [[prev objectAtIndex:2] intValue];
            }
            if (se == -1) {
                se = [[prev objectAtIndex:3] intValue];
            }
            
            preferredSignature = [NSString stringWithFormat:@"%i|%i|%i|%i", nw, ne, sw, se];
            // CCLOG(@"Preferred Signature set to %@", preferredSignature);
        }
        
        // Continue from line 493
        Tile *paste = nil;
        if (preferredSignature != nil) {
            paste = [self bestTileForSignature:preferredSignature
                                   mustMatchNW:nwMustMatch
                                   mustMatchNE:neMustMatch
                                   mustMatchSW:swMustMatch
                                   mustMatchSE:seMustMatch];
            
            if (!paste) {
                // CCLOG(@"Paste tile not located for point %@", NSStringFromCGPoint(point));
                [misfits addObject:[NSValue valueWithCGPoint:point]];
                continue;
            }
            // CCLOG(@"Best tile found (paste) has signature: %@", [paste signatureAsString]);
        }
        
        [[newTerrain objectAtIndex:point.x] setObject:paste                           atIndex:point.y];
        [[checked objectAtIndex:point.x]    setObject:[NSNumber numberWithBool:YES]   atIndex:point.y];
        [_modifiedTiles addObject:[NSValue valueWithCGPoint:point]];
        
        // consider surrounding tiles if terrain constraints were not satisfied
        if ([self isValid:n] && ![self checked:n inArray:checked]) {
            Tile *nTile = [self tileAt:n];
            if ([nTile cornerSWTarget] != [paste cornerNWTarget] || [nTile cornerSETarget] != [paste cornerNETarget]) {
                TransitionPlan *nPlan = [[TransitionPlan alloc] init];
                [nPlan setPoint:n];
                [nPlan setAnchorPoint:point];
                [nPlan setDirFromAnchor:North];
                [nPlan setDirToAnchor:South];
                [transitionList addObject:nPlan];
                // CCLOG(@"Tile to the north of %@ at %@ added to the transitionList.", NSStringFromCGPoint(point), NSStringFromCGPoint(n));
            }
        }
        
        if ([self isValid:e] && ![self checked:e inArray:checked]) {
            Tile *eTile = [self tileAt:e];
            if ([eTile cornerSWTarget] != [paste cornerSETarget] || [eTile cornerNWTarget] != [paste cornerNETarget]) {
                TransitionPlan *ePlan = [[TransitionPlan alloc] init];
                [ePlan setPoint:e];
                [ePlan setAnchorPoint:point];
                [ePlan setDirFromAnchor:East];
                [ePlan setDirToAnchor:West];
                [transitionList addObject:ePlan];
                // CCLOG(@"Tile to the east  of %@ at %@ added to the transitionList.", NSStringFromCGPoint(point), NSStringFromCGPoint(e));
            }
        }
        
        if ([self isValid:s] && ![self checked:s inArray:checked]) {
            Tile *sTile = [self tileAt:s];
            if ([sTile cornerNWTarget] != [paste cornerSWTarget] || [sTile cornerNETarget] != [paste cornerSETarget]) {
                TransitionPlan *sPlan = [[TransitionPlan alloc] init];
                [sPlan setPoint:s];
                [sPlan setAnchorPoint:point];
                [sPlan setDirFromAnchor:South];
                [sPlan setDirToAnchor:North];
                [transitionList addObject:sPlan];
                // CCLOG(@"Tile to the south of %@ at %@ added to the transitionList.", NSStringFromCGPoint(point), NSStringFromCGPoint(s));
            }
        }
        
        if ([self isValid:w] && ![self checked:w inArray:checked]) {
            Tile *wTile = [self tileAt:w];
            if ([wTile cornerNETarget] != [paste cornerNWTarget] || [wTile cornerSETarget] != [paste cornerSWTarget]) {
                TransitionPlan *wPlan = [[TransitionPlan alloc] init];
                [wPlan setPoint:w];
                [wPlan setAnchorPoint:point];
                [wPlan setDirFromAnchor:West];
                [wPlan setDirToAnchor:East];
                [transitionList addObject:wPlan];
                // CCLOG(@"Tile to the west  of %@ at %@ added to the transitionList.", NSStringFromCGPoint(point), NSStringFromCGPoint(w));
            }
        }
    }
    
    // Process and place the tiles from newTerrain onto WorkingMap
    // Finished setting up the Working map -- now use it to set tiles
    for (int i = 0; i < _mapSize.width; i++) {
        for (int j = 0; j < _mapSize.height; j++) {
            if ([self checked:ccp(i, j) inArray:checked]) {
                Tile *newTile = [[newTerrain objectAtIndex:i] objectAtIndex:j];
                [[_workingMap objectAtIndex:i] setObject:newTile atIndex:j];
            }
        }
    }
    
    // Handle misfits by painting them with the tile submitted to the method
    // This should only be needed for situations that arise when submitting an array of points
    // It's not ideal and perhaps we can figure out how to handle it better
    
    for (NSValue *ptVal in misfits) {
        [self paintTile:tile atPoint:[ptVal CGPointValue]];
    }
    
}

- (BOOL) checked:(CGPoint)point inArray:(NSMutableArray *)array
{
    NSNumber *val = [[array objectAtIndex:point.x] objectAtIndex:point.y];
    return [val boolValue];
}



- (Tile *) bestTileForSignature:(NSString *)sig
                    mustMatchNW:(BOOL)nwMustMatch
                    mustMatchNE:(BOOL)neMustMatch
                    mustMatchSW:(BOOL)swMustMatch
                    mustMatchSE:(BOOL)seMustMatch
{
    
    NSArray *corners = [sig componentsSeparatedByString:@"|"];
    int nw = [[corners objectAtIndex:0] integerValue];
    int ne = [[corners objectAtIndex:1] integerValue];
    int sw = [[corners objectAtIndex:2] integerValue];
    int se = [[corners objectAtIndex:3] integerValue];
    
    int lowestCost = INT_MAX;
    Tile *bestCandidate = nil;
    
    for (Tile *t in [_tileDict objectForKey:TERRAIN_DICT_ALL_TILES_SET]) {
        
        // CCLOG(@"[t signature]: %@", [t signatureAsString]);
        
        // Exact Match
        if ([t isEqualToSignature:sig]) {
            // CCLOG(@"Exact Match!");
            return t;
        }
        
        if (nwMustMatch && nw != [t cornerNWTarget]) {
            continue;
        }
        if (neMustMatch && ne != [t cornerNETarget]) {
            continue;
        }
        if (swMustMatch && sw != [t cornerSWTarget]) {
            continue;
        }
        if (seMustMatch && se != [t cornerSETarget]) {
            continue;
        }
        
        // There was no exact match; look for the lowest cost match.
        // Calculate cost
        int nwCost = [self costFrom:nw toTerrain:[t cornerNWTarget]];
        int neCost = [self costFrom:ne toTerrain:[t cornerNETarget]];
        int swCost = [self costFrom:sw toTerrain:[t cornerSWTarget]];
        int seCost = [self costFrom:se toTerrain:[t cornerSETarget]];
        int totalCost = nwCost + neCost + swCost + seCost;
        
        if (totalCost < lowestCost) {
            lowestCost = totalCost;
            bestCandidate = t;
        }
    }
    
    // CCLOG(@"Searching for match to sig %@ and found %@", sig, bestCandidate);
    
    if (!bestCandidate) {
        // CCLOG(@"Unable to locate a best candidate.");
    }
    
    return bestCandidate;
}


- (Tile *) bestTileForSignature:(NSString *)sig mustMatch:(CardinalDirections)matchDirection
{
    BOOL nwMustMatch = NO;
    BOOL neMustMatch = NO;
    BOOL swMustMatch = NO;
    BOOL seMustMatch = NO;
    
    if (matchDirection == East || matchDirection == West) {
        
    }
    
    switch (matchDirection) {
        case North:
            nwMustMatch = YES;
            neMustMatch = YES;
            break;
            
        case East:
            neMustMatch = YES;
            seMustMatch = YES;
            break;
            
        case South:
            swMustMatch = YES;
            seMustMatch = YES;
            break;
            
        case West:
            nwMustMatch = YES;
            swMustMatch = YES;
            break;
            
        default:
            break;
    }
    
    NSArray *corners = [sig componentsSeparatedByString:@"|"];
    int nw = [[corners objectAtIndex:0] integerValue];
    int ne = [[corners objectAtIndex:1] integerValue];
    int sw = [[corners objectAtIndex:2] integerValue];
    int se = [[corners objectAtIndex:3] integerValue];
    
    int lowestCost = INT_MAX;
    Tile *bestCandidate = nil;
    
    for (Tile *t in [_tileDict objectForKey:TERRAIN_DICT_ALL_TILES_SET]) {
        //CCLOG(@"Seeking %@ and Checking %@",sig, [t signatureAsString]);
        // check for mustMatch
        if (nwMustMatch && [t cornerNWTarget] != nw) {
            continue;
        }
        if (neMustMatch && [t cornerNETarget] != ne) {
            continue;
        }
        if (swMustMatch && [t cornerSWTarget] != sw) {
            continue;
        }
        if (seMustMatch && [t cornerSETarget] != se) {
            continue;
        }
        
        // CCLOG(@"[t signature]: %@", [t signatureAsString]);
        
        // Exact Match
        if ([t isEqualToSignature:sig]) {
            // CCLOG(@"Exact Match!");
            return t;
        }
        
        // There was no exact match; look for the lowest cost match.
        // Calculate cost
        int nwCost = [self costFrom:nw toTerrain:[t cornerNWTarget]];
        int neCost = [self costFrom:ne toTerrain:[t cornerNETarget]];
        int swCost = [self costFrom:sw toTerrain:[t cornerSWTarget]];
        int seCost = [self costFrom:se toTerrain:[t cornerSETarget]];
        int totalCost = nwCost + neCost + swCost + seCost;
        
        if (totalCost < lowestCost) {
            lowestCost = totalCost;
            bestCandidate = t;
        }
    }
    
    // CCLOG(@"Searching for match to sig %@ and found %@", sig, bestCandidate);
    
    if (!bestCandidate) {
        // CCLOG(@"Unable to locate a best candidate.");
    }
    
    return bestCandidate;
}

- (Tile *) findTileFor:(CGPoint)coord withAnchorCoord:(CGPoint)anchor
{
    
    // Build the integers that we need to make the signature we will use to search for a tile
    CardinalDirections directionFromAnchor = [self directionOfCoord:coord relativeToCoord:anchor];
    
    int nw, ne, sw, se;
    BOOL nwMustMatch = NO;
    BOOL neMustMatch = NO;
    BOOL swMustMatch = NO;
    BOOL seMustMatch = NO;
    
    switch (directionFromAnchor) {
        case North:
        {
            seMustMatch = YES;
            swMustMatch = YES;
            
            Tile *s = [self tileAt:anchor];
            sw = [s cornerNWTarget];
            se = [s cornerNETarget];
            
            Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            
            if (!w) {
                // Edge
                w = [self tileAt:[self nextPointInDirection:North from:coord]];
                
                if (!w) {
                    // Corner
                    nw = -1;
                } else {
                    nw = [w cornerSWTarget];
                }
            } else {
                nw = [w cornerNETarget];
            }
            
            if (!e) {
                e = [self tileAt:[self nextPointInDirection:North from:coord]];
                if (!e) {
                    ne = -1;
                } else {
                    ne = [e cornerSETarget];
                }
            } else {
                ne = [e cornerNWTarget];
            }
            break;
        }
        case East:
        {
            nwMustMatch = YES;
            swMustMatch = YES;
            
            Tile *w = [self tileAt:anchor];
            nw = [w cornerNETarget];
            sw = [w cornerSETarget];
            
            Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            
            if (!n) {
                n = [self tileAt:[self nextPointInDirection:East from:coord]];
                if (!n) {
                    ne = -1;
                } else {
                    ne = [n cornerNWTarget];
                }
            } else {
                ne = [n cornerSETarget];
            }
            
            if (!s) {
                s = [self tileAt:[self nextPointInDirection:East from:coord]];
                if (!s) {
                    se = -1;
                } else {
                    se = [s cornerSWTarget];
                }
            } else {
                se = [s cornerNETarget];
            }
            break;
        }
        case South:
        {
            nwMustMatch = YES;
            neMustMatch = YES;
            
            Tile *n = [self tileAt:anchor];
            nw = [n cornerSWTarget];
            ne = [n cornerSETarget];
            
            Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            
            if (!w) {
                w = [self tileAt:[self nextPointInDirection:South from:coord]];
                if (!w) {
                    sw = -1;
                } else {
                    sw = [w cornerNWTarget];
                }
            } else {
                sw = [w cornerSETarget];
            }
            
            if (!e) {
                e = [self tileAt:[self nextPointInDirection:South from:coord]];
                if (!e) {
                    se = -1;
                } else {
                    se = [e cornerNETarget];
                }
            } else {
                se = [e cornerSWTarget];
            }
            break;
        }
        case West:
        {
            neMustMatch = YES;
            seMustMatch = YES;
            
            Tile *e = [self tileAt:anchor];
            ne = [e cornerNWTarget];
            se = [e cornerSWTarget];
            
            Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            
            if (!n) {
                n = [self tileAt:[self nextPointInDirection:West from:coord]];
                if (!n) {
                    nw = -1;
                } else {
                    nw = [n cornerNETarget];
                }
            } else {
                nw = [n cornerSWTarget];
            }
            
            if (!s) {
                s = [self tileAt:[self nextPointInDirection:West from:coord]];
                if (!s) {
                    sw = -1;
                } else {
                    sw = [s cornerSETarget];
                }
            } else {
                sw = [s cornerNWTarget];
            }
            break;
        }
        case Northwest:
        {
            seMustMatch = YES;
            
            Tile *seTile = [self tileAt:anchor];
            se = [seTile cornerNWTarget];
            
            Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
            Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
            Tile *nwTile = [self tileAt:[self nextPointInDirection:Northwest from:coord]];
            
            // If we've gone NW and NW exists, there WILL be a tile to the east and the south
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
            
            // There may not be a tile to the NW, so we can check n then west
            // If neither are there, we are in the corner
            if (!nwTile) {
                nwTile = [self tileAt:[self nextPointInDirection:North from:coord]];
                if (nwTile) {
                    nw = [nwTile cornerSWTarget];
                } else {
                    nwTile = [self tileAt:[self nextPointInDirection:West from:coord]];
                    if (nwTile) {
                        nw = [nwTile cornerNETarget];
                    } else {
                        nw = -1;
                    }
                }
            } else {
                nw = [nwTile cornerSETarget];
            }
            break;
        }
        case Northeast:
        {
            swMustMatch = YES;
            
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
                neTile = [self tileAt:[self nextPointInDirection:North from:coord]];
                if (neTile) {
                    ne = [neTile cornerSETarget];
                } else {
                    neTile = [self tileAt:[self nextPointInDirection:East from:coord]];
                    if (neTile) {
                        ne = [neTile cornerNWTarget];
                    } else {
                        ne = -1;
                    }
                }
            } else {
                ne = [neTile cornerSWTarget];
            }
            break;
        }
        case Southwest:
        {
            neMustMatch = YES;
            
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
                swTile = [self tileAt:[self nextPointInDirection:South from:coord]];
                if (swTile) {
                    sw = [swTile cornerNWTarget];
                } else {
                    swTile = [self tileAt:[self nextPointInDirection:West from:coord]];
                    if (swTile) {
                        sw = [swTile cornerSETarget];
                    } else {
                        sw = -1;
                    }
                }
            } else {
                sw = [swTile cornerNETarget];
            }
            break;
        }
        case Southeast:
        {
            nwMustMatch = YES;
            
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
                seTile = [self tileAt:[self nextPointInDirection:South from:coord]];
                if (seTile) {
                    se = [seTile cornerNETarget];
                } else {
                    seTile = [self tileAt:[self nextPointInDirection:East from:coord]];
                    if (seTile) {
                        se = [seTile cornerSWTarget];
                    } else {
                        se = -1;
                    }
                }
            } else {
                se = [seTile cornerNWTarget];
            }
            break;
        }
        case InvalidDirection:
        {
            NSAssert(directionFromAnchor != InvalidDirection, @"Invalid Direction");
        }
    }
    
    NSString *signature = [NSString stringWithFormat:@"%i|%i|%i|%i", nw, ne, sw, se];
    
    // We may not need to change the tile, if the existing tile matches the signature
    if ([[self tileAt:coord] isEqualToSignature:signature]) {
        return [self tileAt:coord];
    }
    
    int lowestCost = INT_MAX;
    Tile *bestCandidate = nil;
    
    // Use the signature to search through all of the tiles
    for (Tile *t in [_tileDict objectForKey:TERRAIN_DICT_ALL_TILES_SET]) {
        
        // check for mustMatch
        if (nwMustMatch && [t cornerNWTarget] != nw) {
            continue;
        }
        if (neMustMatch && [t cornerNETarget] != ne) {
            continue;
        }
        if (swMustMatch && [t cornerSWTarget] != sw) {
            continue;
        }
        if (seMustMatch && [t cornerSETarget] != se) {
            continue;
        }
        
        // CCLOG(@"[t signature]: %@", [t signatureAsString]);
        
        // Exact Match
        if ([t isEqualToSignature:signature]) {
            // CCLOG(@"Exact Match!");
            return t;
        }
        
        // There was no exact match; look for the lowest cost match.
        // Calculate cost
        int nwCost = [self costFrom:nw toTerrain:[t cornerNWTarget]];
        int neCost = [self costFrom:ne toTerrain:[t cornerNETarget]];
        int swCost = [self costFrom:sw toTerrain:[t cornerSWTarget]];
        int seCost = [self costFrom:se toTerrain:[t cornerSETarget]];
        int totalCost = nwCost + neCost + swCost + seCost;
        
        if (totalCost < lowestCost) {
            lowestCost = totalCost;
            bestCandidate = t;
        }
        // CCLOG(@"totalCost: %i vs. lowestCost: %i", totalCost, lowestCost);
        
    }
    
    // If we have gotten here, the terrain constraints were not satisfied and we
    // are using a bestCandidate. We need to add the neighbors of this coordinate
    // to the consideration list, which will be processed after the tiles from
    // the anchor that led to this point in the first place.
    
    // For tiles on the consideration list, we need to search for the best terrain
    // for the location and then add it to the map; in searaching, if we again are
    // unable to satisfy the terrain constraints, then we will append more locations
    // to the consideration list until all constraints are satisfied. These tiles
    // do not need to add diagonals -- only primary directions
    
    return bestCandidate;
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

- (TerrainType *)terrainWithNumber:(unsigned int)terNum
{
    return [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:terNum];
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

- (NSString *)signatureForMapCoord:(CGPoint)coord matchTo:(CardinalDirections)matchDirection
{
    int nw, ne, sw, se;
    
    Tile *n = [self tileAt:[self nextPointInDirection:North from:coord]];
    Tile *s = [self tileAt:[self nextPointInDirection:South from:coord]];
    Tile *e = [self tileAt:[self nextPointInDirection:East from:coord]];
    Tile *w = [self tileAt:[self nextPointInDirection:West from:coord]];
    
    // North Tile exists; assign nw and ne
    if (n) {
        nw = [n cornerSWTarget];
        ne = [n cornerSETarget];
    } else {
        if (w) {
            nw = [w cornerNETarget];
        } else {
            nw = -1;
        }
        if (e) {
            ne = [e cornerNWTarget];
        } else {
            ne = -1;
        }
    }
    
    if (s) {
        sw = [s cornerNWTarget];
        se = [s cornerNETarget];
    } else {
        if (w) {
            sw = [w cornerSETarget];
        } else {
            sw = -1;
        }
        if (e) {
            se = [e cornerSWTarget];
        } else {
            se = -1;
        }
    }
    
    if (matchDirection == East) {
        ne = [e cornerNWTarget];
        se = [e cornerSWTarget];
    } else if(matchDirection == West) {
        nw = [w cornerNETarget];
        sw = [w cornerSETarget];
    } else if(matchDirection == North) {
        nw = [n cornerSWTarget];
        ne = [n cornerSETarget];
    } else if(matchDirection == South) {
        se = [s cornerNETarget];
        sw = [s cornerNWTarget];
    } else {
        // CCLOG(@"!! Matching invalid direction: Ok for initial point.");
    }
    
    NSString *signature = [NSString stringWithFormat:@"%i|%i|%i|%i", nw, ne, sw, se];
    return signature;
}

- (int) costFrom:(int)sourceTerrain toTerrain:(int)destTerrain
{
    if (sourceTerrain == -1 || destTerrain == -1) {
        return 0;
    }
    TerrainType *source = [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:sourceTerrain];
    return [source costOfTransitionTo:destTerrain];
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

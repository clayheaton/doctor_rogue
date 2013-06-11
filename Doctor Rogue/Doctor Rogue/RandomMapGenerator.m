//
//  RandomMapGenerator.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import "RandomMapGenerator.h"
#import "HKTMXTiledMap.h"
#import "GameState.h"
#import "TSXTerrainSetParser.h"
#import "Tile.h"
#import "TerrainType.h"
#import "TransitionPlan.h"
#import "Utilities.h"

@implementation RandomMapGenerator


- (id) initWithRandomSeed:(unsigned int)seed
{
    self = [super init];
    if (self) {
        _seed                = seed;
        
        _edges               = [[NSMutableArray alloc] init];
        _protectedTiles      = [[NSMutableSet alloc] init];
        _considerationList   = [[NSMutableArray alloc] init];
        _modifiedTiles       = [[NSMutableSet alloc] init];
        
        _entryPoint = ccp(5,5);
        _entryPointDirection = South;
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self) {
        _seed                = arc4random() % INT_MAX;
        
        _edges               = [[NSMutableArray alloc] init];
        _protectedTiles      = [[NSMutableSet alloc] init];
        _considerationList   = [[NSMutableArray alloc] init];
        _modifiedTiles       = [[NSMutableSet alloc] init];
        
        _entryPoint = ccp(5,5);
        _entryPointDirection = South;
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

- (void)randomize:(HKTMXTiledMap *)map
{
    _map = map;
    
    if (!_map) {
        NSAssert(_map != nil, @"The map is nil.");
    }
    
    CCLOG(@"RandomMapGenerator is generating the map.");
    
    // This is how you send a notification that will be displayed on the LoadingScene screen
    [self displayOnLoadingScreen:@"Generating the Random Map..."];
    
    // TODO: Read this from a tile property instead of assigning it here.
    // This is something Clay is working on -- leave it for the time being.
    _landingStripTerrain = 5;
    
    // Create internal layer references - REQUIRED
    [self createLayerReferencesFrom:_map];
    
    // Remove placeholder tiles - REQUIRED
    [self cleanTempTilesFrom:_map];
    
    // Create the internal representations of the tile set - REQUIRED
    [self parseTileset:_map];
    
    // Create the internal representation of the map - REQUIRED
    [self establishWorkingMapFrom:_map];
    
    // Use the seed - REQUIRED
    srand(_seed);
    
    // Just for testing purposes -- Switch this out with a better method
    // We will have to randomize indoor separately from outdoor.
    // Maps need an entry and exit point -- more on that later.
    [self clayTestRandomizeOutdoorMap:_map];
    
    CCLOG(@"Map randomization complete");
}

- (void)setNewTiles
{
    [self convertWorkingMapToRealMap];
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
    [self clayExampleUsage];
}

- (void) clayExampleUsage
{
    // If you know you want to paint many tiles with the same terrain type,
    // you can submit the coordinates of those tiles in this manner:
    
    [self spotPaintTerrain:@"grass_heavy" atPercentageOfMap:0.1];
    [self spotPaintTerrain:@"grass_light" atPercentageOfMap:0.05];
    [self spotPaintTerrain:@"hole"        atPercentageOfMap:0.01];
    [self spotPaintTerrain:@"brick"       atPercentageOfMap:0.005];
    [self spotPaintTerrain:@"water_deep"  atPercentageOfMap:0.005];
    
    // Others
    // [self spotPaintTerrain:@"brick_dirty"       atPercentageOfMap:0.005];
    // [self spotPaintTerrain:@"water_shallow"     atPercentageOfMap:0.005];
    // [self spotPaintTerrain:@"grass_medium"      atPercentageOfMap:0.005]; // This is the default terrain
    
    // If you want to paint tiles one at a time, then you can submit them like this:
    
    //[self paintTile:dirt atPoint:ccp(5,3)];
    
    // Individual tile painting guarantees slightly more accurate painting results
    // due to errors that have to be handled when painting multiple tiles at once.
    // Performance is better painting multiple tiles with an array, however.
    
    // Here we paint a river, just as an example.
    
    CCLOG(@"Now performing the clayRiverTest");
    [self clayRiverTest];
    
    // Location entry point is to the first map in the location of the adventure
    // Subsequent maps at the same location will have a different type of entry point
    [self createOutdoorLocationEntryPoint];

}

- (void) createOutdoorLocationEntryPoint
{
    
    // Landing strip for the airplane -- FOR NOW
    // Later, this will need to accommodate maps that aren't the first map and/or that are inside/underground.
    int randomDirection = rand() % 4; // 0-3 are North - West
    
    int anchorCoordX = 5 + (rand() % (int)(_mapSize.width  - 10));
    int anchorCoordY = 5 + (rand() % (int)(_mapSize.height - 10));
    
    NSValue * anchorCoord = [NSValue valueWithCGPoint:ccp(anchorCoordX, anchorCoordY)];
    
    
    [self displayOnLoadingScreen:[NSString stringWithFormat:@"Establishing entry point at %@", NSStringFromCGPoint(anchorCoord.CGPointValue)]];
    
    //  North      South
    //    -        x - -
    //  x - -      - - -
    //  - - -        -
    
    //  East       West
    //  x -         x -
    //  - - -     - - -
    //  - -         - -
    
    NSValue *n1, *n2, *n3, *n4, *n5, *extra;
    
    if (randomDirection == North || randomDirection == South) {
        // Set up base coords
        n1 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:East  from:anchorCoord.CGPointValue]];
        n2 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:East  from:n1.CGPointValue]];
        n3 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:South from:anchorCoord.CGPointValue]];
        n4 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:East  from:n3.CGPointValue]];
        n5 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:East  from:n4.CGPointValue]];
        
        if (randomDirection == North) {
            extra = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:North from:n2.CGPointValue]];
        } else {
            extra = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:South from:n4.CGPointValue]];
        }
    } else {
        n1 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:South  from:anchorCoord.CGPointValue]];
        n2 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:South  from:n1.CGPointValue]];
        n3 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:East   from:anchorCoord.CGPointValue]];
        n4 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:South  from:n3.CGPointValue]];
        n5 = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:South  from:n4.CGPointValue]];
        
        if (randomDirection == East) {
            extra = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:East from:n4.CGPointValue]];
        } else {
            extra = [NSValue valueWithCGPoint: [Utilities nextPointInDirection:West from:n2.CGPointValue]];
        }
    }
    
    NSArray *points         = [NSArray arrayWithObjects:anchorCoord, n1, n2, n3, n4, n5, extra, nil];
    Tile    *landingTerrain = [self tileForTerrainNumber:_landingStripTerrain];
    
    _entryPoint = anchorCoord.CGPointValue;
    _entryPointDirection = randomDirection;
    
    // Set these properties on the map
    [[_map properties] setObject:MAP_OUTDOOR_LOCATION_FIRST_MAP                        forKey:MAP_ENTRY_TYPE];
    [[_map properties] setObject:[NSValue valueWithCGPoint:_entryPoint]                forKey:MAP_ENTRY_POINT];
    [[_map properties] setObject:[NSNumber numberWithUnsignedInt:_entryPointDirection] forKey:MAP_ENTRY_DIRECTION];
    
    [self paintTile:landingTerrain atMultiplePoints:points];
    
}

- (void) clayRiverTest {
    
    NSString *terrType = nil;
    
    int randN = rand() % 100;
    if (randN < 50) {
        terrType = @"water_shallow";
    } else {
        terrType = @"water_deep";
    }
    
    [self displayOnLoadingScreen:[NSString stringWithFormat:@"Painting a river with %@", terrType]];
    
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
        
        int rand1 = rand() % 100;
        BOOL startingRandom = YES;
        int randLimit = 20;
        CGPoint next;
        while (rand1 > randLimit) {
            if (startingRandom) {
                next = [Utilities nextPointInDirection:(rand() % InvalidDirection) from:start];
                startingRandom = NO;
            } else {
                next = [Utilities nextPointInDirection:(rand() % InvalidDirection) from:next];
            }

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
        
        int rand1 = rand() % 100;
        BOOL startingRandom = YES;
        int randLimit = 20;
        CGPoint next;
        while (rand1 > randLimit) {
            if (startingRandom) {
                next = [Utilities nextPointInDirection:(rand() % InvalidDirection) from:start];
                startingRandom = NO;
            } else {
                next = [Utilities nextPointInDirection:(rand() % InvalidDirection) from:next];
            }

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


#pragma mark -
#pragma mark Painting Tiles onto the Map

- (void) spotPaintTerrain:(NSString *)terrain atPercentageOfMap:(float)percentage
{
    int totalTiles       = _mapSize.width * _mapSize.height;
    int tilesToPaint     = 3 + ((rand() % (totalTiles - 3) * percentage));
    
    [self displayOnLoadingScreen:[NSString stringWithFormat:@"Painting %i tiles with %@", tilesToPaint, terrain]];
    
    NSMutableArray *pts  = [[NSMutableArray alloc] initWithCapacity:tilesToPaint];
    
    for (int i=0; i<tilesToPaint; i++) {
        [pts addObject:[NSValue valueWithCGPoint:ccp(rand() % (int)_mapSize.width, rand() % (int)_mapSize.height)]];
    }
    
    Tile    *terrType    = [self tileForTerrainType:terrain];
    
    [self paintTile:terrType atMultiplePoints:pts];
}

// Easy entry point into the painting
- (void) paintTile:(Tile *)tile atPoint:(CGPoint)target
{
    NSArray *point = [NSArray arrayWithObject:[NSValue valueWithCGPoint:target]];
    [self doPaintTile:tile atMultiplePoints:point];
}

- (void) paintTile:(Tile *)tile atMultiplePoints:(NSArray *)points
{
    [self doPaintTile:tile atMultiplePoints:points];
    [self doubleCheckTiles];
}

// DON'T CALL THIS DIRECTLY - USE ONE OF THE METHODS ABOVE
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
        
        CGPoint n = [Utilities nextPointInDirection:North from:point];
        CGPoint e = [Utilities nextPointInDirection:East  from:point];
        CGPoint s = [Utilities nextPointInDirection:South from:point];
        CGPoint w = [Utilities nextPointInDirection:West  from:point];
        
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
    short nw = (short)[[corners objectAtIndex:0] intValue];
    short ne = (short)[[corners objectAtIndex:1] intValue];
    short sw = (short)[[corners objectAtIndex:2] intValue];
    short se = (short)[[corners objectAtIndex:3] intValue];
    
    corners = nil;
    
    int lowestCost = INT_MAX;
    Tile *bestCandidate = nil;
    
    for (Tile *t in [_tileDict objectForKey:TERRAIN_DICT_ALL_TILES_SET]) {
        
        // Exact Match
        if ([t isEqualToNW:nw NE:ne SW:sw SE:se]) {
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
    
    return bestCandidate;
}

- (int) costFrom:(int)sourceTerrain toTerrain:(int)destTerrain
{
    if (sourceTerrain == -1 || destTerrain == -1) {
        return 0;
    }
    TerrainType *source = [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:sourceTerrain];
    return [source costOfTransitionTo:destTerrain];
}

- (void) addTile:(Tile *)tile toWorkingMapAtPoint:(CGPoint)coord
{
    [[_workingMap objectAtIndex:coord.x] setObject:tile atIndex:coord.y];
}

- (void) doubleCheckTiles
{
    [self displayOnLoadingScreen:@"Double-checking placed tiles..."];
    
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

#pragma mark -
#pragma mark Setup and Cleanup

- (void) createLayerReferencesFrom:(HKTMXTiledMap *)map
{
    // Create layer references
    _terrainLayer       = [map layerNamed:MAP_LAYER_TERRAIN];
    _collisionsLayer    = [map layerNamed:MAP_LAYER_COLLISIONS];
    _objectsLayer       = [map layerNamed:MAP_LAYER_OBJECTS];
    _fogLayer           = [map layerNamed:MAP_LAYER_FOG];
}

- (void) cleanTempTilesFrom:(HKTMXTiledMap *)map
{
    
    [_terrainLayer    setTileGID:0 at:ccp(0,0)];
    [_collisionsLayer setTileGID:0 at:ccp(0,0)];
    [_objectsLayer    setTileGID:0 at:ccp(0,0)];
    [_fogLayer        setTileGID:0 at:ccp(0,0)];
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

- (void) displayOnLoadingScreen:(NSString *)message
{
    CCLOG(message);
    NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:NOTIFICATION_LOADING_UPDATE];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAP_GENERATOR_UPDATE object:nil userInfo:dict];
}

#pragma mark -
#pragma mark Finding Tiles

- (Tile *)tileAt:(CGPoint)coord
{
    Tile *t = nil;
    if ([self isValid:coord]) {
        t = [[_workingMap objectAtIndex:coord.x] objectAtIndex:coord.y];
    }
    return t;
}

- (Tile *)tileForTerrainType:(NSString *)type
{
    return [[[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NAME] objectForKey:type] wholeBrush];
}

- (Tile *)tileForTerrainNumber:(int)terNumber
{
    return [[[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:terNumber] wholeBrush];
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

- (TerrainType *)terrainWithNumber:(unsigned int)terNum
{
    return [[_tileDict objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:terNum];
}

#pragma mark -
#pragma mark Validating Tiles

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

- (NSString *)signatureForMapCoord:(CGPoint)coord matchTo:(CardinalDirections)matchDirection
{
    int nw, ne, sw, se;
    
    Tile *n = [self tileAt:[Utilities nextPointInDirection:North from:coord]];
    Tile *s = [self tileAt:[Utilities nextPointInDirection:South from:coord]];
    Tile *e = [self tileAt:[Utilities nextPointInDirection:East from:coord]];
    Tile *w = [self tileAt:[Utilities nextPointInDirection:West from:coord]];
    
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

@end

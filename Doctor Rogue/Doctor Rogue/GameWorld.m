//
//  GameWorld.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import "GameWorld.h"
#import "HKTMXTiledMap.h"
#import "HKTMXLayer+Experimental.h"
#import "MapTile.h"
#import "GameObject.h"

@implementation GameWorld

- (id) init
{
    self = [super init];
    if (self) {
        CCLOG(@"Init in GameWorld");
        _tileTypes = [[NSMutableDictionary alloc] init];
        _fogTileID = 9999;
    }
    return self;
}

#pragma mark -
#pragma mark Parsing the map
- (void) parseMap:(HKTMXTiledMap *)map
{
    CCLOG(@"\n\n--- > GameWorld is parsing the map");
    
    // Retain a pointer to the map
    _map = map;
    
    _objectsLayer = [_map layerNamed:@"objects"];
    
    unsigned short mw = _map.mapSize.width;
    unsigned short mh = _map.mapSize.height;
    CCLOG(@"Map is %hu x %hu tiles", mw, mh);
    
    // Create the grid for lookup
    _mapGrid = [[NSMutableArray alloc] initWithCapacity:mw];
    
    for (int i = 0; i < mw; i++) {
        NSMutableArray *nestedArray = [[NSMutableArray alloc] initWithCapacity:mh];
        [_mapGrid addObject:nestedArray];
    }
    
    // Put a mutable dictionary at each nested array point
    for (int i = 0; i < mw; i++) {
        for (int j = 0; j < mh; j++) {
            NSMutableDictionary *nestedDict = [[NSMutableDictionary alloc] init];
            [[_mapGrid objectAtIndex:i] setObject:nestedDict atIndex:j];
        }
    }
    
    // Get the map terrain prefix
    NSString *terrain_prefix = [_map propertyNamed:@"terrain_prefix"];
    
    NSAssert(terrain_prefix != nil, @"The map must include a property called 'terrain_prefix'.");
    
    // Iterate through the map layers and set MapTile info based on properties
    HKTMXLayer *terrainLayer = [_map layerNamed:@"terrain"];
    HKTMXLayer *fogLayer     = [_map layerNamed:@"fog_of_war"];
    
    // Create the MapTiles
    for (int i = 0; i < mw; i++) {
        for (int j=0; j < mh; j++) {
            
            // Create the tile
            MapTile *tile = [[MapTile alloc] initWithCoordinate:ccp(i,j)];
            
            // Terrain Layer
            unsigned int tID = [terrainLayer tileGIDAt:ccp(i,j)];
            [tile setTerrainTileGID:tID];
            
            // Fog Layer
            unsigned int fID = [fogLayer     tileGIDAt:ccp(i,j)];
            [tile setFogTileGID:fID];
            
            [self gatherTileDescription:tID withPrefix:terrain_prefix];
            [self gatherTileDescription:fID withPrefix:terrain_prefix];
            
            // Put the tile in the proper spot in the dictionary
            [[[_mapGrid objectAtIndex:i] objectAtIndex:j] setObject:tile forKey:GAME_WORLD_TILE];
        }
    }
    
    [self gatherTileDescriptionsWithTerrainPrefix:terrain_prefix];
}

#pragma mark -
#pragma mark Managing Tile Descriptions

- (void) gatherTileDescriptionsWithTerrainPrefix:(NSString *)terrainPrefix
{
    int minGID = 999999;
    int maxGID = -1;
    NSMutableArray *mapLayers = [[NSMutableArray alloc] init];
    
    for(id layer in [_map children])
    {
        if([layer isKindOfClass:NSClassFromString(@"HKTMXLayer")]) {
            [mapLayers addObject:layer];
        }
    }
    
    for (HKTMXLayer *layer in mapLayers) {
        int layerMin = [layer minGID];
        int layerMax = [layer maxGID];
        if (layerMin < minGID) {
            minGID = layerMin;
        }
        if (layerMax > maxGID) {
            maxGID = layerMax;
        }
    }
    
    mapLayers = nil;
    
    for (int i = minGID; i < maxGID + 1; i++) {
        [self gatherTileDescription:i withPrefix:terrainPrefix];
    }
}

- (void) gatherTileDescription:(unsigned int)tileID withPrefix:(NSString *)terrainPrefix
{
    if (tileID == 0) {
        return;
    }
    
    // Make sure that the tile type is in the dictionary of descriptions if it has one
    if (![_tileTypes objectForKey:[NSString stringWithFormat:@"%i", tileID]]) {

        NSString *terrain_type_str = [[_map propertiesForGID:tileID] objectForKey:@"terrain_type"];
        
        if ([terrain_type_str isEqualToString:FOG_BLACK]) {
            // Set the fog tile id here so that we can check it easily for other tiles
            _fogTileID = tileID;
        }
        
        if (terrain_type_str) {
            // We have a description and can populate the dictionary
            NSString *terrain_desc = [NSString stringWithFormat:@"%@%@", terrainPrefix, terrain_type_str];
            [_tileTypes setObject:terrain_desc forKey:[NSString stringWithFormat:@"%i", tileID]];
        }
    }
}

- (NSString *) descriptionForTileAt:(CGPoint)coord
{
    // Look for fog first
    
    unsigned int tileFogID = [[self mapTileForCoord:coord] fogTileGID];
    
    if ( tileFogID == _fogTileID) {
        NSString *fogKey = [_tileTypes objectForKey:[NSString stringWithFormat:@"%i", _fogTileID]];
        fogKey = NSLocalizedString(fogKey, nil);
        fogKey = [fogKey stringByAppendingFormat:@" %@", NSStringFromCGPoint(coord)];
        return fogKey;
    }
    
    // No black fog -- look for terrain description
    NSString *val = [_tileTypes objectForKey:[NSString stringWithFormat:@"%i", [[self mapTileForCoord:coord] terrainTileGID]]];
    
    if (!val) {
        CCLOG(@"The tile at %@ is missing a description.", NSStringFromCGPoint(coord));
        return @"";
    }
    
    val = NSLocalizedString(val, nil);
    val = [val stringByAppendingFormat:@" %@", NSStringFromCGPoint(coord)];
    
    return val;
    
}

#pragma mark -
#pragma mark Helper Methods

- (CCSprite *) spriteForTileAt:(CGPoint)coord
{
    // TODO: Iterate through the layers and get the sprite from the uppermost layer
    
    HKTMXLayer *terrainLayer = [_map layerNamed:@"terrain"];
    return [terrainLayer tileAt:coord];
}

- (MapTile *) mapTileForCoord:(CGPoint)coord
{
    return [[[_mapGrid objectAtIndex:coord.x] objectAtIndex:coord.y] objectForKey:GAME_WORLD_TILE];
}

#pragma mark -
#pragma mark GameObject Management Hub

// Everything will be a child of the faux spriteLayer that is a child of the map
- (void) addGameObject:(GameObject *)gameObject
          toMapAtPoint:(CGPoint)point
              usingTag:(ChildTags)childTag
                  andZ:(int)zValue
{

    gameObject.position = [_objectsLayer positionAt:point];
    CCLOG(@"GameObject added to spriteLayer at %@", NSStringFromCGPoint(gameObject.position));
    CCNode *spriteLayer = [_map getChildByTag:kTag_Map_spriteLayer];
    [spriteLayer addChild:gameObject z:zValue tag:childTag];
}


@end

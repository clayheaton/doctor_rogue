//
//  TerrainTile.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import "TerrainTile.h"
#import "TerrainTilePositioned.h"

@implementation TerrainTile

- (unsigned int) northTarget
{
    return [[NSString stringWithFormat:@"%i%i", _cornerNWTarget, _cornerNETarget] unsignedIntValue];
}

- (unsigned int) eastTarget
{
    return [[NSString stringWithFormat:@"%i%i", _cornerNETarget, _cornerSETarget] unsignedIntValue];
}

- (unsigned int) southTarget
{
    return [[NSString stringWithFormat:@"%i%i", _cornerSETarget, _cornerSWTarget] unsignedIntValue];
}

- (unsigned int) westTarget
{
    return [[NSString stringWithFormat:@"%i%i", _cornerSWTarget, _cornerNWTarget] unsignedIntValue];
}

- (TerrainTilePositioned *) tileToMatch:(unsigned int)signature forSide:(TerrainTileSide)tileSide
{
    // The incoming tile is looking for something to match its north side
    if (tileSide == TerrainTileSide_North) {
        
        // This tile's south matches, so we return a TerrainTilePositioned with 0 rotation
        if (signature == [self southTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_0];
        }
        
        // This tile's east matches, so we return a TerrainTilePositioned with 90 degree clockwise rotation
        if (signature == [self eastTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_90];
        }
        
        // This tile's north matches, so we return a TerrainTilePositioned with 180 degree clockwise rotation
        if (signature == [self northTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_180];
        }
        
        // This tile's west matches, so we return a TerrainTilePositioned with 270 degree clockwise rotation
        if (signature == [self westTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_270];
        }
    }
    
    // The incoming tile is looking for something to match its east side
    if (tileSide == TerrainTileSide_East) {
        if (signature == [self westTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_0];
        }
        if (signature == [self southTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_90];
        }
        if (signature == [self eastTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_180];
        }
        if (signature == [self northTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_270];
        }
    }
    
    // The incoming tile is looking for something to match its south side
    if (tileSide == TerrainTileSide_South) {
        if (signature == [self northTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_0];
        }
        if (signature == [self westTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_90];
        }
        if (signature == [self southTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_180];
        }
        if (signature == [self eastTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_270];
        }
    }
    
    // The incoming tile is looking for something to match its west side
    if (tileSide == TerrainTileSide_West) {
        if (signature == [self eastTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_0];
        }
        if (signature == [self northTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_90];
        }
        if (signature == [self westTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_180];
        }
        if (signature == [self southTarget]) {
            return [[TerrainTilePositioned alloc] initWithTerrainTile:self andRotation:TerrainTileRotation_270];
        }
    }

    // This tile doesn't match -- return nil;
    return nil;
}

- (void) establishBrushType
{
    unsigned int type1;
    type1 = _cornerNETarget;
    int type1Count = 1;
    
    if (_cornerNWTarget == type1) {
        type1Count += 1;
    }
    
    if (_cornerSETarget == type1) {
        type1Count += 1;
    }
    
    if (_cornerSWTarget == type1) {
        type1Count += 1;
    }
    
    if (type1Count == 4) {
        _brushType = TerrainBrush_Whole;
    } else if (type1Count == 2) {
        _brushType = TerrainBrush_Half;
    } else {
        _brushType = TerrainBrush_Quarter;
    }
}

- (NSArray *)terrainTypes
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:_cornerNWTarget],
            [NSNumber numberWithUnsignedInt:_cornerNETarget],
            [NSNumber numberWithUnsignedInt:_cornerSWTarget],
            [NSNumber numberWithUnsignedInt:_cornerSETarget],
            nil];
}
- (BOOL) hasTerrainType:(unsigned int)type
{
    if (   type == _cornerNETarget
        || type == _cornerNWTarget
        || type == _cornerSETarget
        || type == _cornerSWTarget) {
        return YES;
    } else {
        return NO;
    }
}

// Only call this if the tile is a "half brush"
- (CardinalDirections) sideWithTerrainType:(unsigned int)type
{
    if ([self brushType] != TerrainBrush_Half) {
        return nil; // Should this be NULL? Hmm...
    }
    
    if (_cornerNWTarget == type) {
        if (_cornerNETarget == type) {
            return North;
        } else {
            return West;
        }
    } else if (_cornerNETarget == type) {
        return East;
    } else {
        return South;
    }
}

// Only call this if the tile is a "quarter brush"
- (TerrainTileCorners) cornerWithTerrainType:(unsigned int)type
{
    for (int i = 0; i < [self terrainTypes].count; i++) {
        if ([[[self terrainTypes] objectAtIndex:i] unsignedIntValue] == type) {
            return i;
        }
    }
    return nil;
}

@end

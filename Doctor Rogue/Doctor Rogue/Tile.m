//
//  Tile.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/4/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import "Tile.h"
#import "TerrainType.h"

@implementation Tile

#pragma mark Setup

- (NSString *)description
{
    return [NSString stringWithFormat:@"Tile nw:%i ne:%i sw:%i se:%i", _cornerNWTarget, _cornerNETarget, _cornerSWTarget, _cornerSETarget];
}

- (void)establishQuarterBrushTerrainType
{
    unsigned int type1 = _cornerNWTarget;
    unsigned int type2 = 9999;
    unsigned int type1Count = 1;
    unsigned int type2Count = 0;
    
    if (_cornerNETarget == type1) {
        type1Count += 1;
    } else {
        type2 = _cornerNETarget;
        type2Count += 1;
    }
    
    if (_cornerSETarget == type1) {
        type1Count += 1;
    } else {
        type2 = _cornerSETarget;
        type2Count += 1;
    }
    
    if (_cornerSWTarget == type1) {
        type1Count += 1;
    } else {
        type2 = _cornerSWTarget;
        type2Count += 1;
    }
    
    if (type1Count == 1) {
        _quarterBrushType = type1;
        _threeQuarterBrushType  = type2;
    } else if (type2Count == 1) {
        _quarterBrushType = type2;
        _threeQuarterBrushType  = type1;
    } else {
        // NSLog(@"Unable to determine quarterBrushTerrainType");
        _quarterBrushType = 9999;
        _threeQuarterBrushType = 9999;
    }
}

#pragma mark -
#pragma mark General Queries
- (NSArray *) signature
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:_cornerNWTarget],
            [NSNumber numberWithUnsignedInt:_cornerNETarget],
            [NSNumber numberWithUnsignedInt:_cornerSWTarget],
            [NSNumber numberWithUnsignedInt:_cornerSETarget],
            nil];
}

- (NSString *) signatureAsString
{
    return [NSString stringWithFormat:@"%i-%i-%i-%i", _cornerNWTarget, _cornerNETarget, _cornerSWTarget, _cornerSETarget];
}

- (NSSet *)    terrainTypes
{
    return [NSSet setWithArray:[self signature]];
}

- (int) wholeBrushType
{
    if ([self terrainTypes].count == 1) {
        return [[[self terrainTypes] anyObject] intValue];
    } else {
        return -1;
    }
}


- (BOOL) containsTerrainType:(TerrainType *)type
{
    int ttype = [type terrainNumber];
    if (_cornerNETarget == ttype ||
        _cornerNWTarget == ttype ||
        _cornerSETarget == ttype ||
        _cornerSWTarget == ttype) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) containsTerrainTypeByNumber:(int)type
{
    if (_cornerNETarget == type ||
        _cornerNWTarget == type ||
        _cornerSETarget == type ||
        _cornerSWTarget == type) {
        return YES;
    } else {
        return NO;
    }
}

- (short) cornersWithTerrainType:(TerrainType *)type
{
    int terType = [type terrainNumber];
    short count = 0;
    if (_cornerNWTarget == terType) {
        count += 1;
    }
    if (_cornerNETarget == terType) {
        count += 1;
    }
    if (_cornerSWTarget == terType) {
        count += 1;
    }
    if (_cornerSETarget == terType) {
        count += 1;
    }
    return count;
}

- (NSArray *)neighbors:(CardinalDirections)direction
{
    switch (direction) {
        case North:
            return _neighborsNorth;
            break;
        case East:
            return _neighborsEast;
            break;
        case West:
            return _neighborsWest;
            break;
        case South:
            return _neighborsSouth;
            break;
            
        default:
            return nil;
            break;
    }
}

- (BOOL)sideOn:(CardinalDirections)direction isOfTerrainType:(unsigned int)type
{
    // This tile doesn't have the specified terrain type or the direction is invalid
    if (direction == InvalidDirection ||
        ![self containsTerrainTypeByNumber:type] ||
        direction >= Northeast) {
        return NO;
    }
    
    switch (direction) {
        case West:
        {
            if( _cornerNWTarget == type && _cornerSWTarget == type) { return YES; }
            break;
        }
            
        case North:
        {
            if (_cornerNWTarget == type && _cornerNETarget == type) { return YES; }
            break;
        }
            
        case East:
        {
            if (_cornerNETarget == type && _cornerSETarget == type) { return YES; }
            break;
        }
            
        case South:
        {
            if (_cornerSWTarget == type && _cornerSETarget == type) { return YES; }
            break;
        }
            
        default:
        {
            return NO;
            break;
        }
    }
    return NO;
}

// Only call this if the tile is a "half brush"
- (CardinalDirections) sideWithTerrainType:(unsigned int)type
{
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
- (CardinalDirections) cornerWithTerrainType:(unsigned int)type
{
    for (int i = 0; i < [self signature].count; i++) {
        if ([[[self signature] objectAtIndex:i] unsignedIntValue] == type) {
            switch (i) {
                case 0:
                {
                    return Northwest;
                    break;
                }
                case 1:
                {
                    return Northeast;
                    break;
                }
                case 2:
                {
                    return Southwest;
                    break;
                }
                case 3:
                {
                    return Southeast;
                    break;
                }
            }
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Identifying Neighbors

- (void) assignNeighborsFrom:(NSMutableArray *)possibleNeighbors
{
    NSMutableArray *tempWest  = [[NSMutableArray alloc] init];
    NSMutableArray *tempNorth = [[NSMutableArray alloc] init];
    NSMutableArray *tempEast  = [[NSMutableArray alloc] init];
    NSMutableArray *tempSouth = [[NSMutableArray alloc] init];
    
    for (Tile *tp in possibleNeighbors) {
        
        if ([self cornerNWTarget] == [tp cornerNETarget] && [self cornerSWTarget] == [tp cornerSETarget]) {
            [tempWest addObject:tp];
        }
        if ([self cornerNWTarget] == [tp cornerSWTarget] && [self cornerNETarget] == [tp cornerSETarget]) {
            [tempNorth addObject:tp];
        }
        if ([self cornerNETarget] == [tp cornerNWTarget] && [self cornerSETarget] == [tp cornerSWTarget]) {
            [tempEast addObject:tp];
        }
        if ([self cornerSWTarget] == [tp cornerNWTarget] && [self cornerSETarget] == [tp cornerNETarget]) {
            [tempSouth addObject:tp];
        }
    }
    
    _neighborsWest  = [NSArray arrayWithArray:tempWest];
    _neighborsNorth = [NSArray arrayWithArray:tempNorth];
    _neighborsEast  = [NSArray arrayWithArray:tempEast];
    _neighborsSouth = [NSArray arrayWithArray:tempSouth];
    
    [self establishQuarterBrushTerrainType];
}

- (BOOL) isNeighborTo:(CardinalDirections)direction ofTile:(Tile *)t
{
    switch (direction) {
        case North:
            return [_neighborsSouth containsObject:t];
        case East:
            return [_neighborsWest containsObject:t];
        case South:
            return [_neighborsNorth containsObject:t];
        case West:
            return [_neighborsEast containsObject:t];
            
        default:
            return NO;
    }
}

- (BOOL) hasTile:(Tile *)t asNeighborTo:(CardinalDirections)direction
{
    switch (direction) {
        case North:
            return [_neighborsNorth containsObject:t];
        case East:
            return [_neighborsEast  containsObject:t];
        case South:
            return [_neighborsSouth containsObject:t];
        case West:
            return [_neighborsWest  containsObject:t];
            
        default:
            return NO;
    }
}

- (BOOL) matchesTile:(Tile *)t onSide:(CardinalDirections)side
{
    NSAssert(side >= Northeast, @"Tiles only match on full sides.");
    
    switch (side) {
        case North:
            if (_cornerNWTarget == [t cornerSWTarget] && _cornerNETarget == [t cornerSETarget]) return YES;
            
        case East:
            if (_cornerNETarget == [t cornerNWTarget] && _cornerSETarget == [t cornerSWTarget]) return YES;
            
        case South:
            if (_cornerSWTarget == [t cornerNWTarget] && _cornerSETarget == [t cornerNETarget]) return YES;
            
        case West:
            if (_cornerNWTarget == [t cornerNETarget] && _cornerSWTarget == [t cornerSETarget]) return YES;
            
        default:
            return NO;
    }
}


@end

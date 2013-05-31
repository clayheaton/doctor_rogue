//
//  TerrainTilePositioned.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import "TerrainTilePositioned.h"

@implementation TerrainTilePositioned

- (NSString *)description
{
    return [NSString stringWithFormat:@"%i", self.tileGID];
}



- (id) initWithTerrainTile:(TerrainTile *)tile  andRotation:(TerrainTileRotation)rot
{
    self = [super init];
    if (self) {
        _terrainTile = tile;
        _rotation    = rot;
        _lockedOnMap = NO;
    }
    return self;
}


- (void) assignNeighborsFrom:(NSMutableArray *)possibleNeighbors
{
    NSMutableArray *tempWest  = [[NSMutableArray alloc] init];
    NSMutableArray *tempNorth = [[NSMutableArray alloc] init];
    NSMutableArray *tempEast  = [[NSMutableArray alloc] init];
    NSMutableArray *tempSouth = [[NSMutableArray alloc] init];
    
    for (TerrainTilePositioned *tp in possibleNeighbors) {
        //NSLog(@".......\n\n");
        //NSLog(@"self id: %i tp id: %i", [self tileGID], [tp tileGID]);
        //NSLog(@"self corners: %i, %i", [self cornerNWTarget], [self cornerNETarget]);
        //NSLog(@"              %i, %i", [self cornerSWTarget], [self cornerSETarget]);
        //NSLog(@"tp   corners: %i, %i", [tp cornerNWTarget], [tp cornerNETarget]);
        //NSLog(@"              %i, %i", [tp cornerSWTarget], [tp cornerSETarget]);
        
        
        if ([self cornerNWTarget] == [tp cornerNETarget] && [self cornerSWTarget] == [tp cornerSETarget]) {
            [tempWest addObject:tp];
            //NSLog(@"match as: WEST neighbor.");
        }
        if ([self cornerNWTarget] == [tp cornerSWTarget] && [self cornerNETarget] == [tp cornerSETarget]) {
            [tempNorth addObject:tp];
            //NSLog(@"match as: NORTH neighbor.");
        }
        if ([self cornerNETarget] == [tp cornerNWTarget] && [self cornerSETarget] == [tp cornerSWTarget]) {
            [tempEast addObject:tp];
            //NSLog(@"match as: EAST neighbor.");
        }
        if ([self cornerSWTarget] == [tp cornerNWTarget] && [self cornerSETarget] == [tp cornerNETarget]) {
            [tempSouth addObject:tp];
            //NSLog(@"match as: SOUTH neighbor.");
        }
    }
    
    _neighborsWest  = [NSArray arrayWithArray:tempWest];
    _neighborsNorth = [NSArray arrayWithArray:tempNorth];
    _neighborsEast  = [NSArray arrayWithArray:tempEast];
    _neighborsSouth = [NSArray arrayWithArray:tempSouth];
    
    // Testing
    /*
    if ([self tileGID] == 2) {
        NSLog(@"TEST tile id 11.");
        NSLog(@"_neighborsWest:  %@", _neighborsWest);
        NSLog(@"_neighborsEast:  %@", _neighborsEast);
        NSLog(@"_neighborsNorth: %@", _neighborsNorth);
        NSLog(@"_neighborsSouth: %@", _neighborsSouth);
    }
     */
    
}


#pragma mark -

- (unsigned int) tileGID
{
    return _terrainTile.tileGID;
}

- (unsigned int) cornerNWTarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile cornerNWTarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile cornerSWTarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile cornerSETarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile cornerNETarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) cornerNETarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile cornerNETarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile cornerNWTarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile cornerSWTarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile cornerSETarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) cornerSETarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile cornerSETarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile cornerNETarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile cornerNWTarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile cornerSWTarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) cornerSWTarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile cornerSWTarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile cornerSETarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile cornerNETarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile cornerNWTarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) northTarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile northTarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile westTarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile southTarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile eastTarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) eastTarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile eastTarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile northTarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile westTarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile southTarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) southTarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile southTarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile eastTarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile northTarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile westTarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

- (unsigned int) westTarget
{
    switch (_rotation) {
        case TerrainTileRotation_0:
        {
            return [_terrainTile westTarget];
            break;
        }
        case TerrainTileRotation_90:
        {
            return [_terrainTile southTarget];
            break;
        }
        case TerrainTileRotation_180:
        {
            return [_terrainTile eastTarget];
            break;
        }
        case TerrainTileRotation_270:
        {
            return [_terrainTile northTarget];
            break;
        }
            
        default:
        {
            NSLog(@"Illegal tile rotation");
            break;
        }
    }
}

#pragma mark -
#pragma mark Pass through methods called on the tile

- (TerrainBrushTypes) brushType
{
    return [_terrainTile brushType];
}

- (NSArray *)terrainTypes
{
    return [_terrainTile terrainTypes];
}

- (BOOL) hasTerrainType:(unsigned int)type
{
    return [_terrainTile hasTerrainType:type];
}

// Only call this if the tile is a "half brush"
- (CardinalDirections) sideWithTerrainType:(unsigned int)type
{
    return [_terrainTile sideWithTerrainType:type];
}

// Only call this if the tile is a "quarter brush"
- (TerrainTileCorners) cornerWithTerrainType:(unsigned int)type
{
    return [_terrainTile cornerWithTerrainType:type];
}

@end

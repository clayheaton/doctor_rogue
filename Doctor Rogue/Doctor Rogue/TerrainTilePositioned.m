//
//  TerrainTilePositioned.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import "TerrainTilePositioned.h"

@implementation TerrainTilePositioned

- (id) initWithTerrainTile:(TerrainTile *)tile
{
    self = [super init];
    if (self) {
        _terrainTile = tile;
        _rotation    = TerrainTileRotation_0;
    }
    return self;
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

@end

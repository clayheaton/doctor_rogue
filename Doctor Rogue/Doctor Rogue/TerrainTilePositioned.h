//
//  TerrainTilePositioned.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import <Foundation/Foundation.h>
#import "TerrainTile.h"
#import "Constants.h"

@interface TerrainTilePositioned : NSObject

@property (retain, readwrite) TerrainTile        *terrainTile;
@property (assign, readwrite) TerrainTileRotation rotation;

// When building the map, use this to "lock" a tile so that it cannot be changed
@property (assign, readwrite) BOOL lockedOnMap;

@property (retain, readwrite) NSArray *neighborsNorth;
@property (retain, readwrite) NSArray *neighborsEast;
@property (retain, readwrite) NSArray *neighborsSouth;
@property (retain, readwrite) NSArray *neighborsWest;


- (id) initWithTerrainTile:(TerrainTile *)tile andRotation:(TerrainTileRotation)rot;

- (unsigned int) tileGID;

- (unsigned int) cornerNWTarget;
- (unsigned int) cornerNETarget;
- (unsigned int) cornerSETarget;
- (unsigned int) cornerSWTarget;

- (unsigned int) northTarget;
- (unsigned int) eastTarget;
- (unsigned int) southTarget;
- (unsigned int) westTarget;

- (void) assignNeighborsFrom:(NSMutableArray *)possibleNeighbors;


@end

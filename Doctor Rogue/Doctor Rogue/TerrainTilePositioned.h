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

// This probably should be a subclass of TerrainTile, but it isn't. :)

@property (retain, readwrite) TerrainTile        *terrainTile;
@property (assign, readwrite) TerrainTileRotation rotation;

@property (retain, readwrite) NSArray *neighborsNorth;
@property (retain, readwrite) NSArray *neighborsEast;
@property (retain, readwrite) NSArray *neighborsSouth;
@property (retain, readwrite) NSArray *neighborsWest;

@property (assign, readwrite) BOOL         isDefaultTile;
@property (assign, readwrite) unsigned int defaultTileTerrainType; // only use for the default

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

- (NSArray *)neighbors:(CardinalDirections)direction;

- (void) assignNeighborsFrom:(NSMutableArray *)possibleNeighbors;

- (TerrainBrushTypes) brushType;
- (NSArray *)terrainTypes;
- (BOOL) hasTerrainType:(unsigned int)type;

// Only call this if the tile is a "half brush"
- (CardinalDirections) sideWithTerrainType:(unsigned int)type;

// Only call this if the tile is a "quarter brush"
- (CardinalDirections) cornerWithTerrainType:(unsigned int)type;

- (BOOL)sideOn:(CardinalDirections)direction isOfTerrainType:(unsigned int)type;

- (unsigned int)quarterBrushTerrainType;
- (unsigned int)quarterBrushTerrainAlt;

@end

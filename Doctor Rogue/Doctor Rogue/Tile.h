//
//  Tile.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/4/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class TerrainType;

@interface Tile : NSObject
@property (assign, readwrite) unsigned int tileGID;

// The types of terrain in the corners
@property (assign, readwrite) unsigned short cornerNWTarget;
@property (assign, readwrite) unsigned short cornerNETarget;
@property (assign, readwrite) unsigned short cornerSETarget;
@property (assign, readwrite) unsigned short cornerSWTarget;

@property (retain, readwrite) NSArray *neighborsNorth;
@property (retain, readwrite) NSArray *neighborsEast;
@property (retain, readwrite) NSArray *neighborsSouth;
@property (retain, readwrite) NSArray *neighborsWest;

@property (assign, readwrite) unsigned int quarterBrushType;
@property (assign, readwrite) unsigned int threeQuarterBrushType;

- (NSArray  *) signature;
- (NSString *) signatureAsString;
- (NSSet *)    terrainTypes;

- (int) wholeBrushType;

- (BOOL) matchesTile:(Tile *)t onSide:(CardinalDirections)side;



- (BOOL) containsTerrainType:(TerrainType *)type;
- (BOOL) containsTerrainTypeByNumber:(int)type;

- (short) cornersWithTerrainType:(TerrainType *)type;

// Only call this if the tile is a "half brush"
- (CardinalDirections) sideWithTerrainType:(unsigned int)type;

// Only call this if the tile is a "quarter brush"
- (CardinalDirections) cornerWithTerrainType:(unsigned int)type;



- (BOOL) sideOn:(CardinalDirections)direction isOfTerrainType:(unsigned int)type;

- (BOOL) isNeighborTo:(CardinalDirections)direction ofTile:(Tile *)t;
- (BOOL) hasTile:(Tile *)t asNeighborTo:(CardinalDirections)direction;


- (void) assignNeighborsFrom:(NSMutableArray *)possibleNeighbors;
- (NSArray *)neighbors:(CardinalDirections)direction;

@end

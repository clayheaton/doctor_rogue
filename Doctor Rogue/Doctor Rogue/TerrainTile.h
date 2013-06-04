//
//  TerrainTile.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class TerrainTilePositioned;

@interface TerrainTile : NSObject

@property (assign, readwrite) unsigned int tileGID;

// The types of terrain in the corners
@property (assign, readwrite) unsigned int cornerNWTarget;
@property (assign, readwrite) unsigned int cornerNETarget;
@property (assign, readwrite) unsigned int cornerSETarget;
@property (assign, readwrite) unsigned int cornerSWTarget;

@property (assign, readwrite) TerrainBrushTypes brushType;
@property (assign, readwrite) unsigned int quarterBrushType;
@property (assign, readwrite) unsigned int quarterBrushAlt;

- (unsigned int) northTarget;
- (unsigned int) eastTarget;
- (unsigned int) southTarget;
- (unsigned int) westTarget;

// Please do not call this method now. It doesn't work with our tile sets. Maybe it should be removed.
// It would be ok to use if we supported rotated tiles.
- (TerrainTilePositioned *) tileToMatch:(unsigned int)signature forSide:(TerrainTileSide)tileSide;

- (void) establishBrushType;

- (NSArray *)terrainTypes;
- (BOOL) hasTerrainType:(unsigned int)type;

// Only call this if the tile is a "half brush"
- (CardinalDirections) sideWithTerrainType:(unsigned int)type;

// Only call this if the tile is a "quarter brush"
- (CardinalDirections) cornerWithTerrainType:(unsigned int)type;

- (BOOL)sideOn:(CardinalDirections)direction isOfTerrainType:(unsigned int)type;

@end

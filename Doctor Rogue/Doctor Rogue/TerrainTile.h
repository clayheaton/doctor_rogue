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

- (unsigned int) northTarget;
- (unsigned int) eastTarget;
- (unsigned int) southTarget;
- (unsigned int) westTarget;

- (TerrainTilePositioned *) tileToMatch:(unsigned int)signature forSide:(TerrainTileSide)tileSide;

@end

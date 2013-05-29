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

- (id) initWithTerrainTile:(TerrainTile *)tile;

- (unsigned int) cornerNWTarget;
- (unsigned int) cornerNETarget;
- (unsigned int) cornerSETarget;
- (unsigned int) cornerSWTarget;

@end

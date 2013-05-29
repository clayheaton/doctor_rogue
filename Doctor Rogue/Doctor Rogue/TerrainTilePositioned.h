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

- (id) initWithTerrainTile:(TerrainTile *)tile andRotation:(TerrainTileRotation)rot;

- (unsigned int) cornerNWTarget;
- (unsigned int) cornerNETarget;
- (unsigned int) cornerSETarget;
- (unsigned int) cornerSWTarget;

- (unsigned int) northTarget;
- (unsigned int) eastTarget;
- (unsigned int) southTarget;
- (unsigned int) westTarget;

@end

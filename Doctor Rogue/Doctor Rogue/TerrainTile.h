//
//  TerrainTile.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface TerrainTile : NSObject

@property (assign, readwrite) unsigned int tileGID;

// The types of terrain in the corners
@property (assign, readwrite) unsigned int cornerNWTarget;
@property (assign, readwrite) unsigned int cornerNETarget;
@property (assign, readwrite) unsigned int cornerSETarget;
@property (assign, readwrite) unsigned int cornerSWTarget;

@end

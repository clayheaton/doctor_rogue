//
//  RandomMapGenerator.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@class HKTMXTiledMap;
@class HKTMXLayer;

@interface RandomMapGenerator : CCNode {
    
}

@property (retain, readwrite) HKTMXTiledMap *map;

@property (assign, readwrite) unsigned int seed;

@property (retain, readwrite) HKTMXLayer *terrainLayer;
@property (retain, readwrite) HKTMXLayer *objectsLayer;
@property (retain, readwrite) HKTMXLayer *collisionsLayer;
@property (retain, readwrite) HKTMXLayer *fogLayer;

@property (retain, readwrite) NSDictionary   *tileDict;
@property (retain, readwrite) NSMutableArray *workingMap;
@property (retain, readwrite) NSMutableArray *edges;
@property (retain, readwrite) NSMutableSet   *protectedTiles;

@property (retain, readwrite) NSMutableSet *modifiedTiles;

@property (retain, readwrite) NSMutableArray *considerationList;

@property (assign, readwrite) CGSize mapSize;

@property (assign, readwrite) unsigned int landingStripTerrain;

@property (assign, readwrite) CGPoint entryPoint;
@property (assign, readwrite) CardinalDirections entryPointDirection;

- (id) initWithRandomSeed:(unsigned int)seed;

- (void)randomize:(HKTMXTiledMap *)map;
- (void)setNewTiles;

@end

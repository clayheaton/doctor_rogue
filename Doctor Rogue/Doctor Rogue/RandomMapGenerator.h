//
//  RandomMapGenerator.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;
@class HKTMXLayer;

@interface RandomMapGenerator : CCNode {
    
}

@property (retain, readwrite) HKTMXLayer *terrainLayer;
@property (retain, readwrite) HKTMXLayer *objectsLayer;
@property (retain, readwrite) HKTMXLayer *collisionsLayer;
@property (retain, readwrite) HKTMXLayer *fogLayer;

@property (retain, readwrite) NSDictionary   *tileDict;
@property (retain, readwrite) NSMutableArray *tileDictKeyArray;
@property (retain, readwrite) NSMutableArray *workingMap;

@property (retain, readwrite) NSMutableSet *processedTiles;

@property (assign, readwrite) CGSize mapSize;

- (HKTMXTiledMap *)randomize:(HKTMXTiledMap *)map;

@end

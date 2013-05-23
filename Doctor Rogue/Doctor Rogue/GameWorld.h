//
//  GameWorld.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;

@interface GameWorld : CCNode {
    
}

@property (retain, nonatomic) HKTMXTiledMap       *map;
@property (retain, nonatomic) NSMutableArray      *mapGrid;
@property (retain, nonatomic) NSMutableDictionary *tileTypes;

@property (assign, readwrite) unsigned int fogTileID;

- (void) parseMap:(HKTMXTiledMap *)map;

- (NSString *) descriptionForTileAt:(CGPoint)coord;
- (CCSprite *) spriteForTileAt:(CGPoint)coord;

@end

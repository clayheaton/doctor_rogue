//
//  GameWorld.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@class HKTMXTiledMap;
@class HKTMXLayer;
@class GameObject;

@interface GameWorld : CCNode {
    
}

@property (retain, nonatomic) HKTMXTiledMap       *map;
@property (retain, nonatomic) HKTMXLayer          *objectsLayer;
@property (retain, nonatomic) NSMutableArray      *mapGrid;
@property (retain, nonatomic) NSMutableDictionary *tileTypes;

@property (assign, readwrite) unsigned int fogTileID;

- (void) parseMap:(HKTMXTiledMap *)map;

- (NSString *) descriptionForTileAt:(CGPoint)coord;
- (CCSprite *) spriteForTileAt:(CGPoint)coord;

- (void) addGameObject:(GameObject *)gameObject
          toMapAtPoint:(CGPoint)point
              usingTag:(ChildTags)childTag
                  andZ:(int)zValue;

@end

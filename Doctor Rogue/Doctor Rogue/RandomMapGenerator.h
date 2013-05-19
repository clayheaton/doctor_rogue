//
//  RandomMapGenerator.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/16/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;

@interface RandomMapGenerator : CCNode {
    
}

- (HKTMXTiledMap *)randomize:(HKTMXTiledMap *)map;

@end

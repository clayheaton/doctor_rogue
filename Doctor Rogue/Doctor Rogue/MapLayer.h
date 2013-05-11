//
//  MapLayer.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;

@interface MapLayer : CCLayer {
    
}

@property (strong, nonatomic) HKTMXTiledMap *currentMap;

@end

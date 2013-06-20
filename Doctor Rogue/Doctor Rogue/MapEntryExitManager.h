//
//  MapEntryExitManager.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/20/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class MapLayer;
@class VignetteAirplane;
@class Airplane;

@interface MapEntryExitManager : CCNode {
    
}

@property (retain, readwrite) MapLayer *mapLayer;

- (id) initWithMapLayer:(MapLayer *)layer;

- (void) processEntry;
- (void) processExit;

@end

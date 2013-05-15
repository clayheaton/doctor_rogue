//
//  MapLayer.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;
@class CCPanZoomController;

@interface MapLayer : CCLayer {
    
}

@property (retain, nonatomic) HKTMXTiledMap *currentMap;
@property (assign, readwrite) CGPoint screenCenter;
@property (assign, readwrite) CGPoint mapDimensions;
@property (retain, readwrite) CCPanZoomController *panZoomController;
@property (assign, readwrite) BOOL showGrid;
@property (assign, readwrite) BOOL tapIsTargetingMapLayer;

@property (assign, readwrite) unsigned short touchCount;

- (id) initWithMap:(HKTMXTiledMap *)map;

@end

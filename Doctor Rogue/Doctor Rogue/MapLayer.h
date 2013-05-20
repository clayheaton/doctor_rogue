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

@property (assign, readwrite) CGPoint previousTileDoubleTapped;
@property (assign, readwrite) CGPoint tileDoubleTapped;
@property (assign, readwrite) BOOL    highlightDoubleTappedTile;

@property (retain, readwrite) CCPanZoomController *panZoomController;
@property (assign, readwrite) BOOL showGrid;
@property (assign, readwrite) BOOL tapIsTargetingMapLayer;

@property (assign, readwrite) unsigned short touchCount; // TODO: Should get rid of this here...

// Tutorial for gesture recognizers: http://www.raywenderlich.com/4817/how-to-integrate-cocos2d-and-uikit
@property (retain) UITapGestureRecognizer * doubleTapRecognizer;

- (id) initWithMap:(HKTMXTiledMap *)map;

@end

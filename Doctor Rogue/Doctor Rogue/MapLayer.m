//
//  MapLayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import "MapLayer.h"
#import "HKTMXTiledMap.h"
#import "Constants.h"
#import "CCPanZoomController.h"

@interface MapLayer (PrivateMethods)
- (void) loadMap;
@end

@implementation MapLayer
@synthesize currentMap          = _currentMap;
@synthesize screenCenter        = _screenCenter;
@synthesize mapDimensions       = _mapDimensions;
@synthesize panZoomController   = _panZoomController;

- (id) init
{
    self = [super init];
    if (self) {
        self.touchEnabled = YES;
        
        
        HKTMXTiledMap *testMap = [CCTMXTiledMap tiledMapWithTMXFile:@"test_map.tmx"];
        [self setUpWithMap:testMap];
    }
    return self;
}

#pragma mark onEnter and onExit
- (void) onExit
{
    [_currentMap release];
    
    [_panZoomController disable];
    [_panZoomController release];
    
    [super onExit];
}

#pragma mark Map Loading and Initialization
-(void) setUpWithMap:(HKTMXTiledMap *)mapToUse
{
    CCLOG(@"MapLayer: setUpWithMap");
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self setScreenCenter:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
    
    [self setCurrentMap:mapToUse];
    [self addChild:_currentMap z:-1 tag:kTag_MapLayer_currentMap];
    
    [_currentMap setAnchorPoint:ccp(0,0)];
    
    // Get the number of tiles W x H
    CGSize ms = [_currentMap mapSize];
    CGSize ts = [_currentMap tileSize];
    
    _mapDimensions = ccp(ms.width * ts.width, ms.height * ts.height);
    
    CGPoint centerTile = CGPointMake((int)(ms.width * 0.5), (int)(ms.height * 0.5));
    CCLOG(@"  centerTile: %f, %f", centerTile.x, centerTile.y);
    
    CGPoint mapCenterPoint = ccp((ms.width * ts.width) * 0.5, (ms.height * ts.height) * 0.5);
    CGRect boundingRect = CGRectMake(0, 0, (ms.width * ts.width), ms.height * ts.height);
    CCLOG(@"boundingRect: %@", NSStringFromCGRect(boundingRect));
    
    // the pan/zoom controller
    // TODO: Figure out why I can't use HKTMXTiledMap here.
    _panZoomController = [CCPanZoomController controllerWithNode:self];// [self getChildByTag:kTag_MapLayer_currentMap]];
    _panZoomController.boundingRect = boundingRect;
    _panZoomController.windowRect   = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _panZoomController.zoomOutLimit = 0.75f;
    _panZoomController.zoomInLimit  = 1.0f;
    _panZoomController.zoomOnDoubleTap = NO;
    
    [_panZoomController enableWithTouchPriority:0 swallowsTouches:NO];
    
    [_panZoomController centerOnPoint:mapCenterPoint];

    
    // Set up the grid that we will use to refer to the tiles.
    // [self establishMapGrid];
}

- (void)draw
{
        [self drawGrid];
}

- (void)drawGrid
{
    glLineWidth(1);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccDrawColor4B(255, 255, 255, 40);
    // ccDrawLine(ccp(0,0), mapDimensions);
    CGSize ts = [_currentMap tileSize];
    for (int i = 0; i < _currentMap.mapSize.width; i++) {
        ccDrawLine(ccp(i * ts.width,0), ccp(i * ts.width,_currentMap.mapSize.height * ts.height));
    }
    for (int i = 0; i < _currentMap.mapSize.height; i++) {
        ccDrawLine(ccp(0,i * ts.height), ccp(_currentMap.mapSize.width * ts.width, i * ts.height));
    }
}


@end

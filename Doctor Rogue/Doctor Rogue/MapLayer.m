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

@interface MapLayer (PrivateMethods)
- (void) loadMap;
@end

@implementation MapLayer
@synthesize currentMap = _currentMap;

- (id) init
{
    self = [super init];
    if (self) {
        self. touchEnabled = YES;
        [self loadMap];
    }
    return self;
}

#pragma mark Map Loading and Initialization
- (void)loadMap
{
    // CGSize screenSize = [[CCDirector sharedDirector] winSize];
    // CGPoint screenCenter = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    
    [self setCurrentMap:[HKTMXTiledMap tiledMapWithTMXFile:@"test_map.tmx"]];
    [self addChild:_currentMap z:-1 tag:kTag_MapLayer_currentMap];
    
    // CCTMXLayer* layer = [_currentMap layerNamed:@"Collisions"];
    // layer.visible = NO;
    
    /*
    // Used to help restrict scrolling too far
    borderSize = 20;
    playableAreaMin = CGPointMake(borderSize, borderSize);
    playableAreaMax = CGPointMake(currentMap.mapSize.width - 1 - borderSize, currentMap.mapSize.height - 1 - borderSize);
    
    [self createInitialGrid];
    
    
    // move map to the center of the screen
    CGSize ms = [currentMap mapSize]; // number of tiles w and h
    CGPoint centerTile = CGPointMake(ms.width * 0.5, ms.height * 0.5);
    
    [self centerTileMapOnTileCoord:centerTile tileMap:currentMap];
     */
}

@end

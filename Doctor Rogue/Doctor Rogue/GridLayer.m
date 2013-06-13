//
//  GridLayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/12/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import "GridLayer.h"
#import "HKTMXLayer.h"
#import "HKTMXTiledMap.h"
#import "Constants.h"
#import "CCSprite+GLBoxes.h"

@implementation GridLayer

#pragma mark -
#pragma mark Creation and Cleanup

- (id) init
{
    self = [super init];
    if (self) {
        _showGrid                  = NO;
        _highlightDoubleTappedTile = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleGrid:)
                                                     name:NOTIFICATION_TOGGLE_GRID
                                                   object:nil];
    }
    return self;
}

- (void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super onExit];
}

#pragma mark -
#pragma mark Grid Drawing and Tile Highlighting

- (void)processDoubleTapWith:(CGPoint)previous andCurrent:(CGPoint)current
{
    _previousTileDoubleTapped = previous;
    _tileDoubleTapped         = current;
    
    if (CGPointEqualToPoint(_previousTileDoubleTapped, _tileDoubleTapped)) {
        _highlightDoubleTappedTile = !_highlightDoubleTappedTile;
    } else {
        _highlightDoubleTappedTile = YES;
    }
    
    [self showHighlightTile:_highlightDoubleTappedTile];
}

- (void) draw
{
    if (_showGrid) {
        [self drawGrid];
    }
}


- (void) toggleGrid:(NSNotification *)notification
{
    _showGrid = !_showGrid;
}

- (void) showHighlightTile:(BOOL)showIt
{
    if (showIt) {
        HKTMXLayer *terrain = [(HKTMXTiledMap *)[self parent] layerNamed:@"terrain"];
        CGPoint t = [terrain positionAt:_tileDoubleTapped];
        
        [self getChildByTag:kTag_Map_gridLayer_highlightTile].position = t;
        [self getChildByTag:kTag_Map_gridLayer_highlightTile].visible  = YES;
    } else {
        [self getChildByTag:kTag_Map_gridLayer_highlightTile].visible = NO;
    }
}

- (void) establishHighlightTile
{
    CCSprite *tileHighlight = [CCSprite rectangleOfSize:_tileSize
                                                withRed:255
                                                  green:255
                                                   blue:255
                                               andAlpha:70];
    
    [self addChild:tileHighlight z:3 tag:kTag_Map_gridLayer_highlightTile];
    tileHighlight.anchorPoint = ccp(0,0);
    tileHighlight.position = ccp(0,0);
    tileHighlight.visible = NO;
}

- (void) highlightTile
{
    glLineWidth(3 * self.scale);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccDrawColor4B(255, 255, 255, 255);
    
    HKTMXLayer *terrain = [(HKTMXTiledMap *)[self parent] layerNamed:@"terrain"];
    CGPoint t = [terrain positionAt:_tileDoubleTapped];
    // t.x += _tileSize.width * 0.5;
    // t.y += _tileSize.height * 0.5;
    
    ccDrawRect(ccp(t.x, t.y), ccp(t.x + _tileSize.width, t.y + _tileSize.height));
    
    //ccDrawCircle( ccp(t.x, t.y), 30, CC_DEGREES_TO_RADIANS(90), 50, NO);
}

- (void) drawGrid
{
    glLineWidth(1);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccDrawColor4B(255, 255, 255, 40);
    
    for (int i = 0; i < _mapSize.width; i++) {
        ccDrawLine(ccp(i * _tileSize.width,0), ccp(i * _tileSize.width,_mapSize.height * _tileSize.height));
    }
    for (int i = 0; i < _mapSize.height; i++) {
        ccDrawLine(ccp(0,i * _tileSize.height), ccp(_mapSize.width * _tileSize.width, i * _tileSize.height));
    }
}

@end

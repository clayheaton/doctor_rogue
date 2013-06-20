//
//  MapLayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//

#import "MapLayer.h"
#import "HKTMXTiledMap.h"
#import "Constants.h"
#import "CCPanZoomController.h"
#import "RandomMapGenerator.h"
#import "GameWorld.h"
#import "MainGameScene.h"
#import "GameObject.h"
#import "GridLayer.h"
#import "GameState.h"
#import "MapEntryExitManager.h"


@interface MapLayer (PrivateMethods)
- (void) registerForNotifications;
- (void) setUpWithMap:(HKTMXTiledMap *)mapToUse;
- (void) drawGrid;
- (void) toggleGrid:(NSNotification *)notification;
- (void) endTouch:(NSNotification *)notification;
@end

@implementation MapLayer

- (id) init
{
    return [self initWithMap:[HKTMXTiledMap tiledMapWithTMXFile:@"test_grasslands.tmx"] andGameWorld:nil];
}

- (id) initWithMap:(HKTMXTiledMap *)map andGameWorld:(GameWorld *)gw
{
    self = [super init];
    if (self) {
        
        NSAssert(gw != nil, @"MapLayer cannot initialize without a valid Gameworld");
        
        _gameWorld = gw;
        
        _tileDoubleTapped = ccp(0,0);
        _previousTileDoubleTapped = ccp(0,0);
        _highlightDoubleTappedTile = NO;
        
        self.touchEnabled = YES;
        self.showGrid     = YES;
        self.tapIsTargetingMapLayer = NO;
        
        [self registerForNotifications];
        
        // At this point, we can assume the map is randomized,
        // and is safe to parse into the GameWorld
        
        [_gameWorld parseMap:map]; // Builds an object representation of the map
        
        [self setUpWithMap:map];
        
    }
    return self;
}

- (BOOL) underlayerIsNeeded
{
    return YES;
}

#pragma mark onEnter and onExit
- (void) onEnter
{
    [super onEnter];
    
    // Double-tap recognizer
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_doubleTapRecognizer];
    [self scheduleUpdate];
}

- (void) onExit
{
    CCLOG(@"MapLayer onExit");
    [_panZoomController disable];
    [self removeAllChildrenWithCleanup:YES];
    
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_doubleTapRecognizer];
    
    _objectToTrack    = nil;
    _entryExitManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super onExit];
}

#pragma mark Notification Handling
- (void) registerForNotifications
{
    
}

#pragma mark Map Loading and Initialization
-(void) setUpWithMap:(HKTMXTiledMap *)mapToUse
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self setScreenCenter:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
    
    [self setCurrentMap:mapToUse];
    [self addChild:_currentMap z:-1 tag:kTag_MapLayer_currentMap];
    
    // Hide layers that shouldn't be visible
    HKTMXLayer *collisions  = [_currentMap layerNamed:MAP_LAYER_COLLISIONS];
    collisions.visible      = NO;
    
    HKTMXLayer *objects     = [_currentMap layerNamed:MAP_LAYER_OBJECTS];
    objects.visible         = NO;
    
    [_currentMap setAnchorPoint:ccp(0,0)];
    
    // Reorder the layers and insert a faux map layer that will hold our sprites
    // http://www.cocos2d-iphone.org/forums/topic/tilemaps-and-sprites/
    [_currentMap reorderChild:collisions z:MAP_LAYER_COLLISIONS_Z];
    [_currentMap reorderChild:objects    z:MAP_LAYER_OBJECTS_Z];
    [_currentMap reorderChild:[_currentMap layerNamed:MAP_LAYER_TERRAIN] z:MAP_LAYER_TERRAIN_Z];
    [_currentMap reorderChild:[_currentMap layerNamed:MAP_LAYER_FOG]     z:MAP_LAYER_FOG_Z];
    
    CCNode *spriteLayer = [CCNode node];
    [_currentMap addChild:spriteLayer z:MAP_LAYER_SPRITES_Z tag:kTag_Map_spriteLayer];
    
    // Create the layer that will draw the grid and selected tiles
    _gridLayer = [[GridLayer alloc] init];
    _gridLayer.mapSize  = _currentMap.mapSize;
    _gridLayer.tileSize = _currentMap.tileSize;
    [_gridLayer establishHighlightTile];
    [_currentMap addChild:_gridLayer z:MAP_LAYER_GRID_Z tag:kTag_Map_gridLayer];
    _gridLayer.showGrid = YES;
    
    // Note from Clay:
    // Since the _panZoomController is attached to MapLayer and not to the map,
    // the anchor point must be set to 0,0 or we cannot properly detect the tile
    // coordinates on the map when we aren't at a zoom factor of 1.0
    // .. I'm not exactly sure why it breaks otherwise, but hey... this works.
    
    [self setAnchorPoint:ccp(0,0)];
    
    // Get the number of tiles W x H
    CGSize ms = [_currentMap mapSize];
    CGSize ts = [_currentMap tileSize];
    
    _mapDimensions = ccp(ms.width * ts.width, ms.height * ts.height);

    
    CGRect boundingRect = CGRectMake(0, 0, (ms.width * ts.width), (ms.height * ts.height) + [[CCDirector sharedDirector] winSize].height * 0.05);
    
    // the pan/zoom controller
    _panZoomController                      = [CCPanZoomController controllerWithNode:self];
    _panZoomController.boundingRect         = boundingRect;
    _panZoomController.windowRect           = CGRectMake(0, 0, screenSize.width, screenSize.height);

    _panZoomController.zoomOnDoubleTap      = NO;
    _panZoomController.centerOnPinch        = YES;
    
    [_panZoomController enableWithTouchPriority:0 swallowsTouches:NO];
    
    // Zoom fixing for small maps.. Retina always will be 0.5 times the value for non-retina
    
    // Determine the width of the map, in pixels. The zoom out limit should be the greater
    // of the either the factor by which the map must be multiplied to be the width of the screen
    // or the default zoom out limit.
    
    float zoomOutLimit = MAP_ZOOM_OUT_LIMIT;
    
    CCLOG(@"Map Dimensions:    %@", NSStringFromCGPoint(_mapDimensions));
    CCLOG(@"Screen Dimensions: %@", NSStringFromCGSize([[CCDirector sharedDirector] winSizeInPixels]));
    
    CGSize screenDim = [[CCDirector sharedDirector] winSizeInPixels];
    
    float xMultFactor = screenDim.width  / _mapDimensions.x;
    float yMultFactor = screenDim.height / _mapDimensions.y;
    
    if (xMultFactor > zoomOutLimit) {
        zoomOutLimit = xMultFactor;
    }
    
    if (yMultFactor > zoomOutLimit) {
        zoomOutLimit = yMultFactor;
    }
    
    CCLOG(@"zoomOutLimit: %f", zoomOutLimit);
    
    float zoomOutLimitRetina = zoomOutLimit * 0.5;
    
    if ([[CCDirector sharedDirector] enableRetinaDisplay:YES]) {
        _panZoomController.zoomOutLimit         = zoomOutLimitRetina;
        _panZoomController.zoomInLimit          = MAP_ZOOM_IN_LIMIT_RETINA;
        _panZoomController.zoomCenteringDamping = MAP_ZOOM_CENTERING_DAMPING_RETINA;
        _panZoomController.scrollRate           = MAP_SCROLL_RATE_RETINA;
        _panZoomController.scrollDamping        = MAP_SCROLL_DAMPING_RETINA;
        
    } else {
        
        _panZoomController.zoomOutLimit         = zoomOutLimit;
        _panZoomController.zoomInLimit          = MAP_ZOOM_IN_LIMIT;
        _panZoomController.zoomCenteringDamping = MAP_ZOOM_CENTERING_DAMPING;
        _panZoomController.scrollRate           = MAP_SCROLL_RATE;
        _panZoomController.scrollDamping        = MAP_SCROLL_DAMPING;
        
    }
    
    
    // Process the map entry
    
    _entryExitManager = [[MapEntryExitManager alloc] initWithMapLayer:self];
    [_entryExitManager processEntry];     
}

- (void) draw
{
    
}

#pragma mark -
#pragma mark Finding Tiles
// Given a screen position, return the tile coordinate
-(CGPoint) tileCoordFromScreenPoint:(CGPoint)location
{
    CGPoint coord = [[CCDirector sharedDirector] convertToGL:location];
    coord = ccpSub(location, ccp([self position].x, [self position].y));    // Result has y-axis reversed
    coord = ccpMult(coord, 1 / [self scale]);
    
	// make sure coordinates are within bounds of the playable area, and cast to int
	coord = CGPointMake((int)coord.x, (int)coord.y);
    
    CGPoint tileCoord = ccp((int)(coord.x / [_currentMap tileSize].width), (int)(coord.y / [_currentMap tileSize].height));
    
    tileCoord.y = [_currentMap mapSize].height - tileCoord.y - 1;
	
	return tileCoord;
}

- (CGPoint)positionOnTerrain:(CGPoint)tileCoordinate
{
    HKTMXLayer *terrain = [_currentMap layerNamed:@"objects"];
    return [terrain positionAt:tileCoordinate];
}

- (CGPoint) mapCoordFromTileCoord:(CGPoint)coord
{
    float yPos = _mapDimensions.y - (coord.y * _currentMap.tileSize.height) - (_currentMap.tileSize.height * 0.5);
    float xPos = coord.x * _currentMap.tileSize.width + (_currentMap.tileSize.width * 0.5);
    return ccp(xPos,yPos);
}


#pragma mark -
#pragma mark Adjustments to CCPanZoomController

- (void) adjustTopBoundTo:(float)dist
{
    CGSize ms = [_currentMap mapSize];
    CGSize ts = [_currentMap tileSize];
    
    _panZoomController.boundingRect = CGRectMake(0, 0, (ms.width * ts.width), (ms.height * ts.height) + [[CCDirector sharedDirector] winSize].height * dist);
    
}

#pragma mark -
#pragma mark Handling touch events

// Current implementation of double-tap is to select a tile on the map;
// this may display terrain or unit information

- (void)handleDoubleTap:(UITapGestureRecognizer *)doubletapRecognizer {
    [TestFlight passCheckpoint:@"Double-tapped to select a map tile"];
    
    CGPoint dtPoint     = [doubletapRecognizer locationInView:[doubletapRecognizer view]];
    CGPoint screenCoord = [[CCDirector sharedDirector] convertToGL:dtPoint];
    CGPoint tileCoord   = [self tileCoordFromScreenPoint:screenCoord];
    
    _previousTileDoubleTapped = _tileDoubleTapped;
    _tileDoubleTapped         = tileCoord;
    
    [self centerPanZoomControllerOnCoordinate:tileCoord duration:1.0f rate:3.0f];
    
    [_gridLayer processDoubleTapWith:_previousTileDoubleTapped andCurrent:_tileDoubleTapped];
    
    // TODO: Move some of this to _gridLayer
    // Testing of highlighting a tile; mainly to see if we're mapping to the tilemap correctly
    if (CGPointEqualToPoint(_previousTileDoubleTapped, _tileDoubleTapped)) {
        _highlightDoubleTappedTile = !_highlightDoubleTappedTile;
    } else {
        _highlightDoubleTappedTile = YES;
    }
    
    if (_highlightDoubleTappedTile) {
        // send notification to open the UI panel
        NSDictionary *tileInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [_gameWorld descriptionForTileAt:tileCoord], TILE_DESCRIPTION,
                                  [[[_gameWorld mapGrid] objectAtIndex:tileCoord.x] objectAtIndex:tileCoord.y], TILE,
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISPLAY_TILE_INFO
                                                            object:nil
                                                          userInfo:tileInfo];
        
        // When the tile info panel is open, we need to adjust the bounds of the CCPanZoomController to show the entire map
        [self adjustTopBoundTo:0.2f];
        
    } else {
        // send notification to close the UI panel
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDE_TILE_INFO
                                                            object:nil
                                                          userInfo:nil];
        
        // When the tile info panel is closed, we need to adjust the bounds of the CCPanZoomController to close the gap
        [self adjustTopBoundTo:0.05f];
    }
    
}

- (void) centerPanZoomControllerOnCoordinate:(CGPoint)mapCoord duration:(float)duration rate:(float)rate
{
    float yPos = _mapDimensions.y - (mapCoord.y * _currentMap.tileSize.height) - (_currentMap.tileSize.height * 0.5);
    float xPos = mapCoord.x * _currentMap.tileSize.width + (_currentMap.tileSize.width * 0.5);
    
    [_panZoomController centerOnPoint:ccp(xPos,yPos) duration:duration rate:rate];
    
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (CGPoint) locationFromTouches:(NSSet *)touches
{
    return [self locationFromTouch:[touches anyObject]];
}

- (CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(HKTMXTiledMap*)tileMap
{
    CGPoint pos = ccpSub(location, tileMap.position);
    
    pos.x = (int)(pos.x/tileMap.tileSize.width);
    
    pos.y = (int)((tileMap.mapSize.height * tileMap.tileSize.height - pos.y) / tileMap.tileSize.height);
    
    return pos;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {

        _tapIsTargetingMapLayer = YES;
        
    } else {
        _tapIsTargetingMapLayer = NO;
        if ([touches count] == 2) {
            // CCLOG(@"MapLayer detects two-finger touch");
        }

    }
    
}

- (void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        _tapIsTargetingMapLayer = YES;
    } else {
        _tapIsTargetingMapLayer = NO;
        if ([touches count] == 2) {
            //CCLOG(@"Two-finger touch is moving");
        }
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {

    } else {

    }
}

-(void) update:(ccTime)delta
{
    if (_trackObject) {
        [_panZoomController centerOnPoint:_objectToTrack.position damping:0.5f];
    }
}

@end

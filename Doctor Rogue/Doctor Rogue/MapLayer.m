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

@interface MapLayer (PrivateMethods)
- (void) registerForNotifications;
- (void) setUpWithMap:(HKTMXTiledMap *)mapToUse;
- (void) drawGrid;
- (void) toggleGrid:(NSNotification *)notification;
- (void) endTouch:(NSNotification *)notification;
@end

@implementation MapLayer
@synthesize currentMap          = _currentMap;
@synthesize screenCenter        = _screenCenter;
@synthesize mapDimensions       = _mapDimensions;
@synthesize panZoomController   = _panZoomController;
@synthesize showGrid            = _showGrid;
@synthesize tapIsTargetingMapLayer = _tapIsTargetingMapLayer;

- (id) init
{
    return [self initWithMap:[HKTMXTiledMap tiledMapWithTMXFile:@"test_grasslands.tmx"]];
}

- (id) initWithMap:(HKTMXTiledMap *)map
{
    self = [super init];
    if (self) {
        
        _touchCount = 0;
        _tileDoubleTapped = ccp(0,0);
        _previousTileDoubleTapped = ccp(0,0);
        _highlightDoubleTappedTile = NO;
        
        self.touchEnabled = YES;
        self.showGrid     = YES;
        self.tapIsTargetingMapLayer = NO;
        
        [self registerForNotifications];
        
        // Randomization could be moved to setUpWithMap:
        RandomMapGenerator *rmg = [[RandomMapGenerator alloc] init];
        
        // [RandomMapGenerator randomize:] returns a HKTMXTiledMap, but since we're passing a pointer,
        // we don't need to explicitly store the return value
        [rmg randomize:map];
        
        
        // At this point, we can assume the map is randomized
        [self setUpWithMap:map];
        
    }
    return self;
}

#pragma mark onEnter and onExit
- (void) onEnter
{
    [super onEnter];
    
    // Double-tap recognizer
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_doubleTapRecognizer];
}

- (void) onExit
{
    CCLOG(@"MapLayer onExit");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_panZoomController disable];
    [self removeAllChildrenWithCleanup:YES];
    
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_doubleTapRecognizer];
    
    [super onExit];
}

#pragma mark Notification Handling
- (void) registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toggleGrid:)
                                                 name:NOTIFICATION_TOGGLE_GRID
                                               object:nil];
     }

#pragma mark Map Loading and Initialization
-(void) setUpWithMap:(HKTMXTiledMap *)mapToUse
{
    CCLOG(@"MapLayer: setUpWithMap");
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self setScreenCenter:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
    
    // TODO: Fix so that this doesn't double-retain the map and prevent it from being unloaded
    // Need to add currentMap as unsafe_unretained or something because it is automatically retained
    // when it is added as a child.
    
    [self setCurrentMap:mapToUse];
    [self addChild:_currentMap z:-1 tag:kTag_MapLayer_currentMap];
    
    // Hide layers that shouldn't be visible
    HKTMXLayer *collisions  = [_currentMap layerNamed:MAP_LAYER_COLLISIONS];
    collisions.visible      = NO;
    
    HKTMXLayer *objects     = [_currentMap layerNamed:MAP_LAYER_OBJECTS];
    objects.visible         = NO;
    
    [_currentMap setAnchorPoint:ccp(0,0)];
    
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
    
    // CGPoint centerTile = CGPointMake((int)(ms.width * 0.5), (int)(ms.height * 0.5));
    // CCLOG(@"  centerTile: %f, %f", centerTile.x, centerTile.y);
    
    CGRect boundingRect = CGRectMake(0, 0, (ms.width * ts.width), ms.height * ts.height);
    
    // the pan/zoom controller
    _panZoomController                      = [CCPanZoomController controllerWithNode:self];
    _panZoomController.boundingRect         = boundingRect;
    _panZoomController.windowRect           = CGRectMake(0, 0, screenSize.width, screenSize.height);

    _panZoomController.zoomOnDoubleTap      = NO;
    _panZoomController.centerOnPinch        = YES;
    
    [_panZoomController enableWithTouchPriority:0 swallowsTouches:NO];
    
    // TODO: Change this to center on the map entry point
    CGPoint testMapLoadPoint = ccp((ms.width * ts.width) * 0.1, (ms.height * ts.height) * 0.9);
    
    if ([[CCDirector sharedDirector] enableRetinaDisplay:YES]) {
        _panZoomController.zoomOutLimit         = MAP_ZOOM_OUT_LIMIT_RETINA;
        _panZoomController.zoomInLimit          = MAP_ZOOM_IN_LIMIT_RETINA;
        _panZoomController.zoomCenteringDamping = MAP_ZOOM_CENTERING_DAMPING_RETINA;
        _panZoomController.scrollRate           = MAP_SCROLL_RATE_RETINA;
        _panZoomController.scrollDamping        = MAP_SCROLL_DAMPING_RETINA;
        
        [_panZoomController zoomOnPoint:testMapLoadPoint duration:0 scale:0.5f];
    } else {
        
        _panZoomController.zoomOutLimit         = MAP_ZOOM_OUT_LIMIT;
        _panZoomController.zoomInLimit          = MAP_ZOOM_IN_LIMIT;
        _panZoomController.zoomCenteringDamping = MAP_ZOOM_CENTERING_DAMPING;
        _panZoomController.scrollRate           = MAP_SCROLL_RATE;
        _panZoomController.scrollDamping        = MAP_SCROLL_DAMPING;
        
        [_panZoomController centerOnPoint:testMapLoadPoint];
    }
    
    // CGPoint mapCenterPoint = ccp((ms.width * ts.width) * 0.5, (ms.height * ts.height) * 0.5);
    //[_panZoomController centerOnPoint:mapCenterPoint];

    
    // Set up the grid that we will use to refer to the tiles for gameplay purposes
    // Randomization is handled earlier.
    // [self establishMapGrid];
}

- (void) draw
{
    if (_showGrid) {
        [self drawGrid];
    }
    if (_highlightDoubleTappedTile) {
        [self highlightTile];
    }
}

#pragma mark Grid
- (void) toggleGrid:(NSNotification *)notification
{
    _showGrid = !_showGrid;
}

- (void) highlightTile
{
    glLineWidth(3 * self.scale);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccDrawColor4B(255, 255, 255, 255);
    
    HKTMXLayer *terrain = [_currentMap layerNamed:@"terrain"];
    CGPoint t = [terrain positionAt:_tileDoubleTapped];
    t.x += [_currentMap tileSize].width * 0.5;
    t.y += [_currentMap tileSize].height * 0.5;
    
    ccDrawCircle( ccp(t.x, t.y), 30, CC_DEGREES_TO_RADIANS(90), 50, NO);
}

- (void) drawGrid
{
    glLineWidth(1);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccDrawColor4B(255, 255, 255, 40);

    CGSize ts = [_currentMap tileSize];
    for (int i = 0; i < _currentMap.mapSize.width; i++) {
        ccDrawLine(ccp(i * ts.width,0), ccp(i * ts.width,_currentMap.mapSize.height * ts.height));
    }
    for (int i = 0; i < _currentMap.mapSize.height; i++) {
        ccDrawLine(ccp(0,i * ts.height), ccp(_currentMap.mapSize.width * ts.width, i * ts.height));
    }
}

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
    
    // Testing of highlighting a tile; mainly to see if we're mapping to the tilemap correctly
    if (CGPointEqualToPoint(_previousTileDoubleTapped, _tileDoubleTapped)) {
        _highlightDoubleTappedTile = !_highlightDoubleTappedTile;
    } else {
        _highlightDoubleTappedTile = YES;
    }
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
        //CCLOG(@"MapLayer tapped");
        _tapIsTargetingMapLayer = YES;
        
        /*
        CGPoint screenCoord = [self locationFromTouch:[touches anyObject]];
        CCLOG(@"ccTouchesBegan screenCoord: %@", NSStringFromCGPoint(screenCoord));
        CGPoint tileCoord   = [self tileCoordFromScreenPoint:screenCoord];
        
        _previousTileTapped = _tileTapped;
        _tileTapped         = tileCoord;
         
         */
        
        /* Debugging
        CCLOG(@"\nSelecting something at screen coord: %@", NSStringFromCGPoint(screenCoord));
        CCLOG(@"  [self position]: %@", NSStringFromCGPoint([self position]));
        CCLOG(@"  tile coordinate: %@", NSStringFromCGPoint(tileCoord));
        CCLOG(@"  map coordinate : %@", NSStringFromCGPoint([[_currentMap layerNamed:@"terrain"] positionAt:tileCoord]));
        CCLOG(@"  scale factor: %f", [self scale]);
         */
        
    } else {
        _tapIsTargetingMapLayer = NO;

    }
}

- (void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        _tapIsTargetingMapLayer = YES;
    } else {
        _tapIsTargetingMapLayer = NO;

    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        // MapLayer end touch
    } else {

    }
}

@end

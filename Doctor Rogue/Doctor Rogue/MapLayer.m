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
        
        self.touchEnabled = YES;
        self.showGrid     = YES;
        self.tapIsTargetingMapLayer = NO;
        
        [self registerForNotifications];
        
        [self setUpWithMap:map];
        
    }
    return self;
}

#pragma mark onEnter and onExit
- (void) onExit
{
    CCLOG(@"MapLayer onExit");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_panZoomController disable];
    [self removeAllChildrenWithCleanup:YES];
    
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
    
    
    // Get the number of tiles W x H
    CGSize ms = [_currentMap mapSize];
    CGSize ts = [_currentMap tileSize];
    
    _mapDimensions = ccp(ms.width * ts.width, ms.height * ts.height);
    
    CGPoint centerTile = CGPointMake((int)(ms.width * 0.5), (int)(ms.height * 0.5));
    CCLOG(@"  centerTile: %f, %f", centerTile.x, centerTile.y);
    
    CGRect boundingRect = CGRectMake(0, 0, (ms.width * ts.width), ms.height * ts.height);
    CCLOG(@"boundingRect: %@", NSStringFromCGRect(boundingRect));
    
    // the pan/zoom controller
    _panZoomController                      = [CCPanZoomController controllerWithNode:self];
    _panZoomController.boundingRect         = boundingRect;
    _panZoomController.windowRect           = CGRectMake(0, 0, screenSize.width, screenSize.height);


    _panZoomController.zoomOnDoubleTap      = NO;
    _panZoomController.centerOnPinch        = YES;
    
    
    // TODO: Balance these values.
    // Higher scrollRate is slower; default is 9
    // Default scrollDamping is 0.85f;
    
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

    
    // Set up the grid that we will use to refer to the tiles.
    // [self establishMapGrid];
}

- (void) draw
{
    if (_showGrid) {
        [self drawGrid];
    }
}

#pragma mark Grid
- (void) toggleGrid:(NSNotification *)notification
{
    _showGrid = !_showGrid;
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

#pragma mark Handling touch events

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        //CCLOG(@"MapLayer tapped");
        _tapIsTargetingMapLayer = YES;
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

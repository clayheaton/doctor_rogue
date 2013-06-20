//
//  MapEntryExitManager.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/20/13.
//

#import "MapEntryExitManager.h"
#import "Constants.h"
#import "MapLayer.h"
#import "HKTMXTiledMap.h"
#import "HKTMXLayer.h"
#import "GameWorld.h"
#import "GameObject.h"
#import "Airplane.h"
#import "CCPanZoomController.h"


@implementation MapEntryExitManager

- (id) initWithMapLayer:(MapLayer *)layer
{
    self = [super init];
    if (self) {
        _mapLayer = layer;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(planeLanded)
                                                     name:NOTIFICATION_PLANE_LANDED
                                                   object:nil];
    }
    return self;
}

// This sometimes isn't called, so call it from dealloc to make sure that we aren't registered to receive notifications.
- (void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _mapLayer = nil;
    [self removeAllChildrenWithCleanup:YES];
    
    [super onExit];
}

- (void) dealloc
{
    [self onExit];
}

#pragma mark -
#pragma mark Entering the Map

- (void) processEntry
{
    // TODO: Implement for additional cases. For now...
    
    NSString *entryType = [[[_mapLayer currentMap] properties] objectForKey:MAP_ENTRY_TYPE];
    
    // Need to land the plane
    if ([entryType isEqualToString:MAP_OUTDOOR_LOCATION_FIRST_MAP]) {
        [self insertAirplaneWithLanding:YES];
    }
    
    // CCLOG(@"Map Entry Point: %@", [[mapToUse properties] objectForKey:MAP_ENTRY_POINT]);
    // CCLOG(@"Map Entry Type : %@", [[mapToUse properties] objectForKey:MAP_ENTRY_TYPE]);
}

- (void) insertAirplaneWithLanding:(BOOL)landThePlane
{
    CGPoint entryPoint, origlandingPoint, landingPoint;
    
    origlandingPoint = [[[[_mapLayer currentMap] properties] objectForKey:MAP_ENTRY_POINT] CGPointValue];
    
    if (!landThePlane) {
        entryPoint = origlandingPoint;
    } else {
        entryPoint = ccp(rand() % (int)([_mapLayer currentMap].mapSize.width - 1), [_mapLayer currentMap].mapSize.height - 1);
    }
    
    landingPoint       = [_mapLayer positionOnTerrain:origlandingPoint];
    
    Airplane   *plane  = [Airplane planeWithEntryPoint:entryPoint];
    
    [_mapLayer setObjectToTrack:plane];
    
    [[_mapLayer gameWorld] addGameObject:plane toMapAtPoint:entryPoint usingTag:kTag_GameObject_plane andZ:1];
    
    [_mapLayer centerPanZoomControllerOnCoordinate:entryPoint duration:0 rate:0];
    
    if (landThePlane) {
        [plane landOnMap:[_mapLayer currentMap] atPoint:landingPoint];
        
        [[_mapLayer panZoomController] disable];
        _mapLayer.touchEnabled = NO;
        _mapLayer.trackObject  = YES;
    }
    
}

- (void) planeLanded
{
    CCLOG(@"Plane Landed.");
    
    _mapLayer.touchEnabled = YES;
    [[_mapLayer panZoomController] enableWithTouchPriority:0 swallowsTouches:NO];
    
    _mapLayer.trackObject   = NO;
    _mapLayer.objectToTrack = nil;
}

#pragma mark -
#pragma mark Exiting the Map

- (void) processExit
{
    
}

@end

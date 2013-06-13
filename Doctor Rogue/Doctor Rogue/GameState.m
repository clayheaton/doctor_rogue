//
//  GameState.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/28/13.
//

#import "GameState.h"
#import "AdventureLocation.h"

@implementation GameState

static GameState *gameState;

// Initializes the singleton or returns the generator
+ (GameState *) gameState
{
    if (!gameState) {
        gameState = [[GameState alloc] init];
    }
    return gameState;
}

- (id) init
{
    self = [super init];
    if (self) {
        _currentLocationNumber      = -1;
        _currentMapNumberInLocation = -1;
        _paused = YES;
    }
    return self;
}

- (NSArray *) nextMapAndLocation
{
    // This will be called by the loading scene
    // It needs to return the name of the location and the name of the map template
    
    // It is the job of the GameState singleton to keep track of the current location and map
    // However, for now, we will simply increment.
    
    _currentLocationNumber += 1;
    _currentMapNumberInLocation += 1;
    
    AdventureLocation *loc = [_adventureLocations objectAtIndex:_currentLocationNumber];
    
    NSString *locationName = [loc locationName];
    NSNumber *mapSeed   = [[loc mapSeeds] objectAtIndex:_currentMapNumberInLocation];
    
    // TODO: this should check whether the map has been created and created it if not. Or something like that.
    // If GameState is to store saved games, the AdventureLocation needs a pointer to the map or needs to store
    // actions that have altered the map so that the state can be recreated upon load.
    _activeMapTemplate  = [[loc mapTemplates] objectAtIndex:_currentMapNumberInLocation];
    
    return [NSArray arrayWithObjects:locationName, _activeMapTemplate, mapSeed, nil];
}

- (void) temporaryReset
{
    _currentMapNumberInLocation = -1;
    _currentLocationNumber = -1;
}

- (void) advanceTurn
{
    _turn += 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TURN_ADVANCED object:nil];
}

- (BOOL) mapVisited
{
    return [[[[_adventureLocations objectAtIndex:_currentLocationNumber] mapsVisited] objectAtIndex:_currentLocationNumber] boolValue];
}

- (void) markMapVisited:(BOOL)visited
{
    NSMutableArray *mapsVisited = [[_adventureLocations objectAtIndex:_currentLocationNumber] mapsVisited];
    [mapsVisited insertObject:[NSNumber numberWithBool:visited] atIndex:_currentMapNumberInLocation];
}

@end

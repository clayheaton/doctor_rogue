//
//  GameState.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/28/13.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameState : NSObject

@property (assign, readwrite) uint seed;
@property (assign, readwrite) uint turn;

@property (assign, readwrite) BOOL paused; // When the game is paused, the turns cannot progress. For use in cut scenes, etc.

@property (assign, readwrite) unsigned short numLocations;
@property (retain, readwrite) NSMutableArray *adventureLocations;

@property (assign, readwrite) unsigned short currentLocationNumber;
@property (assign, readwrite) unsigned short currentMapNumberInLocation;

@property (copy, readwrite) NSString *activeMapTemplate;

// Initialize or get the singleton gameState
+ (GameState *) gameState;

// to implement
// - (void) loadSavedState;
// - (void) reset;


// Managing map transitions -- stubbed in for now
- (NSArray *) nextMapAndLocation;

- (void) temporaryReset;

- (void) advanceTurn;

- (BOOL) mapVisited;
- (void) markMapVisited:(BOOL)visited;
@end

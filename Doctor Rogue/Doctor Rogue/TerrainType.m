//
//  TerrainType.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/30/13.
//

#import "TerrainType.h"
#import "Tile.h"

@implementation TerrainType

- (NSString *)description
{
    return [NSString stringWithFormat:@"%i: %@", self.terrainNumber, self.name];
}

- (id) init
{
    self = [super init];
    if (self) {
        _wholeBrushes          = [[NSMutableArray alloc] init];
        _threeQuarterBrushes   = [[NSMutableArray alloc] init];
        _halfBrushes           = [[NSMutableArray alloc] init];
        _quarterBrushes        = [[NSMutableArray alloc] init];
        _connections           = [[NSMutableSet alloc] init];
        _transitions           = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (Tile *) wholeBrush
{
    return [_wholeBrushes objectAtIndex:0];
}

- (NSMutableSet *)allBrushes
{
    NSMutableSet *set = [[NSMutableSet alloc] init];
    [set addObjectsFromArray:_wholeBrushes];
    [set addObjectsFromArray:_threeQuarterBrushes];
    [set addObjectsFromArray:_halfBrushes];
    [set addObjectsFromArray:_quarterBrushes];
    return set;
}

#pragma mark -
#pragma mark Establishing connections
- (void) establishConnections:(NSArray *)terrainTypes
{
    for (Tile *t in [self allBrushes]) {
        for (NSNumber *num in [t terrainTypes]) {
            TerrainType *tt = [terrainTypes objectAtIndex:[num intValue]];
            if (tt.terrainNumber == self.terrainNumber) {
                continue;
            }
            [_connections addObject:tt];
        }
    }
}

#pragma mark -
#pragma mark Establishing transitions
- (void) findTransitionsTo:(NSArray *)terrainTypes
{
    for (TerrainType *tt in terrainTypes) {
        
        // Connection to self -- add an empty array as the array member.
        if (tt.terrainNumber == self.terrainNumber) {
            NSMutableArray *ea  = [[NSMutableArray alloc] initWithCapacity:1];
            NSArray *emptyArray = [NSArray arrayWithArray:ea];
            [_transitions setObject:emptyArray forKey:[NSString stringWithFormat:@"%i", self.terrainNumber]];
            continue;
        }
        
        // There is a direct connection -- add the destination type as the array member.
        if ([_connections member:tt]) {
            [_transitions setObject:[NSArray arrayWithObject:tt] forKey:[NSString stringWithFormat:@"%i",[tt terrainNumber]]];
            continue;
        }
        NSArray    *bestPath  = nil;
        int  lowestCost = NSIntegerMax;
        
        
        for (TerrainType *connection in _connections) {
            int thisCost = -1; // Initialize to value that represents no available path.
            
            NSMutableSet *closed = [[NSMutableSet alloc] init];
            [closed removeAllObjects];
            [closed addObject:connection];
            [closed addObject:self];
            
            NSMutableArray *workingPath = [[NSMutableArray alloc] init];
            [workingPath addObject:connection];
            
            NSMutableArray *path = [self pathTo:tt
                                        through:connection
                                    workingPath:workingPath
                                      closedSet:closed];
            
            if (!path) {
                continue;
            }
            
            thisCost = [path count];

            if (thisCost != -1 && thisCost < lowestCost) {
                lowestCost = thisCost;
                bestPath = path;
            }
        }
        
        [_transitions setObject:bestPath forKey:[NSString stringWithFormat:@"%i",[tt terrainNumber]]];
    }

    /*
    //testing
    for(NSString *key in _transitions) {
        NSLog(@"transition to %@ costs %i",key, [self costOfTransitionTo:[key intValue]]);
    }
     */
}

- (NSMutableArray *)pathTo:(TerrainType *)endPoint
                   through:(TerrainType *)connection
               workingPath:(NSMutableArray *)workingPath
                 closedSet:(NSMutableSet *)closed
{
    // Direct connection through this connection
    if ([[connection connections] member:endPoint]) {
        [workingPath addObject:endPoint];
        return workingPath;
    }
    
    NSMutableArray  *bestPath  = nil;
    int  lowestCost = NSIntegerMax;
    
    for (TerrainType *tt in [connection connections]) {
        int thisCost = -1;
        if ([closed member:tt]) {
            continue;
        }
        
        [closed addObject:tt];
        [workingPath addObject:tt];
        
        NSMutableArray *path = [self pathTo:endPoint
                                    through:tt
                                workingPath:workingPath
                                  closedSet:closed];
        if (!path) {
            [workingPath removeObject:tt];
            continue;
        }
        thisCost = [path count];
        if (thisCost != -1 && thisCost < lowestCost) {
            lowestCost = thisCost;
            bestPath   = path;
        }
    }
    return bestPath;
}

- (unsigned short) costOfTransitionTo:(unsigned short)terrainNumber
{
    return [[_transitions objectForKey:[NSString stringWithFormat:@"%i", terrainNumber]] count];
}

@end

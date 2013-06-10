//
//  AdventureLocation.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/28/13.
//

#import "AdventureLocation.h"

@implementation AdventureLocation

- (id) initWithNumMaps:(unsigned short)nMaps
{
    self = [super init];
    if (self) {
        _numMaps = nMaps;
        _maps    = [[NSMutableArray alloc] initWithCapacity:_numMaps];
        
        // Generate the seeds for the maps
        NSMutableArray *seeds = [NSMutableArray arrayWithCapacity:_numMaps];
        
        for (int j = 0; j < _numMaps; j++) {
            [seeds addObject:[NSNumber numberWithInt:rand()]];
        }
        
        _mapSeeds = [NSArray arrayWithArray:seeds];
        
        seeds = nil;
        
    }
    return self;
}

- (void) prepareMapTemplatesWithTerrain:(NSString *)terrainType
{
    // TODO: Make this programmatic in the future, for now, just use strings
    // TODO: Reinstate 75x75 when RMG performance improves
    
    NSArray *availableTemplates = [NSArray arrayWithObjects:
                                   // @"75x75", 
                                   @"50x50",
                                   @"50x25",
                                   @"25x50",
                                   @"25x25",
                                   nil];
    
    NSMutableArray *tempMapTemplates = [NSMutableArray arrayWithCapacity:_numMaps];
    
    for (int i = 0; i < _numMaps; i++) {
        int randTemplate = rand() % [availableTemplates count];
        
        NSString *chosenTemplate = [NSString stringWithFormat:@"map_%@_%@.tmx", terrainType,[availableTemplates objectAtIndex:randTemplate]];
        [tempMapTemplates addObject:chosenTemplate];
    }
    
    _mapTemplates = [NSArray arrayWithArray:tempMapTemplates];

    // NSLog(@"mapTemplates: %@", _mapTemplates);
    
    tempMapTemplates = nil;

}

@end

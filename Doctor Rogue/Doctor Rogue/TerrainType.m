//
//  TerrainType.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/30/13.
//

#import "TerrainType.h"


@implementation TerrainType

- (id) init
{
    self = [super init];
    if (self) {
        _wholeBrushes          = [[NSMutableArray alloc] init];
        _threeQuarterBrushes   = [[NSMutableArray alloc] init];
        _halfBrushes           = [[NSMutableArray alloc] init];
        _quarterBrushes        = [[NSMutableArray alloc] init];
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

@end

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
        // _terrainNumber  = -1;
        _wholeBrushes   = [[NSMutableArray alloc] init];
        _halfBrushes    = [[NSMutableArray alloc] init];
        _quarterBrushes = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

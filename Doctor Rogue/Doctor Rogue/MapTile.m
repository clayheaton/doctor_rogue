//
//  MapTile.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/20/13.
//

#import "MapTile.h"

@implementation MapTile

- (id)initWithCoordinate:(CGPoint)coord
{
    self = [super init];
    if (self) {
        _mapCoord      = coord;
        _obscuredByFog = NO;
        _fogTileGID    = 0;
    }
    return self;
}

@end

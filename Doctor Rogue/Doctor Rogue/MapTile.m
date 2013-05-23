//
//  MapTile.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/20/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import "MapTile.h"

@implementation MapTile

- (id)initWithCoordinate:(CGPoint)coord
{
    self = [super init];
    if (self) {
        _mapCoord = coord;
        _obscuredByFog = NO;
    }
    return self;
}

@end

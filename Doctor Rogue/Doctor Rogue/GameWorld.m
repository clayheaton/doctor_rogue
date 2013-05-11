//
//  GameWorld.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import "GameWorld.h"


@implementation GameWorld

static GameWorld *world;

+ (GameWorld *)world
{
    if (!world) {
        world = [[GameWorld alloc] init];
    }
    return world;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        // do stuff
    }
    return self;
}

@end

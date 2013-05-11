//
//  UILayer.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//  Copyright 2013 The Perihelion Group. All rights reserved.
//

#import "UILayer.h"


@implementation UILayer

- (id)init
{
    self = [super init];
    if (self) {
        self.touchEnabled = NO; // Disabled for testing map scrolling
    }
    return self;
}

@end

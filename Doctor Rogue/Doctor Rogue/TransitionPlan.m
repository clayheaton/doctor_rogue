//
//  TransitionPlan.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/9/13.
//

#import "TransitionPlan.h"

@implementation TransitionPlan

- (id) init
{
    self = [super init];
    if (self) {
        _isInitialTile = NO;
    }
    return self;
}

@end

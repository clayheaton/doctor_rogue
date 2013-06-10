//
//  TransitionPlan.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/9/13.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface TransitionPlan : NSObject

@property (assign, readwrite) CGPoint point;
@property (assign, readwrite) CGPoint anchorPoint;
@property (assign, readwrite) CardinalDirections dirFromAnchor;
@property (assign, readwrite) CardinalDirections dirToAnchor;
@property (assign, readwrite) BOOL isInitialTile;

@end

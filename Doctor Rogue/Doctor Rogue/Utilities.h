//
//  Utilities.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/11/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@interface Utilities : CCNode {
    
}

+ (NSString *) stringForDirection:(CardinalDirections)direction;
+ (CGPoint) nextPointInDirection:(CardinalDirections)direction from:(CGPoint)pt;
+ (CardinalDirections) directionOfCoord:(CGPoint)coord relativeToCoord:(CGPoint)otherCoord;
+ (CardinalDirections) directionOpposite:(CardinalDirections)direction;

@end

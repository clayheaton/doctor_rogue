//
//  Airplane.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/14/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"
#import "Constants.h"
#import "HKTMXTiledMap.h"

@interface Airplane : GameObject {
    
}

@property (assign, readwrite) CGPoint entryPoint;
@property (assign, readwrite) CGPoint landingPoint;

+ (Airplane *) planeWithEntryPoint:(CGPoint)entry;

- (void) landOnMap:(HKTMXTiledMap *)map atPoint:(CGPoint)landingPoint;

@end

//
//  GridLayer.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/12/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GridLayer : CCNode {
    
}

@property (assign, readwrite) CGSize mapSize;
@property (assign, readwrite) CGSize tileSize;
@property (assign, readwrite) BOOL   showGrid;

@property (assign, readwrite) CGPoint previousTileDoubleTapped;
@property (assign, readwrite) CGPoint tileDoubleTapped;
@property (assign, readwrite) BOOL    highlightDoubleTappedTile;

- (void)processDoubleTapWith:(CGPoint)previous andCurrent:(CGPoint)current;

@end

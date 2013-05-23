//
//  MapTile.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/20/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapTile : NSObject


@property (assign, readwrite)    unsigned int terrainTileGID;
@property (assign, readwrite)    unsigned int fogTileGID;
@property (assign, readwrite)    CGPoint mapCoord;
@property (nonatomic, readwrite) NSString *tileDescString;

@property (assign, readonly) BOOL obscuredByFog;

- (id)initWithCoordinate:(CGPoint)coord;

@end

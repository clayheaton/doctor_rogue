//
//  Airplane.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 6/14/13.
//

#import "Airplane.h"


@implementation Airplane

- (id) init
{
    self = [super init];
    if (self) {
        CCSprite   *planeSprite = [CCSprite spriteWithFile:@"hawker_hart.png"];
        planeSprite.anchorPoint = ccp(0.5,0.75);
        [self setPrimarySprite:planeSprite];
        [self addChild:planeSprite z:1 tag:kTag_GameObject_plane];
        
        self.revealsMapThroughFog = YES;
        self.name = @"Airplane"; // TODO: Add to localization
    }
    return self;
}

- (void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super onExit];
}

+ (Airplane *) planeWithEntryPoint:(CGPoint)entry
{
    Airplane *plane = [Airplane node];
    plane.entryPoint = entry;
    return plane;
}

- (CGPoint)positionOnTerrain:(CGPoint)tileCoordinate usingMap:(HKTMXTiledMap *)map
{
    HKTMXLayer *terrain = [map layerNamed:@"objects"];
    return [terrain positionAt:tileCoordinate];
}

- (void) landOnMap:(HKTMXTiledMap *)map atPoint:(CGPoint)landingPoint
{
    // Exhaust Smoke
    CCParticleSystemQuad *exhaust = [CCParticleSystemQuad particleWithFile:@"AirplaneExhaust.plist"];
    exhaust.position = ccp(0.5,0.5);//ccp(underlayer.contentSize.width/2,underlayer.contentSize.height/2);
    exhaust.visible = YES;
    [self addChild:exhaust z:-1 tag:kTag_GameObject_plane_smoke];
    
    // Find the proper angle to the landing point and rotate the plane to face it
    // Cocos2d has some funky trig. This link helped sort it out.
    // http://www.pavley.com/2011/11/28/cocos2d-iphone-sprite-rotation-to-an-arbitrary-point/
    
    CGPoint difference      = ccpSub([self positionOnTerrain:_entryPoint usingMap:map], landingPoint);
    CGFloat rotationRadians = ccpToAngle(difference);
    CGFloat rotationDegrees = -CC_RADIANS_TO_DEGREES(rotationRadians);
    rotationDegrees         -= 90.0f;
    
    self.rotation          = rotationDegrees;
    self.scale             = 2.5f;
    
    float distance          = sqrtf(difference.x*difference.x + difference.y * difference.y);
    float standard          = 75 * map.tileSize.height;
    float factor            = distance / standard;
    float time              = 10 * factor;
    
    id actionMove           = [CCMoveTo    actionWithDuration:time position:landingPoint];
    id actionRotate         = [CCRotateTo  actionWithDuration:0.5f angle:0];
    id actionScale          = [CCScaleTo   actionWithDuration:time scale:1.0f];
    id actionStopExhaust    = [CCCallFuncN actionWithTarget:self   selector:@selector(stopExhaust)];
    id actionMoveDone       = [CCCallFuncN actionWithTarget:self   selector:@selector(planeMoveComplete)];
    [self runAction:[CCSequence actions:actionMove, actionStopExhaust, actionRotate, actionMoveDone, nil]];
    [self runAction:actionScale];
}

- (void) stopExhaust
{
    CCParticleSystemQuad *smoke =  (CCParticleSystemQuad *)[self getChildByTag:kTag_GameObject_plane_smoke];
    [smoke stopSystem];
}

- (void) planeMoveComplete
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLANE_LANDED object:nil];
}

@end

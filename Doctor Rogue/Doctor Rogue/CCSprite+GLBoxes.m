//
//  CCSprite+GLBoxes.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/22/13.
//

#import "CCSprite+GLBoxes.h"

@implementation CCSprite (GLBoxes)

+ (CCSprite *) rectangleOfSize:(CGSize)size
                       withRed:(uint8_t)red
                         green:(uint8_t)green
                          blue:(uint8_t)blue
                      andAlpha:(uint8_t)alpha
{
    // http://www.cocos2d-iphone.org/forum/topic/31512
    
    CCSprite *sprite = [CCSprite node];
    
    GLubyte *buffer = (GLubyte *) malloc(sizeof(GLubyte)*4);

    buffer[0] = red;
    buffer[1] = green;
    buffer[2] = blue;
    buffer[3] = alpha;
    
    CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_Default pixelsWide:1 pixelsHigh:1 contentSize:size];
    
    [sprite setTexture:tex];
    
    [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
    
    free(buffer);
    
    return sprite;
}

@end

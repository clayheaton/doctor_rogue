//
//  CCSprite+GLBoxes.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/22/13.
//

#import "CCSprite.h"

@interface CCSprite (GLBoxes)

// If you want a black/white/red/whatever colored box without using an external texture
// Good for UI panels

+ (CCSprite *) rectangleOfSize:(CGSize)size
                       withRed:(uint8_t)red
                         green:(uint8_t)green
                          blue:(uint8_t)blue
                      andAlpha:(uint8_t)alpha;

@end

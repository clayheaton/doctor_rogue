//
//  NSString+UnicodeUtilities.h
//  Toddler Taxonomist
//
//  Created by Clay Heaton on 4/30/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UnicodeUtilities)

+ (NSString*) unescapeUnicodeString:(NSString*)string;
+ (NSString*) escapeUnicodeString:(NSString*)string;

@end

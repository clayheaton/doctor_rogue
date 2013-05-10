//
//  NSString+UnicodeUtilities.h
//  Doctor Rogue
//

#import <Foundation/Foundation.h>

@interface NSString (UnicodeUtilities)

+ (NSString*) unescapeUnicodeString:(NSString*)string;
+ (NSString*) escapeUnicodeString:(NSString*)string;

@end

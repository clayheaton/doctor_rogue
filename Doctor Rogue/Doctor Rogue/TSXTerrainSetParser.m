//
//  TSXTerrainSetParser.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import "TSXTerrainSetParser.h"

@implementation TSXTerrainSetParser

+ (NSDictionary *) parseTileset:(NSString *)tileset
{
    
    NSArray *fileNameComponents = [tileset componentsSeparatedByString:@"."];
    
    NSString *tilesetFilePath = [[NSBundle mainBundle] pathForResource:[fileNameComponents objectAtIndex:0]
                                                                ofType:[fileNameComponents objectAtIndex:1]];
    
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:tilesetFilePath];
    
    NSError *error;
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (doc == nil) {
        NSAssert(doc != nil, @"Tileset was not parsed properly.");
        return nil;
    }
    
    // Getting the name of the tileset
    NSArray *tilesetElements = [[doc rootElement] elementsForName:@"tileset"];
    GDataXMLElement *firstTileset = (GDataXMLElement *)[tilesetElements objectAtIndex:0];
    NSString *tilesetName = [firstTileset valueForKey:@"source"];
    
    NSLog(@"Parsed Tileset root element: %@", tilesetName);
    doc = nil;
    
    return nil;
}

@end

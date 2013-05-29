//
//  TSXTerrainSetParser.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface TSXTerrainSetParser : NSObject


// Return a dictionary that has tile GIDs as the keys -- there should be an entry for each GID
// Each dictionary object is another dictionary that has 4 keys: north, east, south, west
// Each of those dictionaries contains a set of tiles that match the GID tile in that direction.

// For example, if a tile is looking for a match to its east:
//  1. Look up the GID of the seeking tile as a key in the dictionary
//  2. Look up east as a key in the returned dictionary
//  3. Grab a tile out of the set that is returned. If the set is nil, there is no matching tile. (shouldn't happen).

+ (NSDictionary *) parseTileset:(NSString *)tileset;

@end

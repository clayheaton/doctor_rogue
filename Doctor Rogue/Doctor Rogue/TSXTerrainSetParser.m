//
//  TSXTerrainSetParser.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import "TSXTerrainSetParser.h"
#import "Constants.h"
#import "TerrainTile.h"
#import "TerrainTilePositioned.h"

@implementation TSXTerrainSetParser

+ (NSDictionary *) parseTileset:(NSString *)tileset
{
    NSMutableDictionary *tileDictionary  = [[NSMutableDictionary alloc] init];
    
    NSString            *tilesetFilePath = [[NSBundle mainBundle] pathForResource:tileset ofType:@"tsx"];
    NSData              *xmlData         = [[NSMutableData alloc] initWithContentsOfFile:tilesetFilePath];
    
    NSError *error;
    
    // There's a bit of a tutorial for GDataXMLDocuments here:
    // http://www.raywenderlich.com/725/how-to-read-and-write-xml-documents-with-gdataxml
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    NSAssert(doc != nil, @"Tileset was not parsed properly.");
    
    ///////////////////////////////////////////////////////////////////////////////////
    // Getting the names of the terrain types in the tile set
    ///////////////////////////////////////////////////////////////////////////////////
    
    NSArray *terrainTypes  = [doc nodesForXPath:@"//terraintypes/terrain" error:nil];
    if (error) {
        NSLog(@"Error: %@", error.domain);
        NSAssert(error != nil, @"There was an error parsing the terrain types from the .tsx file.");
    }
    
    NSMutableArray *orderedTerrainTypes = [[NSMutableArray alloc] initWithCapacity:[terrainTypes count]];
    
    // Extract the string value for the name of the terrain types
    for (int i = 0; i < terrainTypes.count; i++) {
        GDataXMLElement *type = (GDataXMLElement *)[terrainTypes objectAtIndex:i];
        [orderedTerrainTypes addObject:[[[type attributes] objectAtIndex:0] stringValue]];
    }
    
    [tileDictionary setObject:[NSArray arrayWithArray:orderedTerrainTypes] forKey:TERRAIN_DICT_TERRAINS];
    
    orderedTerrainTypes = nil;
    terrainTypes        = nil;
    
    ///////////////////////////////////////////////////////////////////////////////////
    // Getting the tiles out of the tile set
    ///////////////////////////////////////////////////////////////////////////////////
    
    /* Note: in the .tsx files, you'll see the individual tiles listed as:
     
     <tile id="0" terrain="1,1,1,0">
        <properties>
            <property name="terrain_type" value="medium_grass_border_light_grass"/>
        </properties>
     </tile>
     
     The values of terrain="1,1,1,0" are what we are interested in at this point, as we create tiles.
     The numbers correspond to the terrain type that matches each corner of the tile. For example,
     terrain type 0 is grass_light and terrain type 1 is grass_medium. 
     
     The order of the corners is terrain="NW,NE,SW,SE". This tile has grass_medium in the SW,NW, and NE
     corners and grass_light in the SE corner.
     
     At this point, we only are concerned about the terrain values, since the properties aren't really used
     in the random map generation (yet).
     
     */
    
    NSArray *theTiles = [doc nodesForXPath:@"//tile" error:nil];
    
    NSMutableArray *positionedTiles = [[NSMutableArray alloc] initWithCapacity:[theTiles count] * 4];
    
    for (int i = 0; i < theTiles.count; i++) {
        GDataXMLElement *tile          = (GDataXMLElement *)[theTiles objectAtIndex:i];
        
        // Not all tiles will be tagged as part of terrain; skip those with no terrain information
        // This catches them because they only have one element in their attributes array (missing the terrain element)
        if (tile.attributes.count < 2) {
            continue;
        }
        
        // Dealing with terrain tiles
        unsigned int    tileGID        = (unsigned int)[(NSString *)[[[tile attributes] objectAtIndex:0] stringValue] intValue]; // There's probaby a more efficient way to do this, but this works.
        tileGID += 1; // 0 is blank
        NSArray         *cornerMarkers = [(NSString *)[[[tile attributes] objectAtIndex:1] stringValue] componentsSeparatedByString:@","];

        TerrainTile *t = [[TerrainTile alloc] init];
        [t setTileGID:tileGID];
        
        [t setCornerNWTarget:[[cornerMarkers objectAtIndex:0] unsignedIntValue]];
        [t setCornerNETarget:[[cornerMarkers objectAtIndex:1] unsignedIntValue]];
        [t setCornerSWTarget:[[cornerMarkers objectAtIndex:2] unsignedIntValue]];
        [t setCornerSETarget:[[cornerMarkers objectAtIndex:3] unsignedIntValue]];
        
        TerrainTilePositioned *tp1 = [[TerrainTilePositioned alloc] initWithTerrainTile:t andRotation:TerrainTileRotation_0];
        
        // Current tile set does not support rotated tiles.
        
        // TerrainTilePositioned *tp2 = [[TerrainTilePositioned alloc] initWithTerrainTile:t andRotation:TerrainTileRotation_90];
        // TerrainTilePositioned *tp3 = [[TerrainTilePositioned alloc] initWithTerrainTile:t andRotation:TerrainTileRotation_180];
        // TerrainTilePositioned *tp4 = [[TerrainTilePositioned alloc] initWithTerrainTile:t andRotation:TerrainTileRotation_270];
        
        // Put all possible tile positions into a large array - will will iterate through them after creating the dictionary,
        // to set the allowed neighbor tiles
        [positionedTiles addObject:tp1];
        
        // These can be used if we have a tileset that supports rotated tiles. We don't have that at the moment.
        
        // [positionedTiles addObject:tp2];
        // [positionedTiles addObject:tp3];
        // [positionedTiles addObject:tp4];
        
        // You'll be able to reference the positioned tiles in the array using TerrainTileRotation_x as the index
        [tileDictionary setObject:[NSArray arrayWithObject:tp1] forKey:[NSString stringWithFormat:@"%i", tileGID]];
        
        // HOWEVER!!  The current tile set has directional tiles. They should not be rotated.
        
    }
    
    // Now that we have possible tile positions set in the dictionary, we will build the list of allowed neighbors for each position
    // by iterating through the array created in the loop above and the keys in the dictionary.
    
    for (NSString *key in tileDictionary) {
        if ([key isEqualToString:TERRAIN_DICT_TERRAINS]) {
            continue;
        }
        
        // For each key, we have to process all four members of the array
        NSArray *tileArray = [tileDictionary objectForKey:key];
        
        for (TerrainTilePositioned *tp in tileArray) {
            [tp assignNeighborsFrom:positionedTiles];
        }
        
    }
    
    doc = nil;
    
    return tileDictionary;
}

@end

//
//  TSXTerrainSetParser.m
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/29/13.
//

#import "TSXTerrainSetParser.h"
#import "Constants.h"
#import "TerrainType.h"
#import "Tile.h"

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
    NSMutableDictionary *terrainsByName = [[NSMutableDictionary alloc] initWithCapacity:[terrainTypes count]];
    
    // Extract the string value for the name of the terrain types
    for (int i = 0; i < terrainTypes.count; i++) {
        GDataXMLElement *type = (GDataXMLElement *)[terrainTypes objectAtIndex:i];
        
        // We use the TerrainType class here so that we can use its arrays as buckets
        // for tiles, to support 'brush' painting of the terrain
        
        TerrainType *terType = [[TerrainType alloc] init];
        [terType setTerrainNumber:i];
        NSString *terName = [[[type attributes] objectAtIndex:0] stringValue];
        [terType setName:terName];
        
        [terrainsByName      setObject:terType forKey:terName];
        [orderedTerrainTypes addObject:terType];
    }
    
    // You can extract these from the array using the number of the terrain as the index or by name from the nested dictionary
    [tileDictionary setObject:[NSArray arrayWithArray:orderedTerrainTypes] forKey:TERRAIN_DICT_TERRAINS_BY_NUMBER];
    [tileDictionary setObject:[NSDictionary dictionaryWithDictionary:terrainsByName] forKey:TERRAIN_DICT_TERRAINS_BY_NAME];
    
    terrainsByName      = nil;
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
    
    NSMutableArray *processedTiles = [[NSMutableArray alloc] initWithCapacity:[theTiles count]];
    
    BOOL findDefault   = YES;
    
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
        
        Tile *t = [[Tile alloc] init];
        [t setTileGID:tileGID];
        
        [t setCornerNWTarget:[[cornerMarkers objectAtIndex:0] intValue]];
        [t setCornerNETarget:[[cornerMarkers objectAtIndex:1] intValue]];
        [t setCornerSWTarget:[[cornerMarkers objectAtIndex:2] intValue]];
        [t setCornerSETarget:[[cornerMarkers objectAtIndex:3] intValue]];

        [processedTiles addObject:t];
        
        // NSLog(@"signature: %@", [t signatureAsString]);
        
        // Set it in the main dictionary at a key == tileGID
        [tileDictionary setObject:t forKey:[NSString stringWithFormat:@"%i", tileGID]];
        
        // Determine if this is the default tile type for the tileset.
        // It can be used to fill the _workingMap in the RandomMapGenerator
        if (findDefault) {
            NSArray *properties = [[[tile children] objectAtIndex:0] children];
            for (GDataXMLElement *property in properties) {
                if ([[[property attributeForName:@"name"] stringValue] isEqualToString:@"default_tile"]) {
                    if ([[[property attributeForName:@"value"] stringValue] isEqualToString:@"YES"]) {
                        [tileDictionary setObject:t forKey:TERRAIN_DICT_DEFAULT];
                        findDefault   = NO;
                        break;
                    }
                }
            }
        }

    }
    
    // Add a set of all of the tiles to the dictionary
    [tileDictionary setObject:[NSSet setWithArray:processedTiles] forKey:TERRAIN_DICT_ALL_TILES_SET];
    
    // Add the tiles as brushes to the terrain types
    for (Tile *t in processedTiles) {
        
        NSSet *terrains = [t terrainTypes];
        for (NSNumber *num in terrains) {
            TerrainType *terType = [[tileDictionary objectForKey:TERRAIN_DICT_TERRAINS_BY_NUMBER] objectAtIndex:[num unsignedShortValue]];
            switch (t.terrainTypes.count) {
                case 1:
                {
                    if (![[terType wholeBrushes] containsObject:t]) {
                        [[terType wholeBrushes]  addObject:t];
                    }
                    break;
                }
                    
                case 2:
                {
                    // Determine whether it is quarter or three quarter for this terrain type
                    if ([t cornersWithTerrainType:terType] == 3) {
                        // Three quarter brush
                        if (![[terType threeQuarterBrushes] containsObject:t]) {
                            [[terType threeQuarterBrushes]  addObject:t];
                        }
                    } else if ([t cornersWithTerrainType:terType] == 2) {
                        // Half brush
                        if (![[terType halfBrushes] containsObject:t]) {
                            [[terType halfBrushes]  addObject:t];
                        }
                    } else if ([t cornersWithTerrainType:terType] == 1) {
                        // Quarter brush
                        if (![[terType quarterBrushes] containsObject:t]) {
                            [[terType quarterBrushes]  addObject:t];
                        }
                    }

                    break;
                }
                    
                default:
                    break;
            }
        }
    }
    
    
    // Now that we have possible tiles set in the dictionary, we will build the list of allowed neighbors for each 
    // by iterating through the array created in the loop above and the keys in the dictionary.
    
    for (Tile *t in [tileDictionary objectForKey:TERRAIN_DICT_ALL_TILES_SET]) {
        [t assignNeighborsFrom:processedTiles];
    }
    
    doc = nil;
    
    return tileDictionary;
}

@end

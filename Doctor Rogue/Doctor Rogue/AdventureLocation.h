//
//  AdventureLocation.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/28/13.
//

//  The game is divided into locations, with each location having several maps.
//  This class is a container for each location. When playing, there will be an
//  Active AdventureLocation that will be used for managing the movement between
//  maps. For each new adventure, the AdventureLocations are determined at the
//  beginning of the game, in GameStartGenerator. They are stored in an array
//  in GameStartGenerator (for now).

//  We will generate maps when needed. Therefore, each AdventureLocation stores
//  an array of mapSeeds that are generated at the beginning of the game.

#import <Foundation/Foundation.h>

@interface AdventureLocation : NSObject

@property (copy, readwrite)      NSString       *locationName;
@property (nonatomic, readwrite) NSArray        *mapTemplates;
@property (nonatomic, readwrite) NSArray        *mapSeeds;

@property (assign, readwrite)    unsigned short numMaps;
@property (nonatomic, readwrite) NSMutableArray *maps;

- (id) initWithNumMaps:(unsigned short)nMaps;
- (void) prepareMapTemplatesWithTerrain:(NSString *)terrainType;

@end

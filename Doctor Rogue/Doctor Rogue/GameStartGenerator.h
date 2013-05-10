//
//  GameStartGenerator.h
//  IndyTest
//
//  Created by Clay Heaton on 4/3/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CaseTypeDescriptorObject = 0,
    CaseTypeType,
    CaseTypeObjectType,
    QuestionTypeMAX
} CaseType;

@interface GameStartGenerator : NSObject

@property (copy, readwrite) NSString *placeName;

// Storing the parts of the artifact; will be used to look up properties in a dictionary later
// Done like this to support light partial initialization of the game (player can elect to
// regenerate the starting name/artifact prior to initializing the entire game
@property (copy, readwrite) NSString *artifactObject;
@property (copy, readwrite) NSString *artifactType;
@property (copy, readwrite) NSString *artifactDescriptor;
@property (copy, readwrite) NSString *artifactFullName;
@property (copy, readwrite) NSString *gameTitle;
@property (assign, readwrite) uint seed;

+ (GameStartGenerator *) generator;
+ (GameStartGenerator *) generatorWithSeed:(uint)seed;
- (id) initWithSeed:(uint)seed;

- (void) makeNewAdventureWithSeed:(uint)newSeed;
- (void) makeNewAdventure;

- (void) prepareGame;

- (NSString *)generatePlaceName;
- (NSString *)generateCultureName;
- (NSString *)generateDietyName;
- (NSString *)generateTotemName;
- (NSString *)generateTitleAndArtifact;

@end

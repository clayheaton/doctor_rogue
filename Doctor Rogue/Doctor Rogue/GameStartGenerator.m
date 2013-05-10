//
//  GameStartGenerator.m
//  IndyTest
//
//  Created by Clay Heaton on 4/3/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import "GameStartGenerator.h"
#import "parseCSV.h"

@implementation GameStartGenerator

static GameStartGenerator *generator;

// Initializes the singleton or returns the generator
+ (GameStartGenerator *) generator
{
    return [GameStartGenerator generatorWithSeed:arc4random()];
}

// Used to initialize with a specific seed - probably not needed
+ (GameStartGenerator *) generatorWithSeed:(uint)seed
{
    if (!generator) {
        generator = [[GameStartGenerator alloc] initWithSeed:seed];
    }
    return generator;
}

// Used for initial generation
- (id) initWithSeed:(uint)seed
{
    self = [super init];
    if (self) {
        srand(seed);
        _seed = seed;
    }
    return self;
}

- (void) makeNewAdventureWithSeed:(uint)newSeed
{
    srand(newSeed);
    [self prepareGame];
}

- (void) makeNewAdventure
{
    srand(arc4random());
    [self prepareGame];
}

- (void) prepareGame
{
    _placeName        = [self generatePlaceName];
    _artifactFullName = [self generateTitleAndArtifact];
}

- (NSString *)generatePlaceName
{
    CSVParser *parser      = [CSVParser new];
    NSString  *csvFilePath = [[NSBundle mainBundle] pathForResource:@"place_names" ofType:@"csv"];
    
    [parser openFile:csvFilePath];
    
    NSArray *content = [parser parseFile];
    
    [parser closeFile];
    parser = nil;
    
    NSMutableArray *prefixes = [[NSMutableArray alloc] initWithCapacity:[content count]];
    NSMutableArray *midfixes = [[NSMutableArray alloc] initWithCapacity:[content count]];
    NSMutableArray *suffixes = [[NSMutableArray alloc] initWithCapacity:[content count]];
    
    // Start at 1 to miss the header row...
    for (int i = 1; i < [content count]; i++) {
        
        NSArray *thisRow = [content objectAtIndex:i];
        // [content objectAtIndex:i] is an array with the values
        // from that row in the CSV file
        
        // Prefixes
        if (![(NSString *)[thisRow objectAtIndex:0] isEqualToString:@""]) {
            [prefixes addObject:[thisRow objectAtIndex:0]];
        }
        
        // Midfixes
        if (![(NSString *)[thisRow objectAtIndex:1] isEqualToString:@""]) {
            [midfixes addObject:[thisRow objectAtIndex:1]];
        }
        
        // Suffixes
        if (![(NSString *)[thisRow objectAtIndex:2] isEqualToString:@""]) {
            [suffixes addObject:[thisRow objectAtIndex:2]];
        }
        
    }

    int prefixIndex = rand() % [prefixes count];
    int midfixIndex = rand() % [midfixes count];
    int suffixIndex = rand() % [suffixes count];
    
    NSString *placeName = [NSString stringWithFormat:@"%@%@%@",
                           [prefixes objectAtIndex:prefixIndex],
                           [midfixes objectAtIndex:midfixIndex],
                           [suffixes objectAtIndex:suffixIndex]];
    
    // NSLog(@"Place Name: %@", [placeName capitalizedString]);
    return [placeName capitalizedString];

}

- (NSString *)generateCultureName
{
    
}

- (NSString *)generateDietyName
{
    
}

- (NSString *)generateTotemName
{
    
}

- (NSString *)generateTitleAndArtifact
{
    
    CSVParser *parser      = [CSVParser new];
    NSString  *csvFilePath = [[NSBundle mainBundle] pathForResource:@"artifact_parts" ofType:@"csv"];
    
    [parser openFile:csvFilePath];
    
    NSArray *content = [parser parseFile];
    
    [parser closeFile];
    parser = nil;
    
    NSMutableArray *objects     = [[NSMutableArray alloc] initWithCapacity:[content count]];
    NSMutableArray *descriptors = [[NSMutableArray alloc] initWithCapacity:[content count]];
    NSMutableArray *types       = [[NSMutableArray alloc] initWithCapacity:[content count]];
    NSMutableArray *caseNames   = [[NSMutableArray alloc] initWithCapacity:[content count]];
    NSMutableArray *caseTypes   = [[NSMutableArray alloc] initWithCapacity:[content count]];
    
    // Start at 1 to miss the header row...
    for (int i = 1; i < [content count]; i++) {
        
        NSArray *thisRow = [content objectAtIndex:i];
        // [content objectAtIndex:i] is an array with the values
        // from that row in the CSV file
        
        // Descriptors
        if (![(NSString *)[thisRow objectAtIndex:0] isEqualToString:@""]) {
            [descriptors addObject:[thisRow objectAtIndex:0]];
        }
        
        // Objects
        if (![(NSString *)[thisRow objectAtIndex:1] isEqualToString:@""]) {
            [objects addObject:[thisRow objectAtIndex:1]];
        }
        
        // Types
        if (![(NSString *)[thisRow objectAtIndex:2] isEqualToString:@""]) {
            [types addObject:[thisRow objectAtIndex:2]];
        }
        
        // Case Names
        if (![(NSString *)[thisRow objectAtIndex:3] isEqualToString:@""]) {
            [caseNames addObject:[thisRow objectAtIndex:3]];
        }
        
        // Case Types: inserted as NSNumber (string converted to int) for use in a switch
        if (![(NSString *)[thisRow objectAtIndex:4] isEqualToString:@""]) {
            [caseTypes addObject:[NSNumber numberWithInt:[(NSString *)[thisRow objectAtIndex:4] intValue]]];
        }
    }
    
    // objects, descriptors, and types

    int objectIndex     = rand() % [objects count];
    int descriptorIndex = rand() % [descriptors count];
    int typeIndex       = rand() % [types count];
    
    _artifactObject     = [objects objectAtIndex:objectIndex];
    _artifactDescriptor = [descriptors objectAtIndex:descriptorIndex];
    _artifactType       = [types objectAtIndex:typeIndex];
    
    // Handle the case and the game title
    int caseIndex       = rand() % [caseNames count];
    
    NSString *caseName  = [caseNames objectAtIndex:caseIndex];
    
    switch ([[caseTypes objectAtIndex:caseIndex] intValue]) {
        case CaseTypeDescriptorObject:
            // The Case of the Golden Sword
            _gameTitle = [NSString stringWithFormat:@"%@ of the\n%@ %@", caseName, [_artifactDescriptor uppercaseString], [_artifactObject uppercaseString]];
            break;
            
        case CaseTypeType:
            // The Society of Doom
            _gameTitle = [NSString stringWithFormat:@"%@ of\n%@", caseName, [_artifactType uppercaseString]];
            break;
            
        case CaseTypeObjectType:
            // The Missing Hammer of Invisibility
            _gameTitle = [NSString stringWithFormat:@"%@ %@ of\n %@", caseName, [_artifactObject uppercaseString], [_artifactType uppercaseString]];
            break;
            
        default:
            // use CaseTypeDescriptorObject
            _gameTitle = [NSString stringWithFormat:@"%@ of the\n%@ %@", caseName, [_artifactDescriptor uppercaseString], [_artifactObject uppercaseString]];
            break;
    }
    
    // NSLog(@"_gameTitle: %@", _gameTitle);
    
    return [NSString stringWithFormat:@"%@ %@ of %@", _artifactDescriptor, _artifactObject, _artifactType];

}

@end

//
//  GameStartGenerator.m


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

// Called by MainMenuLayer when user enters a seed
- (void) makeNewAdventureWithSeed:(uint)newSeed
{
    srand(newSeed);
    [self prepareGame];
}

// Called by MainMenuLayer when user creates another random adventure
- (void) makeNewAdventure
{
    srand(arc4random());
    [self prepareGame];
}

- (void) prepareGame
{
    _placeName        = [self generatePlaceName];
    _artifactFullName = [self generateArtifact];
    _gameTitle        = [self generateGameTitle];
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

- (NSString *)generateArtifact
{
    // Item Descriptors
    CSVParser *parser      = [CSVParser new];
    NSString  *csvFilePath = [[NSBundle mainBundle] pathForResource:@"item_descriptors" ofType:@"csv"];
    [parser openFile:csvFilePath];
    NSArray *item_descriptors_content = [parser parseFile];
    [parser closeFile];
    parser = nil;
    
    // Item Objects
    parser = [CSVParser new];
    csvFilePath = [[NSBundle mainBundle] pathForResource:@"item_objects" ofType:@"csv"];
    [parser openFile:csvFilePath];
    NSArray *item_objects_content = [parser parseFile];
    [parser closeFile];
    parser = nil;
    
    // Item Types
    parser = [CSVParser new];
    csvFilePath = [[NSBundle mainBundle] pathForResource:@"item_types" ofType:@"csv"];
    [parser openFile:csvFilePath];
    NSArray *item_types_content = [parser parseFile];
    [parser closeFile];
    parser = nil;
    
    
    NSMutableArray *itemObjects     = [[NSMutableArray alloc] initWithCapacity:[item_objects_content count]];
    NSMutableArray *itemDescriptors = [[NSMutableArray alloc] initWithCapacity:[item_descriptors_content count]];
    NSMutableArray *itemTypes       = [[NSMutableArray alloc] initWithCapacity:[item_types_content count]];
    
    // Item Objects
    for (int i = 1; i < [item_objects_content count]; i++) {
        NSArray *thisRow = [item_objects_content objectAtIndex:i];
        if (![(NSString *)[thisRow objectAtIndex:0] isEqualToString:@""] &&
             [(NSString *)[thisRow objectAtIndex:1] isEqualToString:@"TRUE"]) { // Check that it's eligible to be an artifact
            
            [itemObjects addObject:[thisRow objectAtIndex:0]];
        }
    }
    
    // Item Descriptors
    for (int i = 1; i < [item_descriptors_content count]; i++) {
        NSArray *thisRow = [item_descriptors_content objectAtIndex:i];
        if (![(NSString *)[thisRow objectAtIndex:0] isEqualToString:@""] &&
             [(NSString *)[thisRow objectAtIndex:1] isEqualToString:@"TRUE"]) { // Check that it's eligible to be an artifact
            
            [itemDescriptors addObject:[thisRow objectAtIndex:0]];
        }
    }
    
    // Item Types
    for (int i = 1; i < [item_types_content count]; i++) {
        NSArray *thisRow = [item_types_content objectAtIndex:i];
        if (![(NSString *)[thisRow objectAtIndex:0] isEqualToString:@""] &&
             [(NSString *)[thisRow objectAtIndex:1] isEqualToString:@"TRUE"]) { // Check that it's eligible to be an artifact
            
            [itemTypes addObject:[thisRow objectAtIndex:0]];
        }
    }
    
    // objects, descriptors, and types

    int objectIndex     = rand() % [itemObjects count];
    int descriptorIndex = rand() % [itemDescriptors count];
    int typeIndex       = rand() % [itemTypes count];
    
    _artifactObject     = [itemObjects     objectAtIndex:objectIndex];
    _artifactDescriptor = [itemDescriptors objectAtIndex:descriptorIndex];
    _artifactType       = [itemTypes       objectAtIndex:typeIndex];
    
    itemObjects     = nil;
    itemDescriptors = nil;
    itemTypes       = nil;
    
    return [NSString stringWithFormat:@"%@ %@ of %@", _artifactDescriptor, _artifactObject, _artifactType];

}

- (NSString *) generateGameTitle
{
    // Cases
    CSVParser *parser = [CSVParser new];
    NSString *csvFilePath = [[NSBundle mainBundle] pathForResource:@"case_types" ofType:@"csv"];
    [parser openFile:csvFilePath];
    NSArray *case_types_content = [parser parseFile];
    [parser closeFile];
    parser = nil;
    
    NSMutableArray *caseNames       = [[NSMutableArray alloc] initWithCapacity:[case_types_content count]];
    NSMutableArray *caseTypes       = [[NSMutableArray alloc] initWithCapacity:[case_types_content count]];
    
    // Case Names & Types
    for (int i = 1; i < [case_types_content count]; i++) {
        NSArray *thisRow = [case_types_content objectAtIndex:i];
        if (![(NSString *)[thisRow objectAtIndex:0] isEqualToString:@""] &&
            ![(NSString *)[thisRow objectAtIndex:1] isEqualToString:@""]) { // Check that it has an assigned type
            
            [caseNames addObject:[thisRow objectAtIndex:0]];
            [caseTypes addObject:[NSNumber numberWithInt:[(NSString *)[thisRow objectAtIndex:1] intValue]]];
        }
    }
    
    // Handle the case and the game title
    int caseIndex       = rand() % [caseNames count];
    NSString *caseName  = [caseNames objectAtIndex:caseIndex];
    
    NSString *answer;
    
    switch ([[caseTypes objectAtIndex:caseIndex] intValue]) {
        case CaseTypeDescriptorObject:
            // The Case of the Golden Sword
            answer = [NSString stringWithFormat:@"%@ of the\n%@ %@", caseName, [_artifactDescriptor uppercaseString], [_artifactObject uppercaseString]];
            break;
            
        case CaseTypeType:
            // The Society of Doom
            answer = [NSString stringWithFormat:@"%@ of\n%@", caseName, [_artifactType uppercaseString]];
            break;
            
        case CaseTypeObjectType:
            // The Missing Hammer of Invisibility
            answer = [NSString stringWithFormat:@"%@ %@ of\n %@", caseName, [_artifactObject uppercaseString], [_artifactType uppercaseString]];
            break;
            
        default:
            // use CaseTypeDescriptorObject
            answer = [NSString stringWithFormat:@"%@ of the\n%@ %@", caseName, [_artifactDescriptor uppercaseString], [_artifactObject uppercaseString]];
            break;
    }
    return answer;
}

// TODO: Implement these
- (NSString *)generateCultureName
{
    
}

- (NSString *)generateDietyName
{
    
}

- (NSString *)generateTotemName
{
    
}

@end

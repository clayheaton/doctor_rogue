//
//  Constants.h
//  Doctor Rogue
//
//  Created by Clay Heaton on 5/10/13.
//  
//

/*
#ifndef Doctor_Rogue_Constants_h
#define Doctor_Rogue_Constants_h
#endif
*/

#define NOTIFICATION_TOGGLE_GRID          @"toggle_grid"
#define NOTIFICATION_TOUCH_ENDED          @"CCPanZoom Touch Ended"
#define NOTIFICATION_DISPLAY_TILE_INFO    @"Display tile info"
#define NOTIFICATION_HIDE_TILE_INFO       @"Hide tile info"
#define NOTIFICATION_MAP_GENERATOR_UPDATE @"MapGeneratorUpdate"
#define NOTIFICATION_LOADING_UPDATE       @"MapGeneratorUpdate"
#define NOTIFICATION_TURN_ADVANCED        @"TurnAdvanced"

#define MAP_LAYER_TERRAIN               @"terrain"
#define MAP_LAYER_OBJECTS               @"objects"
#define MAP_LAYER_COLLISIONS            @"collisions"
#define MAP_LAYER_FOG                   @"fog_of_war"

#define MAP_LAYER_TERRAIN_Z             0
#define MAP_LAYER_GRID_Z                1
#define MAP_LAYER_SPRITES_Z             2
#define MAP_LAYER_OBJECTS_Z             3
#define MAP_LAYER_COLLISIONS_Z          4
#define MAP_LAYER_FOG_Z                 5

#define GAME_WORLD_TILE                 @"GameWorldTile"

#define MAP_OUTDOOR_LOCATION_FIRST_MAP  @"outdoorLocationFirstMap"

#define MAP_ENTRY_TYPE                  @"mapEntryType"
#define MAP_ENTRY_POINT                 @"mapEntryPoint"
#define MAP_ENTRY_DIRECTION             @"mapEntryDirection"

#define FOG_BLACK                       @"fog_black"
#define FOG_GREY                        @"fog_grey"

#define TILE                            @"tile"
#define TILE_DESCRIPTION                @"tile_description"

#define MAP_PREFIX_GRASSLANDS           @"grasslands"

// Terrain Dictionary
#define TERRAIN_DICT_TERRAINS_BY_NUMBER           @"TerrainsOrderedByNumber"
#define TERRAIN_DICT_TERRAINS_BY_NAME             @"TerrainsByName"
#define TERRAIN_DICT_DEFAULT                      @"DefaultTerrain"
#define TERRAIN_DICT_ALL_TILES_SET                @"AllTilesSet"

// Higher scrollRate is slower; default is 9
// Default scrollDamping is 0.85f;

#define MAP_ZOOM_OUT_LIMIT                  0.5f
#define MAP_ZOOM_OUT_LIMIT_RETINA           0.25f
#define MAP_ZOOM_IN_LIMIT                   1.0f
#define MAP_ZOOM_IN_LIMIT_RETINA            0.5f
#define MAP_ZOOM_CENTERING_DAMPING          0.8f
#define MAP_ZOOM_CENTERING_DAMPING_RETINA   0.1f
#define MAP_SCROLL_RATE                     15
#define MAP_SCROLL_RATE_RETINA              25
#define MAP_SCROLL_DAMPING                  0.95f
#define MAP_SCROLL_DAMPING_RETINA           0.5f



typedef enum
{
    CaseTypeDescriptorObject = 0,
    CaseTypeType,
    CaseTypeObjectType,
    QuestionTypeMAX
} CaseType;

// kTag_Parent_Child
typedef enum {
    kTagMIN = 0,
    
    kTag_LoadingScene_mapUpdate,
    kTag_LoadingScene_loadingHelper,
    kTag_LoadingScene_plane,
    
    kTag_MainGameScene_mapLayer,
    kTag_MainGameScene_uiLayer,
    kTag_MainGameScene_underlayer,
    kTag_MainGameScene_chasmwind,
    
    kTag_Map_spriteLayer,           // faux layer inserted between tmx layers, for displaying sprites
    kTag_Map_gridLayer,
    kTag_Map_gridLayer_highlightTile,
    
    kTag_MapLayer_currentMap,
    
    kTag_GameObject_plane,
    kTag_GameObject_plane_smoke,
    
    kTag_UILayer_tempQuitButton,
    kTag_UILayer_toggleGridButton,
    kTag_UILayer_tileInfoBar,
    kTag_UILayer_tileInfoBarTileDescription,
    kTag_UILayer_topInfoBar,
    
    kTagMAX
} ChildTags;

typedef enum
{
	LoadingTargetScene_INVALID = 0,
	LoadingTargetScene_MainMenuScene,
	LoadingTargetScene_MainGameScene,
	LoadingTargetSceneMAX,
} LoadingTargetScenes;

typedef enum
{
	TileMovement_Never,
    TileMovement_Floating,
    TileMovement_Always
} TileMovementStatus;

typedef enum
{
	TerrainTileRotation_0,
    TerrainTileRotation_90,
    TerrainTileRotation_180,
    TerrainTileRotation_270
} TerrainTileRotation;

typedef enum
{
	TerrainTileSide_North,
    TerrainTileSide_East,
    TerrainTileSide_South,
    TerrainTileSide_West
} TerrainTileSide;


// This maps to the array positions
// and may be useful for enumeration
typedef enum
{
	TileCorner_NW = 0,
    TileCorner_NE = 1,
    TileCorner_SW = 2,
    TileCorner_SE = 3,
    TileCorner_MAX
} TerrainTileCorners;

typedef enum
{
	TerrainBrush_Quarter,
    TerrainBrush_Half,
    TerrainBrush_ThreeQuarter,
    TerrainBrush_Whole
} TerrainBrushTypes;

typedef enum
{
	North = 0,
    East  = 1,
    South = 2,
    West  = 3,
    Northwest = 4,
    Northeast = 5,
    Southwest = 6,
    Southeast = 7,
    InvalidDirection = 8
} CardinalDirections;

typedef enum
{
	PrimaryDirections,
    SecondaryDirections,
    AllDirections
} DirctionType;

typedef enum
{
	EdgeCase_None,
    EdgeCase_1,
    EdgeCase_2,
    EdgeCase_3,
    EdgeCase_4,
    EdgeCase_5,
    EdgeCase_6,
    EdgeCase_MAX
} EdgeCaseType;

typedef enum
{
	FogofWar_TileVisible, // in LoS for player
    FogofWar_TileVisited, // previously in LoS for player
    FogofWar_TileBlack    // Never seen or visited.
} FogOfWarStatus;
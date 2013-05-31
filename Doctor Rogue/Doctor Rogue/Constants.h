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

#define NOTIFICATION_TOGGLE_GRID        @"toggle_grid"
#define NOTIFICATION_TOUCH_ENDED        @"CCPanZoom Touch Ended"
#define NOTIFICATION_DISPLAY_TILE_INFO  @"Display tile info"
#define NOTIFICATION_HIDE_TILE_INFO     @"Hide tile info"

#define MAP_LAYER_TERRAIN               @"terrain"
#define MAP_LAYER_OBJECTS               @"objects"
#define MAP_LAYER_COLLISIONS            @"collisions"
#define MAP_LAYER_FOG                   @"fog_of_war"

#define FOG_BLACK                       @"fog_black"
#define FOG_GREY                        @"fog_grey"

#define TILE                            @"tile"
#define TILE_DESCRIPTION                @"tile_description"

#define MAP_PREFIX_GRASSLANDS           @"grasslands"

// Terrain Dictionary
#define TERRAIN_DICT_TERRAINS           @"TerrainsOrderedByName"

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
    kTag_MainGameScene_mapLayer,
    kTag_MainGameScene_uiLayer,
    kTag_MainGameScene_underlayer,
    kTag_MainGameScene_chasmwind,
    kTag_MapLayer_currentMap,
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

typedef enum
{
	TerrainTile_NWCorner = 0,
    TerrainTile_NECorner = 1,
    TerrainTile_SWCorner = 2,
    TerrainTile_SECorner = 3
} TerrainTileCorners;

typedef enum
{
	TerrainBrush_Quarter,
    TerrainBrush_Half,
    TerrainBrush_Whole
} TerrainBrushTypes;

typedef enum
{
	North,
    East,
    South,
    West,
    Northwest,
    Northeast,
    Southwest,
    Southeast
} CardinalDirections;

typedef enum
{
	FogofWar_TileVisible, // in LoS for player
    FogofWar_TileVisited, // previously in LoS for player
    FogofWar_TileBlack    // Never seen or visited.
} FogOfWarStatus;
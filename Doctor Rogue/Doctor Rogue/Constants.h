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

#define NOTIFICATION_TOGGLE_GRID    @"toggle_grid"
#define NOTIFICATION_TOUCH_ENDED    @"CCPanZoom Touch Ended"

#define MAP_LAYER_TERRAIN           @"terrain"
#define MAP_LAYER_OBJECTS           @"objects"
#define MAP_LAYER_COLLISIONS        @"collisions"

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

// kTag_Parent_Child
typedef enum {
    kTagMIN = 0,
    // TODO: the first two are improperly capitalized
    kTag_MainGameScene_MapLayer,
    kTag_MainGameScene_UILayer,
    kTag_MapLayer_currentMap,
    kTag_UILayer_tempQuitButton,
    kTag_UILayer_toggleGridButton,
    kTagMAX
} ChildTags;

typedef enum
{
	LoadingTargetScene_INVALID = 0,
	LoadingTargetScene_MainMenuScene,
	LoadingTargetScene_MainGameScene,
	LoadingTargetSceneMAX,
} LoadingTargetScenes;
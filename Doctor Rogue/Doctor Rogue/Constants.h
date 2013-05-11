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

// kTag_Parent_Child
typedef enum {
    kTagMIN = 0,
    // TODO: the first two are improperly capitalized
    kTag_MainGameScene_MapLayer,
    kTag_MainGameScene_UILayer,
    kTag_MapLayer_currentMap,
    kTagMAX
} ChildTags;

typedef enum
{
	LoadingTargetScene_INVALID = 0,
	LoadingTargetScene_MainMenuScene,
	LoadingTargetScene_MainGameScene,
	LoadingTargetSceneMAX,
} LoadingTargetScenes;
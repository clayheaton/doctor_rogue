//
//  LoadingScene.h
//  FieldHospital
//
//  Created by Clay Heaton on 4/26/12.
//  Copyright 2012 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@interface LoadingScene : CCScene {
    LoadingTargetScenes targetScene_;
}

@property (retain, readwrite) NSDictionary *infoDict;
@property (retain, readwrite) NSArray      *locationInfo;

+(id) sceneWithTargetScene:(LoadingTargetScenes)targetScene;
-(id) initWithTargetScene:(LoadingTargetScenes)targetScene;

@end

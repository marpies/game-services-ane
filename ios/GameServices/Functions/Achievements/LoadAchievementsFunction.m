/**
 * Copyright 2017 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "LoadAchievementsFunction.h"
#import <GameKit/GameKit.h>
#import "GameServices.h"
#import "GameServicesEvent.h"
#import "GKAchievementUtils.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>

FREObject gserv_loadAchievements( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [GameServices log:@"gserv_loadAchievements"];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray<GKAchievement *> * _Nullable achievements, NSError * _Nullable error) {
        if( error != nil ) {
            [GameServices log:[NSString stringWithFormat:@"Error loading achievements: %@", error.localizedDescription]];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_LOAD_ERROR withMessage:error.localizedDescription];
        } else if( achievements != nil ) {
            [GameServices log:@"Successfully loaded achievements"];
            NSMutableDictionary* response = [NSMutableDictionary dictionary];
            response[@"achievements"] = [GKAchievementUtils toJSON:achievements];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_LOAD_SUCCESS withMessage:[MPStringUtils getJSONString:response]];
        } else {
            // surely won't happen
            [GameServices log:@"Failed to load achievements, but no error reported."];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_LOAD_ERROR withMessage:@"Failed to load achievements, but no error reported."];
        }
    }];
    return nil;
}

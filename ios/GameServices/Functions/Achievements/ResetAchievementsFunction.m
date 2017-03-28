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

#import "ResetAchievementsFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import <GameKit/GameKit.h>
#import "GameServices.h"
#import "GameServicesEvent.h"

FREObject gserv_resetAchievements( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [GameServices log:@"gserv_resetAchievements"];
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError * _Nullable error) {
        if( error == nil ) {
            [GameServices log:@"Achievements reset successfully"];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_RESET_SUCCESS];
        } else {
            [GameServices log:[NSString stringWithFormat:@"Error reseting achievements: %@", error.localizedDescription]];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_RESET_ERROR withMessage:error.localizedDescription];
        }
    }];
    return nil;
}

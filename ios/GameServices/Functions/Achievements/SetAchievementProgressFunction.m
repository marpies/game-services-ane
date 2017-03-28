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

#import "SetAchievementProgressFunction.h"
#import "GameServices.h"
#import "GameServicesEvent.h"
#import "GameServicesDelegate.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>

FREObject gserv_setAchievementProgress( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [GameServices log:@"gserv_setAchievementProgress"];
    NSString* achievementId = [MPFREObjectUtils getNSString:argv[0]];
    double progress = [MPFREObjectUtils getDouble:argv[1]];
    gserv_setAchievementProgressInternal( achievementId, progress );
    return nil;
}

void gserv_setAchievementProgressInternal( NSString* achievementId, double progress ) {
    GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    achievement.showsCompletionBanner = [[GameServicesDelegate sharedInstance] showAchievementBanner];
    achievement.percentComplete = progress;
    gserv_reportAchievementsInternal( @[achievement] );
}

void gserv_reportAchievementsInternal( NSArray<GKAchievement*>* achievements ) {
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError * _Nullable error) {
        if( error == nil ) {
            [GameServices log:@"Successfully updated achievement(s) progress"];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_UPDATE_SUCCESS];
        } else {
            [GameServices log:[NSString stringWithFormat:@"Error reporting an achievement: %@", error.localizedDescription]];
            [GameServices dispatchEvent:GS_ACHIEVEMENT_UPDATE_ERROR withMessage:error.localizedDescription];
        }
    }];
}

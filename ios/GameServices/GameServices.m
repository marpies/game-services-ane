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

#import "GameServices.h"
#import "Functions/InitFunction.h"
#import "Functions/AuthenticateFunction.h"
#import "Functions/IsSupportedFunction.h"
#import "Functions/IsAuthenticatedFunction.h"
#import "Functions/SignOutFunction.h"
#import "Functions/Achievements/UnlockAchievementFunction.h"
#import "Functions/Achievements/SetAchievementStepsFunction.h"
#import "Functions/Achievements/SetAchievementProgressFunction.h"
#import "Functions/Achievements/IncrementAchievementFunction.h"
#import "Functions/Achievements/ShowAchievementBannerFunction.h"
#import "Functions/Achievements/LoadAchievementsFunction.h"
#import "Functions/Achievements/ShowAchievementsUIFunction.h"
#import "Functions/Achievements/ReportAchievementsFunction.h"
#import "Functions/Achievements/ResetAchievementsFunction.h"
#import "Functions/Achievements/RevealAchievement.h"
#import "Functions/Leaderboards/ReportScoreFunction.h"
#import "Functions/Leaderboards/ShowLeaderboardsUIFunction.h"

static BOOL AIRGameServicesLogEnabled = NO;
FREContext AIRGameServicesExtContext = nil;

@implementation GameServices

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void) dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( AIRGameServicesExtContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void) log:(const NSString*) message {
    if( AIRGameServicesLogEnabled ) {
        NSLog( @"[iOS-GameServices] %@", message );
    }
}

+ (void) showLogs:(BOOL) showLogs {
    AIRGameServicesLogEnabled = showLogs;
}

@end

/**
 *
 *
 * Context initialization
 *
 *
 **/

FRENamedFunction GameServices_extFunctions[] = {
    { (const uint8_t*) "init",                   0, gserv_init },
    { (const uint8_t*) "auth",                   0, gserv_auth },
    { (const uint8_t*) "isSupported",            0, gserv_isSupported },
    { (const uint8_t*) "isAuthenticated",        0, gserv_isAuthenticated },
    { (const uint8_t*) "signOut",                0, gserv_signOut },
    /* Achievements */
    { (const uint8_t*) "unlockAchievement",      0, gserv_unlockAchievement },
    { (const uint8_t*) "setAchievementSteps",    0, gserv_setAchievementSteps },
    { (const uint8_t*) "incrementAchievement",   0, gserv_incrementAchievement },
    { (const uint8_t*) "setAchievementProgress", 0, gserv_setAchievementProgress },
    { (const uint8_t*) "showAchievementBanner",  0, gserv_showAchievementBanner },
    { (const uint8_t*) "loadAchievements",       0, gserv_loadAchievements },
    { (const uint8_t*) "showAchievementsUI",     0, gserv_showAchievementsUI },
    { (const uint8_t*) "reportAchievements",     0, gserv_reportAchievements },
    { (const uint8_t*) "resetAchievements",      0, gserv_resetAchievements },
    { (const uint8_t*) "revealAchievement",      0, gserv_revealAchievement },
    /* Leaderboards */
    { (const uint8_t*) "reportScore",            0, gserv_reportScore },
    { (const uint8_t*) "showLeaderboardsUI",     0, gserv_showLeaderboardsUI }
};

void GameServicesContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet ) {
    *numFunctionsToSet = sizeof( GameServices_extFunctions ) / sizeof( FRENamedFunction );
    
    *functionsToSet = GameServices_extFunctions;
    
    AIRGameServicesExtContext = ctx;
}

void GameServicesContextFinalizer( FREContext ctx ) { }

void GameServicesInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &GameServicesContextInitializer;
    *ctxFinalizerToSet = &GameServicesContextFinalizer;
}

void GameServicesFinalizer( void* extData ) { }








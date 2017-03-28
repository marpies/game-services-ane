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

#import "ReportAchievementsFunction.h"
#import "SetAchievementProgressFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "GameServices.h"

double getObjectPropertyAsDouble( FREObject object, const uint8_t* propName ) {
    FREObject propValue;
    if( FREGetObjectProperty( object, propName, &propValue, NULL ) == FRE_OK ) {
        return [MPFREObjectUtils getDouble:propValue];
    }
    return 0.0;
}

NSString* getObjectPropertyAsString( FREObject object, const uint8_t* propName ) {
    FREObject propValue;
    if( FREGetObjectProperty( object, propName, &propValue, NULL ) == FRE_OK ) {
        return [MPFREObjectUtils getNSString:propValue];
    }
    return nil;
}

NSArray<GKAchievement*>* getAchievementsFromFREObject( FREObject achievementsArray ) {
    uint32_t arrayLength;
    FREGetArrayLength( achievementsArray, &arrayLength );
    
    NSMutableArray<GKAchievement*>* result = [NSMutableArray arrayWithCapacity:arrayLength];
    for( uint32_t i = 0; i < arrayLength; i++ ) {
        FREObject itemRaw;
        FREGetArrayElementAt( achievementsArray, i, &itemRaw );
        NSString* achievementId = getObjectPropertyAsString( itemRaw, (const uint8_t*) "id" );
        if( achievementId != nil ) {
            GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
            achievement.percentComplete = getObjectPropertyAsDouble( itemRaw, (const uint8_t*) "progress" );
            [result addObject:achievement];
        }
    }

    return result;
}

FREObject gserv_reportAchievements( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    FREObject achievementsArray = argv[0];
    [GameServices log:@"gserv_reportAchievements"];
    gserv_reportAchievementsInternal( getAchievementsFromFREObject( achievementsArray ) );
    return nil;
}

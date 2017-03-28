/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
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

#import "ReportScoreFunction.h"
#import "GameServices.h"
#import "GameServicesEvent.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <GameKit/GameKit.h>

FREObject gserv_reportScore( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [GameServices log:@"gserv_reportScore"];
    
    NSString* leaderboardId = [MPFREObjectUtils getNSString:argv[0]];
    double scoreValue = [MPFREObjectUtils getDouble:argv[1]];
    
    GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardId];
    [score setValue:scoreValue];
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError * _Nullable error) {
        if( error == nil ) {
            [GameServices log:[NSString stringWithFormat:@"Successfully reported score: %@", score]];
            [GameServices dispatchEvent:GS_REPORT_SCORE_SUCCESS];
        } else {
            [GameServices log:[NSString stringWithFormat:@"Error reporting score: %@", error.localizedDescription]];
            [GameServices dispatchEvent:GS_REPORT_SCORE_ERROR withMessage:error.localizedDescription];
        }
    }];
    
    return nil;
}

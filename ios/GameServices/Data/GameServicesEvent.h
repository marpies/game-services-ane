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

#ifndef GameServicesEvent_h
#define GameServicesEvent_h

#import <Foundation/Foundation.h>

static NSString* const GS_WILL_PRESENT_AUTH_DIALOG = @"willPresentAuthDialog";
static NSString* const GS_AUTH_SUCCESS = @"authSuccess";
static NSString* const GS_AUTH_ERROR = @"authError";

static NSString* const GS_IDENTITY_SUCCESS = @"identitySuccess";
static NSString* const GS_IDENTITY_ERROR = @"identityError";

static NSString* const GS_ACHIEVEMENT_UPDATE_SUCCESS = @"achievementUpdateSuccess";
static NSString* const GS_ACHIEVEMENT_UPDATE_ERROR = @"achievementUpdateError";

static NSString* const GS_ACHIEVEMENT_LOAD_SUCCESS = @"achievementLoadSuccess";
static NSString* const GS_ACHIEVEMENT_LOAD_ERROR = @"achievementLoadError";

static NSString* const GS_ACHIEVEMENT_UI_SHOW = @"achievementsUIShow";
static NSString* const GS_ACHIEVEMENT_UI_HIDE = @"achievementsUIHide";

static NSString* const GS_LEADERBOARDS_UI_SHOW = @"leaderboardsUIShow";
static NSString* const GS_LEADERBOARDS_UI_HIDE = @"leaderboardsUIHide";

static NSString* const GS_ACHIEVEMENT_RESET_SUCCESS = @"achievementResetSuccess";
static NSString* const GS_ACHIEVEMENT_RESET_ERROR = @"achievementResetError";

static NSString* const GS_REPORT_SCORE_SUCCESS = @"reportScoreSuccess";
static NSString* const GS_REPORT_SCORE_ERROR = @"reportScoreError";

#endif /* GameServicesEvent_h */

/*
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

package com.marpies.ane.gameservices.events;

public class GameServicesEvent {

	public static final String WILL_PRESENT_AUTH_DIALOG = "willPresentAuthDialog";
	public static final String AUTH_SUCCESS = "authSuccess";
	public static final String AUTH_ERROR = "authError";

	public static final String ACHIEVEMENT_UPDATE_SUCCESS = "achievementUpdateSuccess";
	public static final String ACHIEVEMENT_UPDATE_ERROR = "achievementUpdateError";

	public static final String ACHIEVEMENT_LOAD_SUCCESS = "achievementLoadSuccess";
	public static final String ACHIEVEMENT_LOAD_ERROR = "achievementLoadError";

	public static final String ACHIEVEMENT_UI_SHOW = "achievementsUIShow";
	public static final String ACHIEVEMENT_UI_ERROR = "achievementsUIError";
	public static final String ACHIEVEMENT_UI_HIDE = "achievementsUIHide";

    public static final String LEADERBOARDS_UI_SHOW = "leaderboardsUIShow";
    public static final String LEADERBOARDS_UI_ERROR = "leaderboardsUIError";
    public static final String LEADERBOARDS_UI_HIDE = "leaderboardsUIHide";

	public static final String ACHIEVEMENT_RESET_SUCCESS = "achievementResetSuccess";
	public static final String ACHIEVEMENT_RESET_ERROR = "achievementResetError";

    public static final String REPORT_SCORE_SUCCESS = "reportScoreSuccess";
    public static final String REPORT_SCORE_ERROR = "reportScoreError";

}

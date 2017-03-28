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

package com.marpies.ane.gameservices;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.marpies.ane.gameservices.functions.*;
import com.marpies.ane.gameservices.functions.achievements.*;
import com.marpies.ane.gameservices.functions.leaderboards.ReportScoreFunction;
import com.marpies.ane.gameservices.functions.leaderboards.ShowLeaderboardsUIFunction;
import com.marpies.ane.gameservices.utils.AIR;
import com.marpies.ane.gameservices.functions.IsSupportedFunction;

import java.util.HashMap;
import java.util.Map;

public class GameServicesExtensionContext extends FREContext {

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();

		functions.put( "init", new InitFunction() );
		functions.put( "auth", new AuthenticateFunction() );
		functions.put( "isSupported", new IsSupportedFunction() );
		functions.put( "isAuthenticated", new IsAuthenticatedFunction() );
		functions.put( "signOut", new SignOutFunction() );

		/* Achievements */
		functions.put( "unlockAchievement", new UnlockAchievementFunction() );
		functions.put( "setAchievementSteps", new SetAchievementStepsFunction() );
		functions.put( "incrementAchievement", new IncrementAchievementFunction() );
		functions.put( "setAchievementProgress", new SetAchievementProgressFunction() );
		functions.put( "showAchievementBanner", new ShowAchievementBannerFunction() );
		functions.put( "loadAchievements", new LoadAchievementsFunction() );
		functions.put( "showAchievementsUI", new ShowAchievementsUIFunction() );
		functions.put( "reportAchievements", new ReportAchievementsFunction() );
		functions.put( "resetAchievements", new ResetAchievementsFunction() );
		functions.put( "revealAchievement", new RevealAchievementFunction() );

        /* Leaderboards */
        functions.put( "reportScore", new ReportScoreFunction() );
        functions.put( "showLeaderboardsUI", new ShowLeaderboardsUIFunction() );

		return functions;
	}

	@Override
	public void dispose() {
		AIR.setContext( null );
	}
}

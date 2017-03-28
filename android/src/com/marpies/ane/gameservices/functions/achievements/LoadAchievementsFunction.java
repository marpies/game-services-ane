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

package com.marpies.ane.gameservices.functions.achievements;

import android.support.annotation.NonNull;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.achievement.Achievements;
import com.marpies.ane.gameservices.events.GameServicesEvent;
import com.marpies.ane.gameservices.functions.BaseFunction;
import com.marpies.ane.gameservices.utils.AIR;
import com.marpies.ane.gameservices.utils.GSAchievementUtils;
import com.marpies.ane.gameservices.utils.GameServicesHelper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.TimeUnit;

public class LoadAchievementsFunction extends BaseFunction implements ResultCallback<Achievements.LoadAchievementsResult> {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.log( "GameServices::loadAchievements" );

		if( GameServicesHelper.getInstance().isAuthenticated() ) {
			PendingResult<Achievements.LoadAchievementsResult> result = Games.Achievements.load( GameServicesHelper.getInstance().getClient(), false );
			result.setResultCallback( this, 10, TimeUnit.SECONDS );
		} else {
			AIR.log( "User is not signed in." );
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_LOAD_ERROR, "User is not signed in." );
		}

		return null;
	}

	@Override
	public void onResult( @NonNull Achievements.LoadAchievementsResult result ) {
		com.google.android.gms.common.api.Status status = result.getStatus();

		if( !status.isSuccess() ) {
			result.release();
			AIR.log( "Failed to load achievements: " + status.getStatusMessage() );
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_LOAD_ERROR, status.getStatusMessage() );
			return;
		}

		JSONArray achievementsArray = GSAchievementUtils.toJSONArray( result.getAchievements() );
		result.release();
		JSONObject response = new JSONObject();
		try {
			response.put( "achievements", achievementsArray );
			AIR.log( "Successfully loaded achievements" );
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_LOAD_SUCCESS, response.toString() );
		} catch( JSONException e ) {
			e.printStackTrace();
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_LOAD_ERROR, e.getMessage() );
		}
	}
}


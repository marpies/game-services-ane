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

package com.marpies.ane.gameservices.utils;

import com.google.android.gms.games.achievement.Achievement;
import com.google.android.gms.games.achievement.AchievementBuffer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class GSAchievementUtils {

	public static JSONArray toJSONArray( AchievementBuffer buffer ) {
		JSONArray result = new JSONArray();
		int bufSize = buffer.getCount();
		for( int i = 0; i < bufSize; i++ ) {
			Achievement achievement = buffer.get( i );
			JSONObject json = new JSONObject();
			try {
				json.put( "id", achievement.getAchievementId() );
				float progress = 0.0f;
				/* Is unlocked */
				if( achievement.getState() == Achievement.STATE_UNLOCKED ) {
					progress = 100.0f;
				}
				/* Is incremental */
				if( achievement.getType() == Achievement.TYPE_INCREMENTAL ) {
					int steps = achievement.getCurrentSteps();
					int totalSteps = achievement.getTotalSteps();
					json.put( "steps", steps );
					json.put( "totalSteps", totalSteps );
					if( progress < 0.001 ) {
						/* Calc progress from the steps */
						progress = ((float) steps / (float) totalSteps) * 100.0f;
					}
				}
				json.put( "progress", progress );
				result.put( json.toString() );
			} catch( JSONException e ) {
				e.printStackTrace();
			}
		}
		buffer.release();
		return result;
	}

}

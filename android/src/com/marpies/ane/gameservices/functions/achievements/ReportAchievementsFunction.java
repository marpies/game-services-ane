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

import com.adobe.fre.*;
import com.google.android.gms.games.Games;
import com.marpies.ane.gameservices.events.GameServicesEvent;
import com.marpies.ane.gameservices.functions.BaseFunction;
import com.marpies.ane.gameservices.utils.AIR;
import com.marpies.ane.gameservices.utils.FREObjectUtils;
import com.marpies.ane.gameservices.utils.GameServicesHelper;

import java.util.ArrayList;
import java.util.List;

public class ReportAchievementsFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.log( "GameServices::reportAchievements" );
		FREArray achievementsArray = (FREArray) args[0];

		GameServicesHelper helper = GameServicesHelper.getInstance();
		if( helper.isAuthenticated() ) {
			List<GSAchievement> achievements = getAchievementsFromFREArray( achievementsArray );
			for( GSAchievement achievement : achievements ) {
				Games.Achievements.setSteps( helper.getClient(), achievement.getId(), achievement.getStep() );
			}
			AIR.log( "Successfully set steps for achievements: " + achievements.toString() );
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_UPDATE_SUCCESS );
		} else {
			helper.dispatchAchievementUpdateError();
		}

		return null;
	}

	private List<GSAchievement> getAchievementsFromFREArray( FREArray achievementsArray ) {
		List<GSAchievement> result = new ArrayList<GSAchievement>();
		try {
			long length = achievementsArray.getLength();
			for( long i = 0; i < length; i++ ) {
				try {
					GSAchievement achievement = new GSAchievement();
					FREObject freAchievement = achievementsArray.getObjectAt( i );
					achievement.setId( FREObjectUtils.getString( freAchievement.getProperty( "id" ) ) );
					achievement.setStep( FREObjectUtils.getInt( freAchievement.getProperty( "steps" ) ) );
					result.add( achievement );
				} catch( Exception e ) {
					e.printStackTrace();
				}
			}
		} catch( FREInvalidObjectException e ) {
			e.printStackTrace();
		} catch( FREWrongThreadException e ) {
			e.printStackTrace();
		}
		return result;
	}

	private class GSAchievement {

		private String mId;
		private int mStep;

		GSAchievement() {
			mStep = 0;
		}

		public String toString() {
			return "{GSAchievement id: " + mId + " step: " + mStep + "}";
		}

		String getId() {
			return mId;
		}

		void setId( String id ) {
			mId = id;
		}

		int getStep() {
			return mStep;
		}

		void setStep( int step ) {
			mStep = step;
		}

	}

}



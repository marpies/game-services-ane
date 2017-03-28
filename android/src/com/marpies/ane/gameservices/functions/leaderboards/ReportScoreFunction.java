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

package com.marpies.ane.gameservices.functions.leaderboards;

import android.support.annotation.NonNull;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.leaderboard.Leaderboards;
import com.marpies.ane.gameservices.events.GameServicesEvent;
import com.marpies.ane.gameservices.functions.BaseFunction;
import com.marpies.ane.gameservices.utils.AIR;
import com.marpies.ane.gameservices.utils.FREObjectUtils;
import com.marpies.ane.gameservices.utils.GameServicesHelper;

import java.util.concurrent.TimeUnit;

public class ReportScoreFunction extends BaseFunction implements ResultCallback<Leaderboards.SubmitScoreResult> {

    @Override
    public FREObject call(FREContext context, FREObject[] args) {
        super.call(context, args);

        AIR.log( "GameServices::reportScore" );

        String leaderboardId = FREObjectUtils.getString( args[0] );
        double scoreValue = FREObjectUtils.getDouble( args[1] );
        boolean immediate = FREObjectUtils.getBoolean( args[2] );

        GameServicesHelper helper = GameServicesHelper.getInstance();
        if( helper.isAuthenticated() ) {
            if( immediate ) {
                PendingResult<Leaderboards.SubmitScoreResult> result = Games.Leaderboards.submitScoreImmediate( helper.getClient(), leaderboardId, (long) scoreValue );
                result.setResultCallback( this, 10, TimeUnit.SECONDS );
                return null;
            }

            Games.Leaderboards.submitScore( GameServicesHelper.getInstance().getClient(), leaderboardId, (long) scoreValue );
            AIR.log( "Successfully submitted score to leaderboard: " + leaderboardId );
            AIR.dispatchEvent( GameServicesEvent.REPORT_SCORE_SUCCESS );
        } else {
            AIR.log( "Cannot report score, user is not signed in." );
            AIR.dispatchEvent( GameServicesEvent.REPORT_SCORE_ERROR, "Cannot report score, user is not signed in." );
        }

        return null;
    }

    @Override
    public void onResult( @NonNull Leaderboards.SubmitScoreResult result ) {
        com.google.android.gms.common.api.Status status = result.getStatus();

        if( !status.isSuccess() ) {
            AIR.log( "Failed to submit score: " + status.getStatusMessage() );
            AIR.dispatchEvent( GameServicesEvent.REPORT_SCORE_ERROR, status.getStatusMessage() );
            return;
        }

        result.release();

        AIR.log( "Successfully submitted score" );
        AIR.dispatchEvent( GameServicesEvent.REPORT_SCORE_SUCCESS );
    }
}


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

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.IAIRGSActivityResultCallback;
import com.adobe.air.IAIRGSActivityStateCallback;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesActivityResultCodes;
import com.google.android.gms.games.Player;
import com.marpies.ane.gameservices.events.GameServicesEvent;
import org.json.JSONObject;

public class GameServicesHelper implements
        IAIRGSActivityStateCallback, IAIRGSActivityResultCallback,
        GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

	private static final int AUTH_RESULT_CODE = 9283;
	private static final int ACHIEVEMENTS_UI_RESULT_CODE = 3948;
	private static final int LEADERBOARDS_UI_RESULT_CODE = 4820;
	private static GameServicesHelper mInstance = new GameServicesHelper();

	private GoogleApiClient mGoogleApiClient;
	private boolean mUserAuth;
	private boolean mPendingAchievementsUI;
	private boolean mPendingLeaderboardsUI;
	private String mPendingLeaderboardId;
	private ConnectionResult mPendingConnectionResult;

	private GameServicesHelper() {
	}

	public static GameServicesHelper getInstance() {
		return mInstance;
	}

	public static boolean checkPlayServices( Context context ) {
		GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
		int resultCode = apiAvailability.isGooglePlayServicesAvailable( context );
		return resultCode == ConnectionResult.SUCCESS;
	}

	public void init() {
		if( isInitialized() ) return;

		AndroidActivityWrapper.GetAndroidActivityWrapper().addActivityResultListener( this );
		AndroidActivityWrapper.GetAndroidActivityWrapper().addActivityStateChangeListner( this );

		mGoogleApiClient = new GoogleApiClient.Builder( AIR.getContext().getActivity() )
				.addConnectionCallbacks( this )
				.addOnConnectionFailedListener( this )
				.addApi( Games.API ).addScope( Games.SCOPE_GAMES )
				.build();
		mUserAuth = false;
		mGoogleApiClient.connect();
	}

	public void signIn() {
		if( isInitialized() ) {
			if( !mGoogleApiClient.isConnecting() && !mGoogleApiClient.isConnected() ) {
				mUserAuth = true;
				if( mPendingConnectionResult != null ) {
					AIR.log( "Resolving connection result from earlier" );
					resolveSignInConnectionResult( mPendingConnectionResult );
				} else {
					AIR.log( "Connecting Google API client" );
					mGoogleApiClient.connect();
				}
			} else {
				AIR.log( "Client is already connected" );
			}
		}
	}

	public void signOut() {
		if( isInitialized() && mGoogleApiClient.isConnected() ) {
			Games.signOut( mGoogleApiClient );
			mGoogleApiClient.disconnect();
		}
	}

	/**
	 *
	 * Achievements
	 *
	 */

	public void showAchievementsUI() {
		if( isAuthenticated() ) {
			AIR.log( "GameServicesHelper | initialized and connected, showing UI" );
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_UI_SHOW );
			AIR.getContext().getActivity().startActivityForResult( Games.Achievements.getAchievementsIntent( mGoogleApiClient ), ACHIEVEMENTS_UI_RESULT_CODE );
		} else {
			AIR.log( "GameServicesHelper | not initialized or connected" );
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_UI_ERROR, "User is not signed in." );
		}
	}

	public void dispatchAchievementUpdateError() {
		AIR.log( "Cannot update achievement(s), user is not signed in." );
		AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_UPDATE_ERROR, "Cannot update achievement(s), user is not signed in." );
	}

    /**
     *
     * Leaderboards
     *
     */

	public void showLeaderboardsUI( String leaderboardId ) {
		if( isAuthenticated() ) {
			AIR.log( "GameServicesHelper | initialized and connected, showing UI" );
			mPendingLeaderboardId = leaderboardId;
			AIR.dispatchEvent( GameServicesEvent.LEADERBOARDS_UI_SHOW );
			AIR.getContext().getActivity().startActivityForResult( Games.Leaderboards.getLeaderboardIntent( mGoogleApiClient, leaderboardId ), LEADERBOARDS_UI_RESULT_CODE );
		} else {
			AIR.log( "GameServicesHelper | not initialized or connected" );
			AIR.dispatchEvent( GameServicesEvent.LEADERBOARDS_UI_ERROR, "User is not signed in." );
		}
	}

	/**
	 *
	 *
	 * Getters
	 *
	 *
	 */

	public GoogleApiClient getClient() {
		return mGoogleApiClient;
	}

	public boolean isInitialized() {
		return mGoogleApiClient != null;
	}

	public boolean isAuthenticated() {
		return isInitialized() && mGoogleApiClient.isConnected();
	}

	/**
	 * AIR activity state / result
	 */

	@Override
	public void onActivityStateChanged( AndroidActivityWrapper.ActivityState activityState ) {
		AIR.log( "GameServicesHelper | Activity state changed: " + activityState );
		if( activityState == AndroidActivityWrapper.ActivityState.DESTROYED ) {
			if( mGoogleApiClient.isConnected() ) {
				mGoogleApiClient.disconnect();
				mGoogleApiClient = null;
			}
			AndroidActivityWrapper.GetAndroidActivityWrapper().removeActivityResultListener( this );
			AndroidActivityWrapper.GetAndroidActivityWrapper().removeActivityStateChangeListner( this );
		}
	}

	@Override
	public void onConfigurationChanged( Configuration configuration ) { }

	@Override
	public void onActivityResult( int requestCode, int resultCode, Intent data ) {
		if( requestCode == AUTH_RESULT_CODE ) {
			mUserAuth = false;
			AIR.log( "GameServices::onActivityResult requestCode == AUTH_RESULT_CODE, is success: " + (resultCode == Activity.RESULT_OK) );
			handleUserSignIn( resultCode );
		} else if( requestCode == ACHIEVEMENTS_UI_RESULT_CODE ) {
			AIR.log( "GameServices::onActivityResult requestCode == ACHIEVEMENTS_UI_RESULT_CODE" );
			handleAchievementsUIRequest( resultCode );
		} else if( requestCode == LEADERBOARDS_UI_RESULT_CODE ) {
			AIR.log( "GameServices::onActivityResult requestCode == LEADERBOARDS_UI_RESULT_CODE" );
			handleLeaderboardsUIRequest( resultCode );
		}
	}

	/**
	 *
	 * Google API client
	 *
	 */

	@Override
	public void onConnected( @Nullable Bundle bundle ) {
		AIR.log( "GameServicesHelper | connected" );
		if( mPendingAchievementsUI ) {
			mPendingAchievementsUI = false;
			showAchievementsUI();
		} else if( mPendingLeaderboardsUI ) {
			mPendingLeaderboardsUI = false;
			showLeaderboardsUI( mPendingLeaderboardId );
		} else {
			AIR.log( "GameServicesHelper | user signed in" );
			Player player = Games.Players.getCurrentPlayer( mGoogleApiClient );
			JSONObject response = GSPlayerUtils.getJSON( player );
			AIR.dispatchEvent( GameServicesEvent.AUTH_SUCCESS, response.toString() );
		}
	}

	@Override
	public void onConnectionSuspended( int i ) {
		AIR.log( "GameServicesHelper | onConnectionSuspended() called. Trying to reconnect." );
		mGoogleApiClient.connect();
	}

	@Override
	public void onConnectionFailed( @NonNull ConnectionResult connectionResult ) {
		AIR.log( "GameServicesHelper | connection FAILED" );
		AIR.log( "Error message: " + connectionResult.getErrorMessage() );
		AIR.log( "Error code: " + connectionResult.getErrorCode() );

		if( !connectionResult.isSuccess() && connectionResult.hasResolution() ) {
			if( mPendingAchievementsUI ) {
				AIR.log( "GameServicesHelper | failed to connect with Google client, resolution available" );
				mPendingAchievementsUI = false;
				resolvePendingAchievementsUIError( connectionResult );
			}
			/* Start resolution intent only if the user requested auth himself */
			else if( mUserAuth ) {
				AIR.log( "GameServicesHelper | failed to connect with Google client, resolution available" );
				resolveSignInConnectionResult( connectionResult );
			} else {
				AIR.log( "GameServicesHelper | not starting auth resolution intent because user has not made the auth request himself" );
				mPendingConnectionResult = connectionResult;
			}
		} else {
			AIR.log( "GameServicesHelper | failed to connect with Google client, no resolution" );
		}
	}

	/**
	 *
	 *
	 * Private API
	 *
	 *
	 */

	private void resolveSignInConnectionResult( @NonNull ConnectionResult connectionResult ) {
		AIR.log( "GameServicesHelper::resolveSignInConnectionResult ErrorCode:" + connectionResult.getErrorCode() );
		mUserAuth = false;
		mPendingConnectionResult = null;

		try {
			connectionResult.startResolutionForResult( AIR.getContext().getActivity(), AUTH_RESULT_CODE );
			AIR.dispatchEvent( GameServicesEvent.WILL_PRESENT_AUTH_DIALOG );
		} catch( IntentSender.SendIntentException e ) {
			e.printStackTrace();
			mGoogleApiClient.connect();
		}
	}

	private void resolvePendingAchievementsUIError( @NonNull ConnectionResult connectionResult ) {
		AIR.log( "GameServicesHelper::resolveSignInConnectionResult ErrorCode:" + connectionResult.getErrorCode() );

		try {
			connectionResult.startResolutionForResult( AIR.getContext().getActivity(), AUTH_RESULT_CODE );
		} catch( IntentSender.SendIntentException e ) {
			e.printStackTrace();
			mGoogleApiClient.connect();
		}
	}

	private void handleAchievementsUIRequest( int resultCode ) {
		/* UI was not shown, client in inconsistent state, needs reconnect */
		if( resultCode == GamesActivityResultCodes.RESULT_RECONNECT_REQUIRED ) {
			AIR.log( "GameServices | client must be reconnected before showing achievements UI" );
			mPendingAchievementsUI = true;
			mGoogleApiClient.reconnect();
		} else {
			AIR.dispatchEvent( GameServicesEvent.ACHIEVEMENT_UI_HIDE );
		}
	}

	private void handleLeaderboardsUIRequest( int resultCode ) {
		/* UI was not shown, client in inconsistent state, needs reconnect */
		if( resultCode == GamesActivityResultCodes.RESULT_RECONNECT_REQUIRED ) {
			AIR.log( "GameServices | client must be reconnected before showing leaderboards UI" );
			mPendingLeaderboardsUI = true;
			mGoogleApiClient.reconnect();
		} else {
			mPendingLeaderboardId = null;
			AIR.dispatchEvent( GameServicesEvent.LEADERBOARDS_UI_HIDE );
		}
	}

	private void handleUserSignIn( int resultCode ) {
		if( resultCode == Activity.RESULT_OK ) {
			AIR.log( "GameServicesHelper | user signed in - client is connected: " + mGoogleApiClient.isConnected() );
			if( !mGoogleApiClient.isConnected() && !mGoogleApiClient.isConnecting() ) {
				mGoogleApiClient.connect();
			}
		} else {
			String errorMessage = (resultCode == Activity.RESULT_CANCELED) ? "User has declined signing in." : "There was an error signing the user in.";
			AIR.log( errorMessage );
			AIR.dispatchEvent( GameServicesEvent.AUTH_ERROR, errorMessage );
		}
	}

}

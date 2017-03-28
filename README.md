# GameServices | Google Play and Game Center extension for Adobe AIR

GameServices extension enables access to achievements and leaderboards functionality provided by *Google Play* on Android and *Game Center* on iOS. Achievements can be a great way to increase your users' engagement within your game, while leaderboards can drive competition among your players.

## Features

* User authentication
* Achievements
* Leaderboards

## Getting started

Add the extension's ID to the `extensions` element.

```xml
<extensions>
    <extensionID>com.marpies.ane.gameServices</extensionID>
</extensions>
```

If you are targeting Android, add the following extensions from [this repository](https://github.com/marpies/android-dependency-anes/releases) as well (unless you know these libraries are included by some other extensions):

```xml
<extensions>
    <extensionID>com.marpies.ane.androidsupport</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.base</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.basement</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.tasks</extensionID>
    <extensionID>com.marpies.ane.googleplayservices.games</extensionID>
</extensions>
```

Next, modify your `android/manifestAdditions` to include the following meta-data:

```xml
<![CDATA[
<manifest android:installLocation="auto">
    
    <application>

        <meta-data android:name="com.google.android.gms.games.APP_ID"
            android:value="\ {GOOGLE_APP_ID}" />
        <meta-data android:name="com.google.android.gms.version"
            android:value="@integer/google_play_services_version"/>

    </application>

</manifest>
]]>
```

Make sure to replace `{GOOGLE_APP_ID}` with your application ID as it appears in the *Google Play Developer Console*. Note the backslash and space is required.

The iOS library is built for iOS 7+. You may need to specify the minimum OS version to avoid warnings when creating your IPA:

```xml
<iPhone>
    <InfoAdditions>
        <![CDATA[
            ...

            <key>MinimumOSVersion</key>
            <string>7.0</string>

            ...
        ]]>
    </InfoAdditions>
</iPhone>
```

## API Overview

Start by initializing the extension using the `init` method. The only argument is a `Boolean` that controls whether extension logs show up.

```as3
var showLogs:Boolean = false;

GameServices.init( showLogs );
```

Note that a silent authentication will be performed during initialization. You may add the following event listeners before calling the `init` method to be notified in case the user has been authenticated silently:

```as3
GameServices.addEventListener( GSAuthEvent.SUCCESS, onGameServicesSilentAuthSuccess );
GameServices.addEventListener( GSAuthEvent.ERROR, onGameServicesSilentAuthError );

private function onGameServicesSilentAuthSuccess( event:GSAuthEvent ):void {
    trace( "User authenticated silently:", event.player );
}

private function onGameServicesSilentAuthError( event:GSAuthEvent ):void {
    trace( "Auth error occurred:", event.errorMessage );
}
```

On iOS, an identity signature will be generated. You may need this signature if you want a third party server to authenticate the local player:

```as3
GameServices.addEventListener( GSIdentityEvent.SUCCESS, onGameServicesIdentitySuccess );
GameServices.addEventListener( GSIdentityEvent.ERROR, onGameServicesIdentityError );

private function onGameServicesIdentitySuccess( event:GSIdentityEvent ):void {
    // pass the information to a third party server
    trace( "publicKeyUrl " + event.publicKeyUrl );
    trace( "signature " + event.signature );
    trace( "salt " + event.salt );
    trace( "timestamp " + event.timestamp );
}

private function onGameServicesIdentityError( event:GSIdentityEvent ):void {
    trace( "Identity error: " + event.errorMessage );
}
```

### User Initiated Authentication

You may use the `isAuthenticated` getter to see whether the user is authenticated or not.

```as3
trace( GameServices.isAuthenticated );
```

If the user is not authenticated, you may start the authentication process by calling the `authenticate` method:

```as3
GameServices.addEventListener( GSAuthEvent.SUCCESS, onGameServicesAuthSuccess );
GameServices.addEventListener( GSAuthEvent.ERROR, onGameServicesAuthError );
GameServices.addEventListener( GSAuthEvent.DIALOG_WILL_APPEAR, onGameServicesAuthDialogWillAppear );

GameServices.authenticate();

private function onGameServicesAuthDialogWillAppear( event:GSAuthEvent ):void {
    trace( "Native UI will appear, pause game rendering" );
}

private function onGameServicesAuthSuccess( event:GSAuthEvent ):void {
    trace( "User authenticated:", event.player );
}

private function onGameServicesAuthError( event:GSAuthEvent ):void {
    trace( "Auth error occurred:", event.errorMessage );
}
```

### User Information

After the user has authenticated, you may use the `player` getter to obtain basic information about the user:

```as3
var player:GSPlayer = GameServices.player;
trace( player.id );
trace( player.alias );
trace( player.displayName );

// Android only
trace( player.iconImageUri );
trace( player.hiResImageUri );
```

### Achievements

To access the achievements API, use the `achievements` getter. The returned object provides number of methods allowing you to work with player achievements.

#### Loading Achievements

To load current player's progress in all achievements, use the `load` method. If successful, the event's `achievements` property will contain a list of `GSAchievement` objects. Use these objects to learn about player's progress or build your own UI:

```as3
// The listener must be added on the 'achievements' object
GameServices.achievements.addEventListener(GSAchievementEvent.LOAD_SUCCESS, onAchievementsLoadSuccess);
GameServices.achievements.addEventListener(GSAchievementEvent.LOAD_ERROR, onAchievementsLoadError);

GameServices.achievements.load();

private function onAchievementLoadSuccess( event:GSAchievementEvent ):void {
    trace( "Loaded achievements: " + event.achievements );
    for each( var achievement:GSAchievement in event.achievements ) {
        trace( achievement.id );

        trace( achievement.steps ); // Android only
        trace( achievement.totalSteps ); // Android only

        trace( achievement.progress ); // iOS only (0.0 - 100.0)
    }
}

private function onAchievementsLoadError( event:GSAchievementEvent ):void {
    trace( "Error occurred: " + event.errorMessage );
}
```

#### Native UI

You may also show a native UI where the progress for each achievement is shown:

```as3
GameServices.achievements.addEventListener(GSAchievementEvent.UI_SHOW, onAchievementsUIShow);
GameServices.achievements.addEventListener(GSAchievementEvent.UI_HIDE, onAchievementsUIHide);
GameServices.achievements.addEventListener(GSAchievementEvent.UI_ERROR, onAchievementsUIError);

GameServices.achievements.showNativeUI();

private function onAchievementsUIShow( event:GSAchievementEvent ):void {
    trace( "Achievements UI shown" );
}

private function onAchievementsUIHide( event:GSAchievementEvent ):void {
    trace( "Achievements UI hidden" );
}

private function onAchievementsUIError( event:GSAchievementEvent ):void {
    trace( "Achievements UI error: " + event.errorMessage );
}
```

#### Reveal Achievement

You may use hidden achievements, for example to hide certain aspects of your game's story. You control when the achievement is revealed to the player using the `reveal` method:

```as3
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_SUCCESS, onAchievementRevealSuccess );
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_ERROR, onAchievementRevealError );

GameServices.achievements.reveal( "achievementId" );
```

#### Unlock Achievement

To reward the player for reaching a milestone, use the `unlock` method. If the achievement is hidden this will reveal it to the player.

```as3
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_SUCCESS, onAchievementUnlockSuccess );
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_ERROR, onAchievementUnlockError );

GameServices.achievements.unlock( "achievementId" );
```

#### Update Progress

To record an achievement progress, use one of the methods listed below. Note that iOS supports only the `setProgress` method, where the `progress` parameter is a percentage value that states how far the player has progressed on the given achievement. Each method dispatches either `UPDATE_SUCCESS` or `UPDATE_ERROR` event.

```as3
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_SUCCESS, onAchievementUpdateSuccess );
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_ERROR, onAchievementUpdateError );

// Android only
GameServices.achievements.setSteps( "achievementId", 5 ); // Set to the given number of steps
GameServices.achievements.increment( "achievementId", 5 ); // Increment by the given number of steps

// iOS only
GameServices.achievements.setProgress( "achievementId", 55 ); // 55% progress
```

Alternatively, you may report progress on multiple achievements using the `report` method:

```as3
var a1:GSAchievement = new GSAchievement( "achievement1-id", step, progress );
var a2:GSAchievement = new GSAchievement( "achievement2-id", step, progress );

GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_SUCCESS, onAchievementUpdateSuccess );
GameServices.achievements.addEventListener( GSAchievementEvent.UPDATE_ERROR, onAchievementUpdateError );

GameServices.achievements.report( new <GSAchievement>[a1, a2] );
```

#### Reset Achievements

You may reset progress for all achievements using the `resetAll` method, however it is only supported on iOS. Resetting achievements on Android may be done via the [Google Play Console](https://developers.google.com/games/services/common/concepts/achievements#resetting_an_achievement).

```as3
GameServices.achievements.addEventListener( GSAchievementEvent.RESET_SUCCESS, onAchievementResetSuccess );
GameServices.achievements.addEventListener( GSAchievementEvent.RESET_ERROR, onAchievementResetError );

GameServices.achievements.resetAll();
```

### Leaderboards

To access the leaderboards API, use the `leaderboards` getter.

#### Report Score

To report player's score, use the `report` method along with a leaderboard ID and the achieved score:

```as3
GameServices.leaderboards.addEventListener(GSLeaderboardEvent.REPORT_SUCCESS, onLeaderboardReportSuccess);
GameServices.leaderboards.addEventListener(GSLeaderboardEvent.REPORT_ERROR, onLeaderboardReportError);

GameServices.leaderboards.report( "leaderboardId", 150 );
```

#### Native UI

You may also show a native UI and let the players browse the leaderboards:

```as3
GameServices.leaderboards.addEventListener(GSLeaderboardEvent.UI_SHOW, onLeaderboardsUIShow);
GameServices.leaderboards.addEventListener(GSLeaderboardEvent.UI_HIDE, onLeaderboardsUIHide);
GameServices.leaderboards.addEventListener(GSLeaderboardEvent.UI_ERROR, onLeaderboardsUIError);

GameServices.leaderboards.showNativeUI( "leaderboardId" );

private function onLeaderboardsUIShow( event:GSLeaderboardEvent ):void {
    trace( "Leaderboards UI shown" );
}

private function onLeaderboardsUIHide( event:GSLeaderboardEvent ):void {
    trace( "Leaderboards UI hidden" );
}

private function onLeaderboardsUIError( event:GSLeaderboardEvent ):void {
    trace( "Leaderboards UI error: " + event.errorMessage );
}
```

## Documentation

ActionScript [documentation is available online](https://marpies.github.io/docs/game-services-ane/), or can be generated by running `ant asdoc` from the *build* directory.

## Build ANE

ANT build scripts are available in the *build* directory. Edit *build.properties* to correspond with your local setup.

## Requirements

* Adobe AIR 20+
* Android 4.0+
* iOS 7+

## Author

The ANE has been written by [Marcel Piestansky](https://twitter.com/marpies) and is distributed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

## Change log

### March 28, 2017

* v1.0.0
  * Public release
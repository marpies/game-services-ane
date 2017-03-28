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

#import "GameServicesDelegate.h"
#import "GameServices.h"
#import <GameKit/GKLocalPlayer.h>
#import "GameServicesEvent.h"
#import <AIRExtHelpers/MPStringUtils.h>
#import "GKPlayerUtils.h"

static GameServicesDelegate* mAIRGameServicesInstance = nil;

@implementation GameServicesDelegate {
    BOOL mHasCancelledEarlier;
    GKGameCenterViewControllerState mGameCenterViewState;
}

@synthesize cachedAuthController;
@synthesize showAchievementBanner;

# pragma mark - Public API

+ (id) sharedInstance {
    if( mAIRGameServicesInstance == nil ) {
        mAIRGameServicesInstance = [[GameServicesDelegate alloc] init];
    }
    return mAIRGameServicesInstance;
}

- (id) init {
    if( self = [super init] ) {
        mHasCancelledEarlier = NO;
        self.showAchievementBanner = YES;
    }
    return self;
}

- (BOOL) isSupported {
    if( [GKLocalPlayer class] ) {
        return YES;
    }
    return NO;
}

- (void) authenticate:(BOOL) silent {
    if( ![self isSupported] ) {
        [GameServices log:@"GameServicesDelegate::authenticate GameKit is not supported on this device."];
        return;
    }
    [GameServices log:[NSString stringWithFormat:@"GameServicesDelegate::authenticate silently=%i", silent]];
    
    if( mHasCancelledEarlier ) {
        [GameServices log:@"GameServicesDelegate::authenticate user has cancelled auth earlier, new dialog won't be presented in this session."];
        return;
    }
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    /* Present cached auth UIViewController if exists */
    if( [[GameServicesDelegate sharedInstance] cachedAuthController] != nil ) {
        if( silent ) {
            [GameServices log:@"GameServicesDelegate::authenticate cached auth UIViewController exists but silent auth requested!"];
            return;
        }
        [GameServices log:@"GameServicesDelegate::authenticate presenting cached auth UIViewController"];
        [self presentAuthenticationViewController:[[GameServicesDelegate sharedInstance] cachedAuthController]];
        [[GameServicesDelegate sharedInstance] setCachedAuthController:nil];
    }
    /* Otherwise try to present auth UIViewController from the start */
    else {
        if( localPlayer.isAuthenticated ) {
            [GameServices log:@"GameServicesDelegate::authenticate NO cached auth UIViewController but already auth'd"];
        } else {
            localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
                /* User not authenticated, should present view controller */
                if( viewController != nil ) {
                    /* If silent then cache the UIViewController */
                    if( silent ) {
                        [GameServices log:@"GameServicesDelegate::authenticate caching auth UIViewController for when it's time to auth"];
                        [[GameServicesDelegate sharedInstance] setCachedAuthController:viewController];
                    }
                    /* Present right away */
                    else {
                        [GameServices log:@"GameServicesDelegate::authenticate presenting auth UIViewController"];
                        [self presentAuthenticationViewController:viewController];
                    }
                } else if( [GKLocalPlayer localPlayer].isAuthenticated ) {
                    [GameServices log:@"GameServicesDelegate::authenticate User authenticated, generating identity verification signature"];
                    [GameServices dispatchEvent:GS_AUTH_SUCCESS withMessage:[MPStringUtils getJSONString:[GKPlayerUtils toJSON:[GKLocalPlayer localPlayer]]]];
                    [[GKLocalPlayer localPlayer] generateIdentityVerificationSignatureWithCompletionHandler:^(NSURL * _Nullable publicKeyUrl, NSData * _Nullable signature, NSData * _Nullable salt, uint64_t timestamp, NSError * _Nullable error) {
                        if( error == nil ) {
                            [GameServices log:@"GameServicesDelegate::authenticate retrieved identity"];
                            NSDictionary* identityJSON = @{@"publicKeyUrl": publicKeyUrl.absoluteString,
                                                                  @"timestamp": [NSString stringWithFormat:@"%llu", timestamp],
                                                                  @"signature": [signature base64EncodedStringWithOptions:0],
                                                                  @"salt": [salt base64EncodedStringWithOptions:0]};
                            [GameServices dispatchEvent:GS_IDENTITY_SUCCESS withMessage:[MPStringUtils getJSONString:identityJSON]];
                        }
                        /* Error generating identity */
                        else {
                            [GameServices log:@"GameServicesDelegate::authenticate ERROR generating identity verification signature"];
                            [GameServices dispatchEvent:GS_IDENTITY_ERROR withMessage:error.localizedDescription];
                        }
                        
                    }];
                } else if( error != nil ) {
                    [GameServices log:[NSString stringWithFormat:@"GameServicesDelegate::authenticate error: %@", error.description]];
                    mHasCancelledEarlier = [[error description] containsString:@"canceled"] || error.code == 2;
                    [GameServices dispatchEvent:GS_AUTH_ERROR withMessage:error.localizedDescription];
                }
            };
        }
    }
}

- (void) showAchievementsUI {
    mGameCenterViewState = GKGameCenterViewControllerStateAchievements;
    
    [self showNativeUI:nil];
}

- (void) showLeaderboardsUI:(nonnull NSString*) leaderboardId {
    mGameCenterViewState = GKGameCenterViewControllerStateLeaderboards;
    
    [self showNativeUI:leaderboardId];
}

# pragma mark - Private API

- (void) showNativeUI:(nullable NSString*) leaderboardId {
    NSString* event = GS_ACHIEVEMENT_UI_SHOW;
    if( mGameCenterViewState == GKGameCenterViewControllerStateLeaderboards ) {
        event = GS_LEADERBOARDS_UI_SHOW;
    }
    
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.gameCenterDelegate = self;
    gameCenterController.viewState = mGameCenterViewState;
    
    /* Set leaderboard ID */
    if( leaderboardId != nil ) {
        gameCenterController.leaderboardIdentifier = leaderboardId;
    }
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:gameCenterController animated:YES completion:^{
        [GameServices dispatchEvent:event];
    }];
}

- (void) presentAuthenticationViewController:(UIViewController*) viewController {
    [GameServices dispatchEvent:GS_WILL_PRESENT_AUTH_DIALOG];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
}

# pragma mark - GKGameCenterControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *) gameCenterViewController {
    [GameServices log:@"GameServicesDelegate::gameCenterViewControllerDidFinish"];
    
    NSString* event = GS_ACHIEVEMENT_UI_HIDE;
    if( mGameCenterViewState == GKGameCenterViewControllerStateLeaderboards ) {
        event = GS_LEADERBOARDS_UI_HIDE;
    }
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissViewControllerAnimated:YES completion:^{
        [GameServices dispatchEvent:event];
    }];
}

@end










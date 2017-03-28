package com.marpies.ane.gameservices.achievements {

    import com.marpies.ane.gameservices.GameServices;
    import com.marpies.ane.gameservices.events.GSAchievementEvent;

    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;

    CONFIG::ane {
        import flash.external.ExtensionContext;
    }

    /**
     * Class providing access to achievements functionality.
     */
    public class GSAchievements extends EventDispatcher {

        /* Event codes */
        private static const ACHIEVEMENT_UPDATE_SUCCESS:String = "achievementUpdateSuccess";
        private static const ACHIEVEMENT_UPDATE_ERROR:String = "achievementUpdateError";
        private static const ACHIEVEMENT_LOAD_SUCCESS:String = "achievementLoadSuccess";
        private static const ACHIEVEMENT_LOAD_ERROR:String = "achievementLoadError";
        private static const ACHIEVEMENT_UI_SHOW:String = "achievementsUIShow";
        private static const ACHIEVEMENT_UI_ERROR:String = "achievementsUIError";
        private static const ACHIEVEMENT_UI_HIDE:String = "achievementsUIHide";
        private static const ACHIEVEMENT_RESET_SUCCESS:String = "achievementResetSuccess";
        private static const ACHIEVEMENT_RESET_ERROR:String = "achievementResetError";

        CONFIG::ane {
            private var mContext:ExtensionContext;
        }

        /* Singleton stuff */
        private static var mCanInitialize:Boolean;
        private static var mInstance:GSAchievements;

        /**
         * @private
         */
        public function GSAchievements() {
            if( !mCanInitialize ) throw new Error( "GSAchievements can only be initialized internally. Access it using GameServices.achievements getter." );
        }

        /**
         * @private
         */
        ns_gameservices_internal static function getInstance():GSAchievements {
            if( !mInstance ) {
                mCanInitialize = true;
                mInstance = new GSAchievements();
                mCanInitialize = false;
            }
            return mInstance;
        }

        /**
         * @private
         */
        ns_gameservices_internal static function dispose():void {
            CONFIG::ane {
                if( mInstance ) {
                    if( mInstance.mContext !== null ) {
                        mInstance.removeContextListener();
                        mInstance.mContext = null;
                    }
                    mInstance = null;
                }
            }
        }

        CONFIG::ane {
            /**
             * @private
             */
            ns_gameservices_internal function setContext( context:ExtensionContext ):void {
                if( context === null ) throw new ArgumentError( "Parameter context cannot be null." );

                mContext = context;
                addNativeListener();
            }
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Unlock an achievement for the currently signed in player. If the achievement is hidden this will
         * reveal it to the player.
         *
         * @param achievementId The ID of the achievement to unlock.
         * @param immediate Set to <code>true</code> if you need the operation to attempt to communicate
         *                  to the server immediately, otherwise the update may not be sent to the server until
         *                  the next sync.
         *
         * @event updateSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                      is updated successfully.
         * @event updateError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                    fails to be updated.
         */
        public function unlock( achievementId:String, immediate:Boolean = false ):void {
            if( !GameServices.isSupported ) return;

            CONFIG::ane {
                mContext.call( "unlockAchievement", achievementId, immediate );
            }
        }

        /**
         * Reveals a hidden achievement to the currently signed in player. If the achievement has already been unlocked,
         * this will have no effect.
         *
         * @param achievementId The ID of the achievement to reveal.
         * @param immediate Set to <code>true</code> if you need the operation to attempt to communicate
         *                  to the server immediately, otherwise the update may not be sent to the server until
         *                  the next sync.
         *
         * @event updateSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                      is updated successfully.
         * @event updateError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                    fails to be updated.
         */
        public function reveal( achievementId:String, immediate:Boolean = false ):void {
            if( !GameServices.isSupported ) return;

            CONFIG::ane {
                mContext.call( "revealAchievement", achievementId, immediate );
            }
        }

        /**
         * <strong>Android only</strong> - Increments an achievement by the given number of steps.
         * The achievement must be an incremental achievement. Once an achievement reaches at least
         * the maximum number of steps, it will be unlocked automatically. Any further increments will be ignored.
         *
         * @param achievementId The achievement ID to increment.
         * @param numSteps The number of steps to increment by. Must be greater than 0.
         * @param immediate Set to <code>true</code> if you need the operation to attempt to communicate
         *                  to the server immediately, otherwise the update may not be sent to the server until
         *                  the next sync.
         *
         * @event updateSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                      is updated successfully.
         * @event updateError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                    fails to be updated.
         */
        public function increment( achievementId:String, numSteps:uint = 1, immediate:Boolean = false ):void {
            if( !GameServices.isSupported ) return;

            if( numSteps == 0 ) throw new ArgumentError( "Argument numSteps must be greater than 0." );

            CONFIG::ane {
                mContext.call( "incrementAchievement", achievementId, numSteps, immediate );
            }
        }

        /**
         * <strong>Android only</strong> - Sets an achievement to have at least the given number of steps completed.
         * Calling this method while the achievement already has more steps than the provided value is a no-op.
         * Once the achievement reaches the maximum number of steps, the achievement will automatically be unlocked,
         * and any further mutation operations will be ignored.
         *
         * @param achievementId The ID of the achievement to update.
         * @param numSteps The number of steps to set the achievement to. Must be greater than 0.
         * @param immediate Set to <code>true</code> if you need the operation to attempt to communicate
         *                  to the server immediately, otherwise the update may not be sent to the server until
         *                  the next sync.
         *
         * @event updateSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                      is updated successfully.
         * @event updateError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                    fails to be updated.
         */
        public function setSteps( achievementId:String, numSteps:uint = 1, immediate:Boolean = false ):void {
            if( !GameServices.isSupported ) return;

            if( numSteps == 0 ) throw new ArgumentError( "Argument numSteps must be greater than 0." );

            CONFIG::ane {
                mContext.call( "setAchievementSteps", achievementId, numSteps, immediate );
            }
        }

        /**
         * <strong>iOS only</strong> - Sets the achievement's progress, i.e. percentage value that states
         * how far the player has progressed on this achievement.
         *
         * @param achievementId The ID of the achievement to update.
         * @param progress A percentage value that states how far the player has progressed on this achievement.
         *                 The range of legal values is between 0.0 and 100.0, inclusive.
         *
         * @event updateSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                      is updated successfully.
         * @event updateError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                    fails to be updated.
         */
        public function setProgress( achievementId:String, progress:Number ):void {
            if( !GameServices.isSupported ) return;

            if( progress < 0 || progress > 100 ) throw new ArgumentError( "Argument progress must be between 0.0 and 100.0, including." );

            CONFIG::ane {
                mContext.call( "setAchievementProgress", achievementId, progress );
            }
        }

        /**
         * Loads the achievements data for the current player.
         *
         * @event loadSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievements
         *                    are loaded successfully.
         * @event loadError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievements
         *                  fail to be loaded.
         */
        public function load():void {
            if( !GameServices.isSupported ) return;

            CONFIG::ane {
                mContext.call( "loadAchievements" );
            }
        }

        /**
         * Reports multiple achievements in a single call.
         *
         * @param achievements A list of achievements to update.
         *
         * @event updateSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                      is updated successfully.
         * @event updateError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievement
         *                    fails to be updated.
         */
        public function report( achievements:Vector.<GSAchievement> ):void {
            if( !GameServices.isSupported ) return;

            if( achievements === null ) throw new ArgumentError( "Parameter achievements cannot be null." );

            CONFIG::ane {
                mContext.call( "reportAchievements", achievements );
            }
        }

        /**
         * Shows the native achievements UI.
         *
         * @event uiShow com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the native achievements
         *               UI is shown.
         * @event uiHide com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the native achievements
         *               UI is hidden.
         * @event uiError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the native achievements
         *                UI fails to be shown.
         */
        public function showNativeUI():void {
            if( !GameServices.isSupported ) return;

            CONFIG::ane {
                mContext.call( "showAchievementsUI" );
            }
        }

        /**
         * <strong>iOS only</strong> - Resets all achievements progress for the local player.
         *
         * @event resetSuccess com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievements
         *                     are reset successfully.
         * @event resetError com.marpies.ane.gameservices.events.GSAchievementEvent Dispatched when the achievements
         *                   fail to be reset.
         */
        public function resetAll():void {
            if( !GameServices.isSupported ) return;

            CONFIG::ane {
                mContext.call( "resetAchievements" );
            }
        }

        /**
         * Set to <code>false</code> if your game displays a custom banner or indicator when a player
         * earns an achievement.
         *
         * @param value <code>false</code> if the native completion banner should not appear.
         */
        public function setShowCompletionBanner( value:Boolean ):void {
            if( !GameServices.isSupported ) return;

            CONFIG::ane {
                mContext.call( "showAchievementBanner", value );
            }
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        private function onStatus( event:StatusEvent ):void {
            switch( event.code ) {
                case ACHIEVEMENT_UPDATE_SUCCESS:
                    dispatchAchievementUpdateSuccess();
                    return;

                case ACHIEVEMENT_UPDATE_ERROR:
                    dispatchAchievementUpdateError( event.level );
                    return;

                case ACHIEVEMENT_LOAD_SUCCESS:
                    var json:Object = JSON.parse( event.level );
                    dispatchAchievementLoadSuccess( json.achievements );
                    return;

                case ACHIEVEMENT_LOAD_ERROR:
                    dispatchAchievementLoadError( event.level );
                    return;

                case ACHIEVEMENT_UI_SHOW:
                    dispatchAchievementUIShow();
                    return;

                case ACHIEVEMENT_UI_HIDE:
                    dispatchAchievementUIHide();
                    return;

                case ACHIEVEMENT_UI_ERROR:
                    dispatchAchievementUIError( event.level );
                    return;

                case ACHIEVEMENT_RESET_SUCCESS:
                    dispatchAchievementResetSuccess();
                    return;

                case ACHIEVEMENT_RESET_ERROR:
                    dispatchAchievementResetError( event.level );
                    return;
            }
        }

        private function dispatchAchievementUIShow():void {
            if( !hasEventListener( GSAchievementEvent.UI_SHOW ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.UI_SHOW ) );
        }

        private function dispatchAchievementUIHide():void {
            if( !hasEventListener( GSAchievementEvent.UI_HIDE ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.UI_HIDE ) );
        }

        private function dispatchAchievementUIError( errorMessage:String ):void {
            if( !hasEventListener( GSAchievementEvent.UI_ERROR ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.UI_ERROR, errorMessage ) );
        }

        private function dispatchAchievementUpdateSuccess():void {
            if( !hasEventListener( GSAchievementEvent.UPDATE_SUCCESS ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.UPDATE_SUCCESS ) );
        }

        private function dispatchAchievementUpdateError( errorMessage:String ):void {
            if( !hasEventListener( GSAchievementEvent.UPDATE_ERROR ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.UPDATE_ERROR, errorMessage ) );
        }

        private function dispatchAchievementResetSuccess():void {
            if( !hasEventListener( GSAchievementEvent.RESET_SUCCESS ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.RESET_SUCCESS ) );
        }

        private function dispatchAchievementResetError( errorMessage:String ):void {
            if( !hasEventListener( GSAchievementEvent.RESET_ERROR ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.RESET_ERROR, errorMessage ) );
        }

        private function dispatchAchievementLoadSuccess( json:Object ):void {
            if( json is String ) {
                json = JSON.parse( json as String );
            }
            if( json is Array ) {
                dispatchEvent( new GSAchievementEvent( GSAchievementEvent.LOAD_SUCCESS, null, GSAchievement.fromJSONArray( json as Array ) ) );
            }
        }

        private function dispatchAchievementLoadError( errorMessage:String ):void {
            if( !hasEventListener( GSAchievementEvent.LOAD_ERROR ) ) return;

            dispatchEvent( new GSAchievementEvent( GSAchievementEvent.LOAD_ERROR, errorMessage ) );
        }

        private function addNativeListener():void {
            CONFIG::ane {
                mContext.addEventListener( StatusEvent.STATUS, onStatus );
            }
        }

        private function removeContextListener():void {
            CONFIG::ane {
                mContext.removeEventListener( StatusEvent.STATUS, onStatus );
            }
        }

    }

}

package com.marpies.ane.gameservices.leaderboards {

    import com.marpies.ane.gameservices.GameServices;
    import com.marpies.ane.gameservices.events.GSLeaderboardEvent;

    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;


    CONFIG::ane {
        import flash.external.ExtensionContext;
    }

    /**
     * Class providing access to leaderboards functionality.
     */
    public class GSLeaderboards extends EventDispatcher {

        /* Event codes */
        private static const LEADERBOARDS_UI_SHOW:String = "leaderboardsUIShow";
        private static const LEADERBOARDS_UI_ERROR:String = "leaderboardsUIError";
        private static const LEADERBOARDS_UI_HIDE:String = "leaderboardsUIHide";

        private static const REPORT_SCORE_SUCCESS:String = "reportScoreSuccess";
        private static const REPORT_SCORE_ERROR:String = "reportScoreError";

        CONFIG::ane {
            private var mContext:ExtensionContext;
        }

        /* Singleton stuff */
        private static var mCanInitialize:Boolean;
        private static var mInstance:GSLeaderboards;

        /**
         * @private
         */
        public function GSLeaderboards() {
            if( !mCanInitialize ) throw new Error( "GSLeaderboards can only be initialized internally. Access it using GameServices.leaderboards getter." );
        }

        /**
         * @private
         */
        ns_gameservices_internal static function getInstance():GSLeaderboards {
            if( !mInstance ) {
                mCanInitialize = true;
                mInstance = new GSLeaderboards();
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
         * Reports the score to the given leaderboard.
         *
         * @param leaderboardId The leaderboard identifier.
         * @param score The score to report.
         * @param immediate Set to <code>true</code> if you need the operation to attempt to communicate
         *                  to the server immediately, otherwise the update may not be sent to the server until
         *                  the next sync.
         *
         * @event reportSuccess com.marpies.ane.gameservices.events.GSLeaderboardEvent Dispatched when the score has been
         *                reported successfully.
         * @event reportError com.marpies.ane.gameservices.events.GSLeaderboardEvent Dispatched when the score has failed
         *              to be reported.
         */
        public function report( leaderboardId:String, score:Number = 0, immediate:Boolean = false ):void {
            if( leaderboardId == null ) throw new ArgumentError( "Parameter leaderboardId cannot be null." );

            CONFIG::ane {
                mContext.call( "reportScore", leaderboardId, score, immediate );
            }
        }

        /**
         * Shows the native leaderboards UI.
         *
         * @param leaderboardId The identifier of the leaderboard to be shown.
         *
         * @event uiShow com.marpies.ane.gameservices.events.GSLeaderboardEvent Dispatched when the native leaderboards
         *               UI is shown.
         * @event uiHide com.marpies.ane.gameservices.events.GSLeaderboardEvent Dispatched when the native leaderboards
         *               UI is hidden.
         * @event uiError com.marpies.ane.gameservices.events.GSLeaderboardEvent Dispatched when the native leaderboards
         *                UI fails to be shown.
         */
        public function showNativeUI( leaderboardId:String ):void {
            if( !GameServices.isSupported ) return;

            if( leaderboardId == null ) throw new ArgumentError( "Parameter leaderboardId cannot be null." );

            CONFIG::ane {
                mContext.call( "showLeaderboardsUI", leaderboardId );
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
                case LEADERBOARDS_UI_SHOW:
                    dispatchLeaderboardsUIShow();
                    return;

                case LEADERBOARDS_UI_ERROR:
                    dispatchLeaderboardsUIError( event.level );
                    return;

                case LEADERBOARDS_UI_HIDE:
                    dispatchLeaderboardsUIHide();
                    return;

                case REPORT_SCORE_SUCCESS:
                    dispatchScoreReportSuccess();
                    return;

                case REPORT_SCORE_ERROR:
                    dispatchScoreReportError( event.level );
                    return;
            }
        }

        private function dispatchLeaderboardsUIShow():void {
            if( !hasEventListener( GSLeaderboardEvent.UI_SHOW ) ) return;

            dispatchEvent( new GSLeaderboardEvent( GSLeaderboardEvent.UI_SHOW ) );
        }

        private function dispatchLeaderboardsUIHide():void {
            if( !hasEventListener( GSLeaderboardEvent.UI_HIDE ) ) return;

            dispatchEvent( new GSLeaderboardEvent( GSLeaderboardEvent.UI_HIDE ) );
        }

        private function dispatchLeaderboardsUIError( errorMessage:String ):void {
            if( !hasEventListener( GSLeaderboardEvent.UI_ERROR ) ) return;

            dispatchEvent( new GSLeaderboardEvent( GSLeaderboardEvent.UI_ERROR, errorMessage ) );
        }

        private function dispatchScoreReportSuccess():void {
            if( !hasEventListener( GSLeaderboardEvent.REPORT_SUCCESS ) ) return;

            dispatchEvent( new GSLeaderboardEvent( GSLeaderboardEvent.REPORT_SUCCESS, null ) );
        }

        private function dispatchScoreReportError( errorMessage:String ):void {
            if( !hasEventListener( GSLeaderboardEvent.REPORT_ERROR ) ) return;

            dispatchEvent( new GSLeaderboardEvent( GSLeaderboardEvent.REPORT_ERROR, errorMessage ) );
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

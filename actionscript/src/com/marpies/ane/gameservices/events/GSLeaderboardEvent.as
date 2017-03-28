package com.marpies.ane.gameservices.events {

    import flash.events.Event;

    /**
     * Dispatched when one of the method related to leaderboards is called.
     */
    public class GSLeaderboardEvent extends GSErrorEvent {

        /**
         * Successfully reported the score.
         */
        public static const REPORT_SUCCESS:String = "GSLeaderboardEvent::reportSuccess";

        /**
         * Failed to report the score.
         */
        public static const REPORT_ERROR:String = "GSLeaderboardEvent::reportError";

        /**
         * The native leaderboards UI has been shown.
         */
        public static const UI_SHOW:String = "GSLeaderboardEvent::uiShow";

        /**
         * The native leaderboards UI has been hidden.
         */
        public static const UI_HIDE:String = "GSLeaderboardEvent::uiHide";

        /**
         * Failed to show the native leaderboards UI.
         */
        public static const UI_ERROR:String = "GSLeaderboardEvent::uiError";

        /**
         * @private
         */
        public function GSLeaderboardEvent( type:String, errorMessage:String = null ) {
            super( type, errorMessage );
        }

        /**
         * @private
         */
        override public function clone():Event {
            return new GSLeaderboardEvent( type, errorMessage );
        }
    }

}

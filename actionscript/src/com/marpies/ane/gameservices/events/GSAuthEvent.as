package com.marpies.ane.gameservices.events {

    import com.marpies.ane.gameservices.GSPlayer;

    /**
     * Dispatched during user authentication.
     */
    public class GSAuthEvent extends GSErrorEvent {

        /**
         * The user has been successfully authenticated.
         */
        public static const SUCCESS:String = "GSAuthEvent::success";

        /**
         * Failed to authenticate the user.
         */
        public static const ERROR:String = "GSAuthEvent::error";

        /**
         * The authentication dialog will appear.
         */
        public static const DIALOG_WILL_APPEAR:String = "GSAuthEvent::dialogWillAppear";

        private var mPlayer:GSPlayer;

        /**
         * @private
         */
        public function GSAuthEvent( type:String, errorMessage:String = null, player:GSPlayer = null ) {
            super( type, errorMessage );

            mPlayer = player;
        }

        /**
         * Returns the local player, if successfully authenticated.
         */
        public function get player():GSPlayer {
            return mPlayer;
        }
    }

}

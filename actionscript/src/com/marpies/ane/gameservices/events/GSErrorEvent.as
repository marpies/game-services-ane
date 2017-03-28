package com.marpies.ane.gameservices.events {

    import flash.events.Event;

    /**
     * Base event class, providing message about possible failures.
     */
    public class GSErrorEvent extends Event {

        private var mErrorMessage:String;

        /**
         * @private
         */
        public function GSErrorEvent( type:String, errorMessage:String ) {
            super( type, false, false );

            mErrorMessage = errorMessage;
        }

        /**
         * If an error occurred, returns the error's message, otherwise returns <code>null</code>.
         */
        public function get errorMessage():String {
            return mErrorMessage;
        }
    }

}

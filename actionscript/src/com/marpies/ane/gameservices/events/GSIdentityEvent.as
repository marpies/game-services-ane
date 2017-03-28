package com.marpies.ane.gameservices.events {

    /**
     * Dispatched when identity verification signature is generated for the authenticated player (iOS only).
     */
    public class GSIdentityEvent extends GSErrorEvent {

        /**
         * The signature was generated successfully.
         */
        public static const SUCCESS:String = "GSIdentityEvent::success";

        /**
         * Generating the signature failed.
         */
        public static const ERROR:String = "GSIdentityEvent::error";

        private var mPublicKeyUrl:String;
        private var mSignature:String;
        private var mSalt:String;
        private var mTimestamp:Number;

        /**
         * @private
         */
        public function GSIdentityEvent( type:String, errorMessage:String = null, publicKeyUrl:String = null, signature:String = null, salt:String = null, timestamp:Number = 0 ) {
            super( type, errorMessage );
            mPublicKeyUrl = publicKeyUrl;
            mSignature = signature;
            mSalt = salt;
            mTimestamp = timestamp;
        }

        /**
         * The URL for the public encryption key.
         */
        public function get publicKeyUrl():String {
            return mPublicKeyUrl;
        }

        /**
         * The verification signature data generated.
         */
        public function get signature():String {
            return mSignature;
        }

        /**
         * A random <code>String</code> used to compute the hash and keep it randomized.
         */
        public function get salt():String {
            return mSalt;
        }

        /**
         * The date and time that the signature was created.
         */
        public function get timestamp():Number {
            return mTimestamp;
        }
    }

}

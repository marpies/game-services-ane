package com.marpies.ane.gameservices {

    /**
     * Class representing local player.
     */
    public class GSPlayer {

        private var mId:String;
        private var mAlias:String;
        private var mDisplayName:String;
        private var mIconImageUri:String;
        private var mHiResImageUri:String;

        /**
         * @private
         */
        public function GSPlayer() {
        }

        /**
         * @private
         */
        public function toString():String {
            return "{GSPlayer | id: " + mId + " alias: " + mAlias + " displayName: " + mDisplayName + "}";
        }

        /**
         * @private
         */
        internal static function fromJSON( json:Object ):GSPlayer {
            var player:GSPlayer = new GSPlayer();
            player.mId = json.playerId;
            player.mAlias = json.alias;
            player.mDisplayName = json.displayName;
            player.mIconImageUri = json.iconImageUri;
            player.mHiResImageUri = json.hiResImageUri;
            return player;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Player's id, as assigned by Google Play or Game Center.
         */
        public function get id():String {
            return mId;
        }

        /**
         * Player's alias.
         */
        public function get alias():String {
            return mAlias;
        }

        /**
         * Player's display name.
         */
        public function get displayName():String {
            return mDisplayName;
        }

        /**
         * <strong>Android only</strong>: The URI for loading this player's icon-size profile image.
         */
        public function get iconImageUri():String {
            return mIconImageUri;
        }

        /**
         * <strong>Android only</strong>: The URI for loading this player's hi-res profile image.
         */
        public function get hiResImageUri():String {
            return mHiResImageUri;
        }
    }

}

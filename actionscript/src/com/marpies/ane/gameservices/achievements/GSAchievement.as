package com.marpies.ane.gameservices.achievements {

    /**
     * Class representing an achievement.
     */
    public class GSAchievement {

        private var mId:String;
        private var mSteps:int;
        private var mTotalSteps:int;
        private var mProgress:Number;

        /**
         * Creates new achievement object. You should only need to use this
         * when reporting multiple achievements using the <code>GameServices.achievements.report()</code> method.
         *
         * @param id The achievement identifier.
         * @param step <strong>Android only</strong> - The step value to set the achievement to.
         * @param progress <strong>iOS only</strong> - The progress value to set the achievement to.
         *
         * @see com.marpies.ane.gameservices.achievements.GSAchievements#report()
         */
        public function GSAchievement( id:String, step:int, progress:Number ) {
            if( id === null ) throw new ArgumentError( "Parameter id cannot be null." );

            mId = id;
            mSteps = step;
            mProgress = progress;
            if( mProgress !== mProgress ) { // isNaN
                mProgress = 0;
            }
        }

        /**
         * @private
         */
        public function toString():String {
            return "{GSAchievement id: " + mId + " steps: " + mSteps + "/" + mTotalSteps + " progress: " + mProgress + "}";
        }

        /**
         * @private
         */
        internal static function fromJSONArray( jsonArray:Array ):Vector.<GSAchievement> {
            var result:Vector.<GSAchievement> = new <GSAchievement>[];
            var length:int = jsonArray.length;
            for( var i:int = 0; i < length; ++i ) {
                result[i] = GSAchievement.fromJSON( jsonArray[i] );
            }
            return result;
        }

        /**
         * @private
         */
        private static function fromJSON( json:Object ):GSAchievement {
            if( json is String ) {
                json = JSON.parse( json as String );
            }
            var achievement:GSAchievement = new GSAchievement(
                    json.id,
                    ("steps" in json) ? json.steps : 0,
                    ("progress" in json) ? json.progress : 0
            );
            achievement.ns_gameservices_internal::totalSteps = ("totalSteps" in json) ? json.totalSteps : 0;
            return achievement;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Returns the ID of this achievement.
         */
        public function get id():String {
            return mId;
        }

        /**
         * <strong>Android only</strong> - Returns the number of steps this user has gone toward unlocking
         * this achievement.
         */
        public function get steps():int {
            return mSteps;
        }

        /**
         * <strong>Android only</strong> - Returns the total number of steps necessary to unlock this achievement.
         */
        public function get totalSteps():int {
            return mTotalSteps;
        }

        /**
         * @private
         */
        ns_gameservices_internal function set totalSteps( value:int ):void {
            mTotalSteps = value;
            if( mTotalSteps > 0 ) {
                mProgress = mSteps / mTotalSteps;
            }
        }

        /**
         * <strong>iOS only</strong> - Returns a percentage value that states how far the player has progressed
         * on this achievement. The value is in the range of 0.0 - 100.0, inclusive.
         */
        public function get progress():Number {
            return mProgress;
        }

    }

}

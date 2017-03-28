package com.marpies.ane.gameservices.events {

    import com.marpies.ane.gameservices.achievements.GSAchievement;

    import flash.events.Event;

    /**
     * Dispatched when one of the method related to achievements is called.
     */
    public class GSAchievementEvent extends GSErrorEvent {

        /**
         * Successfully loaded the achievements.
         */
        public static const LOAD_SUCCESS:String = "GSAchievementEvent::loadSuccess";

        /**
         * Failed to load the achievements.
         */
        public static const LOAD_ERROR:String = "GSAchievementEvent::loadError";

        /**
         * The achievements were reset successfully.
         */
        public static const RESET_SUCCESS:String = "GSAchievementEvent::resetSuccess";

        /**
         * The achievements failed to be reset.
         */
        public static const RESET_ERROR:String = "GSAchievementEvent::resetError";

        /**
         * An achievement was updated successfully.
         */
        public static const UPDATE_SUCCESS:String = "GSAchievementEvent::updateSuccess";

        /**
         * Failed to update an achievement.
         */
        public static const UPDATE_ERROR:String = "GSAchievementEvent::updateError";

        /**
         * The native achievements UI has been shown.
         */
        public static const UI_SHOW:String = "GSAchievementEvent::uiShow";

        /**
         * The native achievements UI has been hidden.
         */
        public static const UI_HIDE:String = "GSAchievementEvent::uiHide";

        /**
         * Failed to show the native achievements UI.
         */
        public static const UI_ERROR:String = "GSAchievementEvent::uiError";

        private var mAchievements:Vector.<GSAchievement>;

        /**
         * @private
         */
        public function GSAchievementEvent( type:String, errorMessage:String = null, achievements:Vector.<GSAchievement> = null ) {
            super( type, errorMessage );

            mAchievements = achievements;
        }

        /**
         * Returns the loaded achievements.
         */
        public function get achievements():Vector.<GSAchievement> {
            return mAchievements;
        }

        /**
         * @private
         */
        override public function clone():Event {
            return new GSAchievementEvent( type, errorMessage, mAchievements );
        }
    }

}

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

package com.marpies.ane.gameservices {

    import com.marpies.ane.gameservices.achievements.GSAchievements;
    import com.marpies.ane.gameservices.events.GSAuthEvent;
    import com.marpies.ane.gameservices.events.GSIdentityEvent;
    import com.marpies.ane.gameservices.leaderboards.GSLeaderboards;

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.StatusEvent;
    import flash.system.Capabilities;

    CONFIG::ane {
        import flash.external.ExtensionContext;
    }

    /**
     * Class providing access to game services API.
     */
    public class GameServices {

        private static const TAG:String = "[GameServices]";
        private static const EXTENSION_ID:String = "com.marpies.ane.gameServices";
        private static const iOS:Boolean = Capabilities.manufacturer.indexOf( "iOS" ) > -1;
        private static const ANDROID:Boolean = Capabilities.manufacturer.indexOf( "Android" ) > -1;

        CONFIG::ane {
            private static var mContext:ExtensionContext;
        }

        /* GameServices */
        private static var mPlayer:GSPlayer;

        /* Event codes */
        private static const WILL_PRESENT_AUTH_DIALOG:String = "willPresentAuthDialog";
        private static const AUTH_SUCCESS:String = "authSuccess";
        private static const AUTH_ERROR:String = "authError";
        private static const IDENTITY_SUCCESS:String = "identitySuccess";
        private static const IDENTITY_ERROR:String = "identityError";

        /* Misc */
        private static var mLogEnabled:Boolean;
        private static var mInitialized:Boolean;

        /* Event dispatcher */
        private static var mEventDispatcher:IEventDispatcher;

        /**
         * @private
         * Do not use. GameServices is a static class.
         */
        public function GameServices() {
            throw Error( "GameServices is static class." );
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Initializes extension context. An attempt to silently authenticate the user will be made.
         *
         * @param showLogs Set to <code>true</code> to show extension log messages.
         *
         * @return <code>true</code> if the extension context was created, <code>false</code> otherwise
         */
        public static function init( showLogs:Boolean = false ):Boolean {
            if( !isSupportedInternal ) return false;
            if( mInitialized ) return true;

            mLogEnabled = showLogs;

            /* Initialize context */
            if( !initExtensionContext() ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return false;
            }

            CONFIG::ane {
                /* Listen for native library events */
                mContext.addEventListener( StatusEvent.STATUS, onStatus );

                /* Call init */
                mContext.call( "init", showLogs );
                mInitialized = true;
            }

            return mInitialized;
        }

        /**
         * Starts the user authentication flow. If user is not authenticated, a native UI will be presented.
         *
         * @event success com.marpies.ane.gameservices.events.GSAuthEvent Dispatched when the authentication flow
         *                has been completed successfully.
         * @event error com.marpies.ane.gameservices.events.GSAuthEvent Dispatched when the authentication flow
         *              has failed.
         * @event dialogWillAppear com.marpies.ane.gameservices.events.GSAuthEvent Dispatched shortly before the
         *                         native authentication UI is presented.
         * @event success com.marpies.ane.gameservices.events.GSIdentityEvent <strong>iOS only</strong> - Dispatched
         *                when the player's identity signature has been generated successfully.
         * @event error com.marpies.ane.gameservices.events.GSIdentityEvent <strong>iOS only</strong> - Dispatched
         *              when the player's identity signature has failed to be generated.
         */
        public static function authenticate():void {
            if( !isSupportedInternal ) return;
            validateExtensionContext();

            CONFIG::ane {
                mContext.call( "auth" );
            }
        }

        /**
         * <strong>Android only</strong> - Signs out the current signed-in user, if any. It also clears
         * the account previously selected by the user and a future sign in attempt will require the user
         * pick an account again.
         */
        public static function signOut():void {
            if( !isSupportedInternal ) return;
            validateExtensionContext();

            CONFIG::ane {
                mContext.call( "signOut" );
            }
        }

        /**
         *
         * Event dispatcher
         *
         */

        /**
         * Registers an event listener object with an EventDispatcher object so that the listener receives
         * notification of an event.
         *
         * @param type The type of event.
         * @param listener The listener function that processes the event. This function must accept an event object as
         *                 its only parameter.
         * @param useCapture Determines whether the listener works in the capture phase or the target and bubbling
         *                   phases. If <code>useCapture</code> is set to <code>true</code>, the listener processes
         *                   the event only during the capture phase and not in the target or bubbling phase.
         *                   If <code>useCapture</code> is <code>false</code>, the listener processes the
         *                   event only during the target or bubbling phase. To listen for the event in all three
         *                   phases, call <code>addEventListener()</code> twice, once with <code>useCapture</code>
         *                   set to <code>true</code>, then again with <code>useCapture</code> set to <code>false</code>.
         * @param priority The priority level of the event listener. Priorities are designated by a 32-bit integer.
         *                 The higher the number, the higher the priority. All listeners with priority n are processed
         *                 before listeners of priority n-1. If two or more listeners share the same priority,
         *                 they are processed in the order in which they were added. The default priority is 0.
         * @param useWeakReference Determines whether the reference to the listener is strong or weak.
         *                         A strong reference (the default) prevents your listener from being garbage-collected.
         *                         A weak reference does not.
         */
        public static function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void {
            eventDispatcher.addEventListener( type, listener, useCapture, 0, false );
        }

        /**
         * Removes a listener from the EventDispatcher object. If there is no matching listener registered
         * with the <code>EventDispatcher</code> object, a call to this method has no effect.
         *
         * @param type The type of event.
         * @param listener The listener object to remove.
         * @param useCapture Specifies whether the listener was registered for the capture phase or the target
         *                   and bubbling phases. If the listener was registered for both the capture phase and
         *                   the target and bubbling phases, two calls to <code>removeEventListener()</code> are
         *                   required to remove both: one call with <code>useCapture</code> set to <code>true</code>,
         *                   and another call with <code>useCapture</code> set to <code>false</code>.
         */
        public static function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void {
            eventDispatcher.removeEventListener( type, listener, useCapture );
        }

        /**
         * Checks whether the <code>EventDispatcher</code> object has any listeners registered for a specific
         * type of event.
         *
         * @param type The type of event.
         * @return A value of <code>true</code> if a listener of the specified type is registered;
         *         <code>false</code> otherwise.
         */
        public static function hasEventListener( type:String ):Boolean {
            return eventDispatcher.hasEventListener( type );
        }

        /**
         * Disposes native extension context.
         */
        public static function dispose():void {
            if( !isSupportedInternal ) return;
            validateExtensionContext();

            CONFIG::ane {
                mContext.removeEventListener( StatusEvent.STATUS, onStatus );
                mContext.dispose();
                mContext = null;

                GSAchievements.ns_gameservices_internal::dispose();
                mPlayer = null;

                mInitialized = false;
            }
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Returns object providing access to achievements APIs.
         */
        public static function get achievements():GSAchievements {
            var instance:GSAchievements = GSAchievements.ns_gameservices_internal::getInstance();

            CONFIG::ane {
                instance.ns_gameservices_internal::setContext( mContext );
            }

            return instance;
        }

        /**
         * Returns object providing access to leaderboards APIs.
         */
        public static function get leaderboards():GSLeaderboards {
            var instance:GSLeaderboards = GSLeaderboards.ns_gameservices_internal::getInstance();

            CONFIG::ane {
                instance.ns_gameservices_internal::setContext( mContext );
            }

            return instance;
        }

        /**
         * Extension version.
         */
        public static function get version():String {
            return "1.0.2";
        }

        /**
         * Returns <code>true</code> if the user is authenticated.
         */
        public static function get isAuthenticated():Boolean {
            if( !isSupportedInternal ) return false;
            if( !mInitialized && !initExtensionContext() ) {
                return false;
            }

            var result:Boolean;
            CONFIG::ane {
                result = mContext.call( "isAuthenticated" ) as Boolean;
            }
            return result;
        }

        /**
         * Returns an object representing the authenticated player running your game on a device.
         */
        public static function get player():GSPlayer {
            return mPlayer;
        }

        /**
         * Returns <code>true</code> if the extension is initialized.
         */
        public static function get isInitialized():Boolean {
            return mInitialized;
        }

        /**
         * Checks whether the native functionality is supported.
         */
        public static function get isSupported():Boolean {
            if( !isSupportedInternal ) return false;
            if( !initExtensionContext() ) return false;

            var result:Boolean;

            CONFIG::ane {
                result = mContext.call( "isSupported" ) as Boolean;
            }

            return result;
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        private static function onStatus( event:StatusEvent ):void {
            switch( event.code ) {
                case WILL_PRESENT_AUTH_DIALOG:
                    dispatchAuthDialogWillAppear();
                    return;
                case AUTH_SUCCESS:
                    var newPlayer:GSPlayer = GSPlayer.fromJSON( JSON.parse( event.level ) );
                    mPlayer = newPlayer;
                    dispatchAuthSuccess();
                    return;
                case AUTH_ERROR:
                    dispatchAuthError( event.level );
                    return;
                case IDENTITY_SUCCESS:
                    var identity:Object = JSON.parse( event.level );
                    dispatchIdentitySuccess( identity.publicKeyUrl, identity.signature, identity.salt, identity.timestamp );
                    return;
                case IDENTITY_ERROR:
                    dispatchIdentityError( event.level );
                    return;
            }
        }

        /**
         * Initializes extension context.
         *
         * @return <code>true</code> if initialized successfully, <code>false</code> otherwise.
         */
        private static function initExtensionContext():Boolean {
            var result:Boolean;

            CONFIG::ane {
                if( mContext === null ) {
                    mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
                }
                result = mContext !== null;
            }

            return result;
        }

        private static function validateExtensionContext():void {
            CONFIG::ane {
                if( !mContext ) throw new Error( "GameServices extension was not initialized. Call init() first." );
            }
        }

        private static function dispatchAuthDialogWillAppear():void {
            if( !hasEventListener( GSAuthEvent.DIALOG_WILL_APPEAR ) ) return;

            eventDispatcher.dispatchEvent( new GSAuthEvent( GSAuthEvent.DIALOG_WILL_APPEAR ) );
        }

        private static function dispatchAuthSuccess():void {
            if( !hasEventListener( GSAuthEvent.SUCCESS ) ) return;

            eventDispatcher.dispatchEvent( new GSAuthEvent( GSAuthEvent.SUCCESS, null, mPlayer ) );
        }

        private static function dispatchAuthError( message:String ):void {
            if( !hasEventListener( GSAuthEvent.ERROR ) ) return;

            eventDispatcher.dispatchEvent( new GSAuthEvent( GSAuthEvent.ERROR, message ) );
        }

        private static function dispatchIdentitySuccess( publicKeyUrl:String, signature:String, salt:String, timestamp:Number ):void {
            if( !hasEventListener( GSIdentityEvent.SUCCESS ) ) return;

            eventDispatcher.dispatchEvent( new GSIdentityEvent( GSIdentityEvent.SUCCESS, null, publicKeyUrl, signature, salt, timestamp ) );
        }

        private static function dispatchIdentityError( message:String ):void {
            if( !hasEventListener( GSIdentityEvent.ERROR ) ) return;

            eventDispatcher.dispatchEvent( new GSIdentityEvent( GSIdentityEvent.ERROR, message ) );
        }

        private static function get eventDispatcher():IEventDispatcher {
            if( mEventDispatcher == null ) {
                mEventDispatcher = new EventDispatcher();
            }
            return mEventDispatcher;
        }

        private static function get isSupportedInternal():Boolean {
            return iOS || ANDROID;
        }

        private static function log( message:String ):void {
            if( mLogEnabled ) {
                trace( TAG, message );
            }
        }

    }
}

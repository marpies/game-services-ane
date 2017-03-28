/*
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

package com.marpies.ane.gameservices.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.marpies.ane.gameservices.functions.BaseFunction;
import com.marpies.ane.gameservices.utils.AIR;
import com.marpies.ane.gameservices.utils.GameServicesHelper;

public class IsSupportedFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		try {
			return FREObject.newObject( GameServicesHelper.checkPlayServices( AIR.getContext().getActivity() ) );
		} catch( FREWrongThreadException e ) {
			e.printStackTrace();
		}

		return null;
	}

}

